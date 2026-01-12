# Automatic WiFi Connecting Tool (awi) - クイックスタート

## セットアップ（初回のみ）

```bash
# プロジェクトディレクトリに移動（ダウンロードした場所に合わせて変更）
cd awi
./setup-awi.sh
```

これで 45 分ごとに自動再接続が開始され、`awi`コマンドが使えるようになります。

---

## よく使うコマンド

### ステータス確認

```bash
awi status
```

### 現在の WiFi を自動再接続対象に追加

```bash
awi add
```

### 対象 WiFi 一覧を表示

```bash
awi list
```

### WiFi を対象から削除

```bash
awi remove "WiFi名"
```

### 手動で再接続テスト

```bash
awi reconnect
```

### ヘルプを表示

```bash
awi help
```

### ログを確認

```bash
# awiコマンドでログを確認（推奨）
awi log          # 最近のログ（最後の20行）を表示
awi log -f       # ログをリアルタイムで確認

# または直接ファイルを確認
tail -f ~/.awi.log
```

---

## サービスの制御

### サービスを開始

```bash
awi start
```

### サービスを停止

```bash
awi stop
```

### サービスを再起動

```bash
awi restart
```

### サービスを削除（完全に無効化）

```bash
awi uninstall
```

### 直接launchctlを使用する場合

```bash
# サービスを停止
launchctl unload ~/Library/LaunchAgents/com.awi.plist

# サービスを再開
launchctl load ~/Library/LaunchAgents/com.awi.plist

# サービスを削除
launchctl unload ~/Library/LaunchAgents/com.awi.plist
rm ~/Library/LaunchAgents/com.awi.plist
```

---

## コマンド一覧

セットアップスクリプトを実行すると、`awi`コマンドが自動的に設定されます。

### 基本コマンド

- `awi status` - ステータス確認
- `awi reconnect` - 手動再接続
- `awi add` - 現在の WiFi を追加
- `awi list` - 対象 WiFi 一覧
- `awi remove "WiFi名"` - WiFi を削除

### サービス管理コマンド

- `awi start` - サービスを開始
- `awi stop` - サービスを停止
- `awi restart` - サービスを再起動
- `awi uninstall` - サービスをアンインストール

### ログ・ヘルプコマンド

- `awi log [-f]` - ログを表示（-fでリアルタイム）
- `awi help` - ヘルプを表示

**注意**: 新しいターミナルセッションを開くか、`source ~/.zshrc`を実行してから`awi`コマンドが使えます。

---

## 設定内容

- **実行間隔**: 45 分ごと
- **ログファイル**: `~/.awi.log`
- **ステータスファイル**: `~/.awi.status`
