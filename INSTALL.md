# インストール方法

## 方法 1: GitHub からクローン（推奨）

```bash
# リポジトリをクローン
git clone https://github.com/YOUR_USERNAME/awi.git
cd awi

# セットアップスクリプトを実行
./setup-awi.sh
```

## 方法 2: ZIP ファイルをダウンロード

1. GitHub のリポジトリページから「Code」→「Download ZIP」をクリック
2. ZIP ファイルを解凍
3. ターミナルで解凍したディレクトリに移動
4. セットアップスクリプトを実行：

```bash
cd awi-main  # 解凍したディレクトリ名に合わせて変更
./setup-awi.sh
```

## 方法 3: Homebrew（オプション）

Homebrew formula を作成している場合：

```bash
brew install awi
```

## セットアップ後の確認

セットアップが完了したら、新しいターミナルを開くか、以下を実行：

```bash
source ~/.zshrc  # または source ~/.bashrc
```

その後、`awi`コマンドが使えることを確認：

```bash
awi help
awi status
```

## アンインストール

`awi uninstall`コマンドで簡単にアンインストールできます：

```bash
# サービスをアンインストール（推奨）
awi uninstall
```

このコマンドは以下を実行します：
- サービスの停止と削除
- エイリアス設定の削除（確認付き）

**注意**: ログファイルや設定ファイル（`~/.awi.log`, `~/.awi.status`, `~/.awi-whitelist`）は残ります。完全に削除する場合は手動で削除してください。

### 手動でアンインストールする場合

```bash
# サービスを停止
launchctl unload ~/Library/LaunchAgents/com.awi.plist

# plistファイルを削除
rm ~/Library/LaunchAgents/com.awi.plist

# エイリアスを削除（~/.zshrcまたは~/.bashrcから手動で削除）
# または、以下のコマンドで削除：
sed -i.bak '/# Automatic WiFi Connecting Tool (awi)/,/^$/d' ~/.zshrc

# ログファイルや設定ファイルを削除（オプション）
rm ~/.awi.log
rm ~/.awi.status
rm ~/.awi-whitelist
```
