# Automatic WiFi Connecting Tool (awi)

WiFi で 45 分ごとに再接続が必要な場合に、自動的に WiFi を再接続するツールです。

## 機能

- **自動再接続**: 45 分ごとに WiFi を自動的に再接続します
- **ログ記録**: 再接続の履歴をログファイルに記録します
- **ステータス確認**: 接続状態と最後の再接続時間を確認できます
- **安全な動作**: WiFi が接続されていない場合はスキップします

## セットアップ方法

### 1. プロジェクトをダウンロード

GitHub からクローンするか、ZIP ファイルをダウンロードして解凍してください。

```bash
# GitHubからクローンする場合
git clone git@github.com:zenbkm10610/awi.git
cd awi
```

### 2. セットアップスクリプトを実行

```bash
./setup-awi.sh
```

これで、macOS の launchd サービスとして登録され、自動的に実行されるようになります。

## 使い方

### コマンド

セットアップ後、`awi`コマンドが使えるようになります：

```bash
awi status      # ステータス確認
awi reconnect   # 手動再接続
awi list        # 対象WiFi一覧
awi add         # 現在のWiFiを追加
awi remove <名> # WiFiを削除
awi log [-f]    # ログを表示（-fでリアルタイム）
awi start       # サービスを開始
awi stop        # サービスを停止
awi restart     # サービスを再起動
awi uninstall   # サービスをアンインストール
awi help        # ヘルプを表示
```

ステータスコマンドは以下を表示します：

- 現在の WiFi 接続状態
- 自動再接続サービスの状態
- 最後の再接続日時と経過時間
- 最近のログ

### サービスの確認

```bash
# サービスが実行中か確認
launchctl list | grep com.awi
```

### ログの確認

```bash
# awiコマンドでログを確認（推奨）
awi log          # 最近のログ（最後の20行）を表示
awi log -f       # ログをリアルタイムで確認

# または直接ファイルを確認
tail -f ~/.awi.log
tail -n 20 ~/.awi.log
```

### サービスの制御

```bash
# awiコマンドでサービスを制御（推奨）
awi start      # サービスを開始
awi stop       # サービスを停止
awi restart    # サービスを再起動
awi uninstall  # サービスをアンインストール

# または直接launchctlを使用
launchctl unload ~/Library/LaunchAgents/com.awi.plist
launchctl load ~/Library/LaunchAgents/com.awi.plist
```

## コマンド一覧

セットアップスクリプトを実行すると、`awi`コマンドが自動的に設定されます。

### 基本コマンド

```bash
awi status      # ステータス確認
awi reconnect   # 手動再接続
awi list        # 対象WiFi一覧
awi add         # 現在のWiFiを追加
awi remove <名> # WiFiを削除
```

### サービス管理コマンド

```bash
awi start       # サービスを開始
awi stop        # サービスを停止
awi restart     # サービスを再起動
awi uninstall   # サービスをアンインストール
```

### ログ・ヘルプコマンド

```bash
awi log [-f]    # ログを表示（-fでリアルタイム）
awi help        # ヘルプを表示
```

**注意**: 新しいターミナルセッションを開くか、`source ~/.zshrc`を実行してから`awi`コマンドが使えます。

## 動作の仕組み

1. **launchd**: macOS のバックグラウンドサービス管理システムを使用
2. **実行間隔**: 45 分（2700 秒）ごとに自動実行
3. **再接続方法**: WiFi を一度オフにしてからオンにすることで再接続
4. **ステータス記録**: 最後の再接続時間を`~/.awi.status`に記録

## カスタマイズ

### 実行間隔を変更する場合

`com.awi.plist`の`StartInterval`を変更してください：

```xml
<key>StartInterval</key>
<integer>1800</integer>  <!-- 30分ごと（秒単位） -->
```

変更後、サービスを再読み込みしてください：

```bash
# awiコマンドを使用（推奨）
awi restart

# または直接launchctlを使用
launchctl unload ~/Library/LaunchAgents/com.awi.plist
launchctl load ~/Library/LaunchAgents/com.awi.plist
```

### 特定の WiFi ネットワークで動作させる場合

`awi add`コマンドで、現在接続中の WiFi をホワイトリストに追加できます：

```bash
# 現在接続中のWiFiを追加
awi add

# 対象WiFi一覧を確認
awi list
```

ホワイトリストファイル（`~/.awi-whitelist`）を直接編集することもできます。

## トラブルシューティング

### サービスが起動しない場合

```bash
# エラーログを確認
cat ~/.awi.err.log

# サービスを再起動
awi restart

# または直接launchctlを使用
launchctl unload ~/Library/LaunchAgents/com.awi.plist
launchctl load ~/Library/LaunchAgents/com.awi.plist
```

### 権限エラーが発生する場合

macOS の「システム環境設定」→「セキュリティとプライバシー」→「プライバシー」→「完全なディスクアクセス」で、ターミナルまたはシェルにアクセス権限を付与してください。

### WiFi が再接続されない場合

手動でテストしてみてください：

```bash
# 手動で再接続
awi reconnect

# ログを確認
awi log -f

# ステータスを確認
awi status

# サービスが実行中か確認
launchctl list | grep com.awi
```

## ファイル構成

```
awi/
├── awi.sh                     # メインコマンド（CLI）
├── awi-reconnect.sh            # メインスクリプト
├── awi-status.sh               # ステータス確認コマンド
├── awi-add.sh                  # WiFi追加スクリプト
├── awi-list.sh                 # WiFi一覧スクリプト
├── awi-remove.sh               # WiFi削除スクリプト
├── com.awi.plist               # launchd設定ファイル（テンプレート）
├── setup-awi.sh                # セットアップスクリプト
├── README.md                   # このファイル
├── QUICK_START.md              # クイックスタートガイド
└── FAQ.md                      # よくある質問

~/.awi.log                      # ログファイル
~/.awi.status                   # ステータスファイル
~/.awi-whitelist                # WiFiホワイトリスト
```

## 注意事項

- このスクリプトは WiFi を一時的に切断するため、接続中の通信が中断される可能性があります
- 再接続には数秒かかる場合があります
- スターバックスの WiFi ポータルページが表示される場合は、手動で認証が必要な場合があります
