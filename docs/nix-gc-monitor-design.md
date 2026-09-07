# Nix GC Monitor 設計書

## 1. 文書情報

- ステータス: Draft
- 対象: macOS / nix-darwin / Home Manager
- 実装言語: Go
- 実行方式: Home Managerが管理するユーザーLaunchAgent
- 通知方式: Discord Incoming Webhook
- 想定Nixバージョン: 2.34.8以降

## 2. 背景

Flakeを使ったビルド、開発シェル、nix-darwinやHome Managerの更新により、
`/nix/store` にはStoreパスが追加される。Storeパスは複数のFlakeから共有される
ため、プロジェクト単位の使用量を正確に合計することは難しい。

また、ディスクの空き容量が少ないという理由だけでGCを実行しても、古いシステム
世代、プロファイル、`result`、`nix-direnv`などのGC rootから参照されている
Storeパスは削除されない。そのため、単純な定期GCではなく、ディスクの状態と
GCで解放可能な容量を調査してから通知・判断する仕組みを作る。

## 3. 目的

第1版では、以下を実現する。

1. `/nix` の空き容量を1日1回確認する。
2. 空き容量が設定した閾値を下回った場合のみ、GC候補をdry-runで調査する。
3. ディスク状況とGC効果を基に、対応方針を判定する。
4. 新たに警告状態へ入ったとき、または重要度が上がったときだけDiscordへ通知する。
5. 状態を永続化し、同じ内容の通知を毎日繰り返さない。
6. 利用者が明示的に実行した場合に限り、到達不能なStoreパスをGCする。
7. GC前後の空き容量と解放量を記録し、結果をDiscordへ通知する。

## 4. 対象外

第1版では、以下を対象外とする。

- Discordのボタンやリアクションを使ったリモートGC承認
- Discord Botまたは外部公開HTTPサーバーの運用
- GC rootになっている古いシステム世代の自動削除
- プロジェクトごとの厳密なStore使用量計算
- `/nix/store` のファイルを直接削除する処理
- 常駐デーモンによるリアルタイム監視
- Linux、NixOS、複数ホストの集中監視

Discord Incoming Webhookは通知専用として使う。Discordから操作を受け取る機能は、
Bot、Interactions、署名検証、公開エンドポイントなどを必要とするため、別フェーズ
として扱う。

## 5. 設計方針

### 5.1 安全性

- 日次ジョブは監視と通知だけを行い、GCを自動実行しない。
- GCは `collect --confirm` の明示指定がある場合だけ実行する。
- GCにはNixの公式コマンドを使い、Storeを直接編集しない。
- 第1版のGCは到達不能なStoreパスだけを対象とし、世代削除は行わない。
- Webhook URLをGit、Nix Store、ログ、状態ファイルへ保存しない。
- 同時実行を排他し、日次ジョブと手動GCが競合しないようにする。

### 5.2 小さな1回実行型プロセス

常駐プロセスは作らず、`launchd` が1日1回 `check` を起動する。スリープ中に実行
時刻を過ぎた場合は、Home Managerの `StartCalendarInterval` の動作に従い、
復帰後にまとめて1回実行される。

### 5.3 実験的なNix CLIとの分離

`nix store gc` は実験的インターフェースであるため、コマンド実行と出力解析を
`internal/nixstore` に隔離する。出力形式の変更によって解放可能容量を解析できない
場合でも、監視全体を失敗させず「推定不能」として通知する。

## 6. システム構成

```text
Home Manager
  └─ launchd LaunchAgent
       └─ 1日1回 nix-gc-monitor check
            ├─ /nix のファイルシステム情報を取得
            ├─ 必要な場合だけ nix store gc --dry-run
            ├─ 状態判定
            ├─ 前回状態との比較
            ├─ Discord Incoming Webhookへ通知
            └─ 状態ファイルをアトミック更新

利用者
  ├─ nix-gc-monitor status
  └─ nix-gc-monitor collect --confirm
       ├─ 実行直前の状態を再確認
       ├─ nix store gc --max <上限>
       ├─ 実行前後の容量を比較
       └─ Discordへ結果通知
```

## 7. リポジトリ構成

```text
dotfiles/
├── apps/
│   └── nix-gc-monitor/
│       ├── go.mod
│       ├── go.sum
│       ├── package.nix
│       ├── README.md
│       ├── cmd/
│       │   └── nix-gc-monitor/
│       │       └── main.go
│       └── internal/
│           ├── config/       # 設定の読込・検証
│           ├── disk/         # statfsによる容量取得
│           ├── nixstore/     # dry-run・GC実行・出力解析
│           ├── decision/     # 状態と推奨アクションの決定
│           ├── discord/      # Incoming Webhook
│           ├── state/        # 状態の読込・アトミック保存
│           └── lock/         # プロセス間排他
├── docs/
│   └── nix-gc-monitor-design.md
└── nix/
    └── home/
        ├── default.nix
        └── nix-gc-monitor.nix
```

Goアプリ本体とHome Manager統合を分離する。`package.nix` は `buildGoModule` を使って
バイナリをビルドし、`nix/home/nix-gc-monitor.nix` がパッケージ導入、設定ファイル、
LaunchAgentを宣言する。

## 8. CLI設計

### 8.1 コマンド

```text
nix-gc-monitor check
nix-gc-monitor status
nix-gc-monitor collect --confirm
nix-gc-monitor notify-test
nix-gc-monitor version
```

#### `check`

- ディスク容量を取得する。
- 警告閾値を下回った場合にdry-runを実行する。
- 判定結果と前回状態を比較する。
- 必要な場合だけDiscordへ通知する。
- 状態を保存する。
- `launchd` から呼び出す標準コマンドとする。

#### `status`

- 現在のディスク容量、前回検査時刻、判定、推定解放可能容量を表示する。
- Discord通知とGCは実行しない。
- `--refresh` を指定した場合だけ再検査する。

#### `collect --confirm`

- `--confirm` がなければ処理内容を表示して終了する。
- 排他ロックを取得する。
- 実行直前にディスク容量とdry-runを再確認する。
- `nix store gc --max <設定値>` を実行する。
- GC前後の空き容量を比較する。
- 状態と実行履歴を保存し、Discordへ結果を通知する。

このコマンドは到達不能なStoreパスを削除する。古いシステム世代やプロファイル世代
の削除は行わない。

#### `notify-test`

- Discord設定を検証する。
- 容量情報を含まないテストメッセージを1件送る。
- Webhook URLそのものは出力しない。

### 8.2 終了コード

| コード | 意味 |
|---:|---|
| 0 | 正常終了。警告状態を含む |
| 2 | 設定不備 |
| 3 | 同時実行中 |
| 4 | ディスク情報取得失敗 |
| 5 | Nixコマンド失敗 |
| 6 | Discord通知失敗 |
| 7 | 状態ファイル操作失敗 |

警告状態は監視結果であり、プロセス障害ではないため終了コード0とする。

## 9. 設定

非機密設定はHome Managerが次の場所へ生成する。

```text
~/.config/nix-gc-monitor/config.json
```

Webhook URLは次のローカル専用ファイルへ保存する。

```text
~/.config/nix-gc-monitor/discord-webhook-url
```

Webhookファイルはモード `0600` とし、GitとNix Storeへ入れない。末尾改行は読込時に
除去する。

### 9.1 設定例

```json
{
  "monitor": {
    "path": "/nix",
    "warningFreePercent": 20,
    "criticalFreePercent": 10,
    "warningFreeBytes": 32212254720,
    "criticalFreeBytes": 16106127360,
    "recoveryFreePercent": 25,
    "recoveryFreeBytes": 37580963840
  },
  "gc": {
    "minimumUsefulBytes": 5368709120,
    "maximumDeleteBytes": 21474836480,
    "dryRunTimeoutSeconds": 900,
    "collectTimeoutSeconds": 1800
  },
  "discord": {
    "webhookURLFile": "/Users/kobadai/.config/nix-gc-monitor/discord-webhook-url",
    "notifyRecovery": true,
    "timeoutSeconds": 10
  },
  "runtime": {
    "stateFile": "/Users/kobadai/.local/state/nix-gc-monitor/state.json",
    "lockFile": "/Users/kobadai/.local/state/nix-gc-monitor/lock"
  }
}
```

初期値は仮値であり、実環境のディスク容量と増加ペースを観測した後に調整する。
パーセントとバイト数のどちらか一方が閾値以下なら警告とする。

## 10. 収集する情報

### 10.1 ディスク情報

`/nix` に対して `statfs` を実行し、次を計算する。

- 総容量
- 利用可能容量
- 使用容量
- 利用可能率
- ファイルシステム識別情報
- 検査日時

`/` の空き容量ではなく、実際にNix Storeが存在する `/nix` のファイルシステムを
監視する。

### 10.2 GC候補

警告状態の場合だけ、タイムアウト付きで次を実行する。

```sh
nix store gc --dry-run
```

取得を試みる情報は次のとおり。

- 削除候補パス数
- 推定解放可能容量
- コマンド所要時間
- Nixバージョン

推定値の解析に失敗した場合は `null` とし、dry-runの成功・失敗と解析エラーを別々に
保持する。推定解放可能容量は参考値であり、実際のGC結果と一致する保証はしない。

### 10.3 将来のGC root調査

将来版では、以下を使って保持要因を分類する。

- システムおよびHome Managerの世代
- ユーザープロファイル
- プロジェクト内の `result`
- `nix-direnv` が作成したroot
- 明示的な `--profile`

共有されたStoreパスがあるため、プロジェクト別容量は「推定値」として扱う。

## 11. 判定ロジック

### 11.1 ディスクレベル

```text
critical:
  freePercent <= criticalFreePercent
  OR freeBytes <= criticalFreeBytes

warning:
  freePercent <= warningFreePercent
  OR freeBytes <= warningFreeBytes

healthy:
  上記以外
```

警告状態から正常へ戻す場合は、閾値付近で通知が往復しないように回復用の閾値を使う。

```text
recovered:
  freePercent >= recoveryFreePercent
  AND freeBytes >= recoveryFreeBytes
```

### 11.2 推奨アクション

| ディスク状態 | 推定解放可能容量 | 判定 |
|---|---:|---|
| healthy | 任意 | `none` |
| warning/critical | `minimumUsefulBytes` 以上 | `gc_recommended` |
| warning/critical | `minimumUsefulBytes` 未満 | `roots_review_recommended` |
| warning/critical | 推定不能 | `inspection_required` |

空き容量が少なくても、GCで十分な容量を解放できない場合はGCを強く推奨しない。古い
世代やプロファイルなど、GC rootの確認が必要であることを通知する。

## 12. 状態モデル

保存する状態は、ディスク重要度と推奨アクションの組み合わせとする。

```text
healthy
warning_gc_recommended
warning_roots_review
warning_inspection_required
critical_gc_recommended
critical_roots_review
critical_inspection_required
error
```

### 12.1 状態遷移と通知

次の場合にDiscordへ通知する。

- `healthy` から任意の警告状態へ変わった。
- `warning_*` から `critical_*` へ悪化した。
- 推奨アクションが `roots_review` から `gc_recommended` などへ変わった。
- 警告状態から `healthy` へ回復した。
- GCを手動実行し、成功または失敗した。
- 監視処理が連続して失敗した。

同一状態が継続しているだけなら通知しない。将来、設定可能な週次リマインダーを追加
できるが、第1版では無効とする。

### 12.2 状態ファイル

```json
{
  "schemaVersion": 1,
  "state": "warning_gc_recommended",
  "checkedAt": "2026-07-25T03:00:00+09:00",
  "lastNotifiedAt": "2026-07-25T03:00:02+09:00",
  "consecutiveFailures": 0,
  "disk": {
    "path": "/nix",
    "totalBytes": 1000000000000,
    "freeBytes": 25000000000,
    "freePercent": 2.5
  },
  "gcEstimate": {
    "candidateCount": 120,
    "reclaimableBytes": 8000000000,
    "available": true
  },
  "lastCollection": null
}
```

一時ファイルへ書き込み、`fsync` 後に同一ファイルシステム内でrenameして更新する。
壊れた状態ファイルを検出した場合は、元ファイルを上書きせずエラーとして扱う。

## 13. Discord通知

DiscordのIncoming WebhookへJSONをPOSTする。Botや常時接続は使用しない。

### 13.1 通知内容

- ホスト名
- 状態と重要度
- `/nix` の総容量、空き容量、空き率
- GCで解放可能な推定容量
- 削除候補数
- 推奨アクション
- 検査日時
- 手元で確認・実行するコマンド

例:

```text
Nix Store: GC推奨
Host: macbook
空き容量: 18.4 GiB / 460 GiB (4.0%)
GC推定解放量: 9.2 GiB
状態: critical_gc_recommended

確認: nix-gc-monitor status --refresh
実行: nix-gc-monitor collect --confirm
```

### 13.2 セキュリティ

- `allowed_mentions.parse` を空配列にし、意図しないメンションを無効化する。
- Webhook URLはエラーメッセージ、構造化ログ、HTTPトレースへ出力しない。
- HTTPエラー本文は長さを制限し、Webhook tokenに見える文字列をマスクする。
- リダイレクトは原則拒否する。
- TLS検証を無効化する設定は提供しない。

### 13.3 リトライ

- 接続失敗と5xxは指数バックオフ付きで最大3回試行する。
- 429は `Retry-After` を尊重する。
- 400、401、403、404は設定または権限エラーとして再試行しない。
- 通知失敗時は `lastNotifiedAt` を更新せず、次回検査で再通知できるようにする。

## 14. GC実行

手動実行時は次を使用する。

```sh
nix store gc --max <maximumDeleteBytes>
```

`--max` によって1回のGCで解放する容量に上限を設ける。実行前にdry-runを再実行し、
候補がなくなっている場合はGCを行わない。

重要な制約:

- `nix store gc` は到達不能なStoreパスだけを削除する。
- GC rootから到達可能なStoreパスは削除されない。
- 古い世代を削除してrootを外す処理は別コマンドであり、第1版では実装しない。
- `nix.gc.automatic` は有効化せず、このツールとの二重実行を避ける。

## 15. 排他制御

状態ディレクトリ内のロックファイルへ非ブロッキングの排他ロックを取得する。

```text
~/.local/state/nix-gc-monitor/lock
```

ロック取得に失敗した場合は終了コード3で終了する。ロックはプロセス終了時にOSが解放
できる方式を使い、単なるPIDファイルによる古いロックの残留を避ける。

## 16. launchd / Home Manager統合

`nix/home/nix-gc-monitor.nix` で次を宣言する。

- Goバイナリの `home.packages` への追加
- 非機密な `config.json`
- ユーザーLaunchAgent
- stdout/stderrの出力先

想定設定:

```nix
launchd.agents.nix-gc-monitor = {
  enable = true;
  config = {
    Label = "dev.kobadai.nix-gc-monitor";
    ProgramArguments = [
      "${nixGcMonitor}/bin/nix-gc-monitor"
      "check"
      "--config"
      "/Users/kobadai/.config/nix-gc-monitor/config.json"
    ];
    StartCalendarInterval = [
      {
        Hour = 3;
        Minute = 0;
      }
    ];
    ProcessType = "Background";
    StandardOutPath =
      "/Users/kobadai/Library/Logs/nix-gc-monitor/stdout.log";
    StandardErrorPath =
      "/Users/kobadai/Library/Logs/nix-gc-monitor/stderr.log";
  };
};
```

ログディレクトリはHome Manager activationまたはアプリ初回実行時に作成する。
Webhook secretが存在しない場合、監視自体は実行して状態を保存するが、通知失敗として
明確なエラーを残す。

## 17. ログ

Go標準の `log/slog` を使い、JSON Lines形式で出力する。

記録する項目:

- タイムスタンプ
- レベル
- コマンド名
- 実行ID
- 処理時間
- ディスク状態
- 判定
- Nixコマンドの終了状態
- Discord通知の成否

記録しない項目:

- Discord Webhook URL
- Webhook token
- 環境変数全体
- Nix Store内の全候補パス

候補パスは通常ログへ出さず、デバッグモードで明示された場合だけ別ファイルへ保存する。

## 18. エラー処理

| 障害 | 動作 |
|---|---|
| `/nix` が存在しない | エラー終了し、状態を変更しない |
| `statfs` 失敗 | エラー回数を増やす |
| Nix dry-run失敗 | `inspection_required` として扱う |
| dry-run出力解析失敗 | 解放容量を推定不能として継続する |
| Discord接続失敗 | 状態は保存するが通知済みにはしない |
| 状態ファイル破損 | 上書きせずエラー終了する |
| GCタイムアウト | プロセスを停止し、失敗通知する |
| 同時実行 | 待機せず終了コード3で終了する |

監視エラーそのものによるDiscord通知は、Webhookが利用できる場合に限り、連続2回失敗
した時点で送る。単発障害では通知しない。

## 19. テスト方針

### 19.1 単体テスト

- バイト数と割合の境界値
- warning、critical、recoveryの状態遷移
- 推定解放量による推奨アクション
- 同一状態で通知しないこと
- warningからcriticalへの悪化通知
- 状態ファイルのアトミック保存
- 壊れた状態ファイルの検出
- Webhook URLのマスキング
- Nix出力パーサーのfixtureテスト

### 19.2 結合テスト

- 偽のNixバイナリをPATHまたは依存注入で使用する。
- `httptest.Server` でDiscord成功、429、5xx、4xxを再現する。
- 一時ディレクトリで状態保存と排他を検証する。
- `collect --confirm` なしではGCを呼ばないことを検証する。
- 通知失敗時に通知済み状態へ進まないことを検証する。

### 19.3 Nix側の検証

```sh
go test ./...
go vet ./...
gofmt -l .
nix build .#nix-gc-monitor
nix flake check
```

実環境では最初に `notify-test` と `check` を手動実行し、数日間はGCを実行せず観測結果
だけを確認する。

## 20. 受け入れ条件

- `nix-gc-monitor check` が `/nix` の空き容量を正しく取得できる。
- 正常状態ではdry-runとDiscord通知を実行しない。
- 閾値を下回るとdry-runを実行し、判定結果を保存する。
- 初回の警告状態でDiscord通知が1件届く。
- 同じ状態で再実行しても重複通知されない。
- criticalへの悪化時には追加通知される。
- 回復時に回復通知が届く。
- Webhook URLがGit、Nix Store、ログ、状態ファイルへ含まれない。
- `collect --confirm` なしではGCが実行されない。
- GC後に実測解放量をDiscordへ通知する。
- `launchd` が1日1回実行し、スリープ中の予定は復帰後に1回へ集約される。
- `go test ./...` と `nix flake check` が成功する。

## 21. 実装フェーズ

### Phase 1: 観測のみ

- CLI骨格
- 設定
- ディスク容量取得
- 判定
- 状態保存
- `status`

### Phase 2: Discord通知

- Incoming Webhook
- 状態遷移通知
- リトライ
- secret管理
- `notify-test`

### Phase 3: Nix調査

- `nix store gc --dry-run`
- 出力パーサー
- タイムアウト
- GC効果による推奨アクション

### Phase 4: 手動GC

- `collect --confirm`
- `--max`
- GC前後の計測
- 結果通知

### Phase 5: 宣言的導入

- `buildGoModule`
- Home Managerモジュール
- LaunchAgent
- Nix build/check

### 将来候補

- GC rootの分類と保持要因レポート
- 古い世代を削除する前の承認フロー
- 週次サマリー
- 複数Mac対応
- Discord Interactionsによる署名付きリモート承認

## 22. 未決事項

実装開始前または観測期間後に、以下を決定する。

- warningおよびcriticalの最終閾値
- GC推奨とみなす最小解放容量
- 1回のGCで解放する容量上限
- 日次実行時刻
- 回復通知の要否
- 同じ警告が継続した場合の週次リマインダー要否

第1版では本書の仮値を使用し、設定で変更可能にする。

## 23. 参考資料

- [Nix Reference Manual: `nix store gc`](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-store-gc.html)
- [Home Manager Manual: launchd options](https://nix-community.github.io/home-manager/options/home-manager/launchd.html)
- [Apple: Creating Launch Daemons and Agents](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html)
- [Discord: Webhooks](https://docs.discord.com/developers/platform/webhooks)
- [Discord: Webhook Resource](https://docs.discord.com/developers/resources/webhook)
- [Discord: Rate Limits](https://docs.discord.com/developers/topics/rate-limits)
