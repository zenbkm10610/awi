#!/bin/bash

# WiFi自動再接続のセットアップスクリプト

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST_TEMPLATE="$SCRIPT_DIR/com.awi.plist"
PLIST_FILE="$SCRIPT_DIR/com.awi.plist.tmp"
LAUNCHD_DIR="$HOME/Library/LaunchAgents"
LAUNCHD_FILE="$LAUNCHD_DIR/com.awi.plist"

echo "========================================="
echo "awi セットアップ"
echo "========================================="
echo ""

# スクリプトに実行権限を付与
chmod +x "$SCRIPT_DIR/awi-reconnect.sh"
chmod +x "$SCRIPT_DIR/awi-status.sh"
chmod +x "$SCRIPT_DIR/awi.sh"
chmod +x "$SCRIPT_DIR/awi-add.sh"
chmod +x "$SCRIPT_DIR/awi-list.sh"
chmod +x "$SCRIPT_DIR/awi-remove.sh"
echo "✅ スクリプトに実行権限を付与しました"

# LaunchAgentsディレクトリが存在しない場合は作成
mkdir -p "$LAUNCHD_DIR"
echo "✅ LaunchAgentsディレクトリを確認しました"

# 既存のサービスを確実に停止（重複登録を防ぐ）
if [ -f "$LAUNCHD_FILE" ]; then
    echo "既存のサービスを停止中..."
    # サービスが実行中かどうかに関わらず、unloadを試みる
    launchctl unload "$LAUNCHD_FILE" 2>/dev/null || true
    # 念のため、もう一度確認してunload
    if launchctl list | grep -q "com.awi"; then
        launchctl unload "$LAUNCHD_FILE" 2>/dev/null || true
    fi
    echo "✅ 既存のサービスを停止しました"
fi

# 古いサービスも停止（移行用）
if launchctl list | grep -q "com.wifi.reconnect"; then
    echo "古いサービスを停止中..."
    launchctl unload "$HOME/Library/LaunchAgents/com.wifi.reconnect.plist" 2>/dev/null || true
fi

# ホワイトリストを移行（古いファイルが存在する場合）
OLD_WHITELIST="$HOME/.wifi-reconnect-whitelist"
NEW_WHITELIST="$HOME/.awi-whitelist"
if [ -f "$OLD_WHITELIST" ] && [ ! -f "$NEW_WHITELIST" ]; then
    cp "$OLD_WHITELIST" "$NEW_WHITELIST"
    echo "✅ ホワイトリストを移行しました: $OLD_WHITELIST → $NEW_WHITELIST"
fi

# plistファイルを動的に生成（パスを置換）
sed "s|/Users/Kenta/work/wifi-reconnect|$SCRIPT_DIR|g" "$PLIST_TEMPLATE" | \
    sed "s|/Users/Kenta|$HOME|g" > "$PLIST_FILE"
cp "$PLIST_FILE" "$LAUNCHD_FILE"
rm -f "$PLIST_FILE"
echo "✅ plistファイルを生成・コピーしました"

# サービスを読み込んで開始
launchctl load "$LAUNCHD_FILE" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ サービスを開始しました"
else
    echo "⚠️  サービスの読み込みに失敗しました。既に実行中かもしれません。"
    echo "   確認: launchctl list | grep com.awi"
fi

# エイリアス設定を追加
echo ""
echo "エイリアス設定を追加中..."
SHELL_CONFIG=""
if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ] || [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
else
    # デフォルトでzshrcを試す
    SHELL_CONFIG="$HOME/.zshrc"
fi

ALIAS_BLOCK="# Automatic WiFi Connecting Tool (awi)
alias awi='$SCRIPT_DIR/awi.sh'
"

if [ -f "$SHELL_CONFIG" ]; then
    # 既にエイリアスが追加されているかチェック
    if grep -q "awi" "$SHELL_CONFIG" 2>/dev/null && grep -q "wifi-reconnect\|awi-reconnect" "$SHELL_CONFIG" 2>/dev/null; then
        echo "⚠️  エイリアスは既に設定されています: $SHELL_CONFIG"
    else
        # 古いwifi-*エイリアスを削除（存在する場合）
        if grep -q "wifi-status\|wifi-reconnect" "$SHELL_CONFIG" 2>/dev/null; then
            # 古いエイリアスブロックを削除
            sed -i.bak '/# WiFi自動再接続エイリアス/,/^$/d' "$SHELL_CONFIG" 2>/dev/null || \
            sed -i '' '/# WiFi自動再接続エイリアス/,/^$/d' "$SHELL_CONFIG" 2>/dev/null || true
        fi
        echo "" >> "$SHELL_CONFIG"
        echo "$ALIAS_BLOCK" >> "$SHELL_CONFIG"
        echo "✅ エイリアスを追加しました: $SHELL_CONFIG"
        echo "   反映するには: source $SHELL_CONFIG"
    fi
else
    # ファイルが存在しない場合は作成
    echo "$ALIAS_BLOCK" > "$SHELL_CONFIG"
    echo "✅ エイリアスファイルを作成しました: $SHELL_CONFIG"
    echo "   反映するには: source $SHELL_CONFIG"
fi

echo ""
echo "========================================="
echo "セットアップ完了！"
echo "========================================="
echo ""
echo "📋 設定内容:"
echo "   - 45分ごとにWiFiを自動再接続します"
echo "   - ログファイル: ~/.awi.log"
echo "   - ステータスファイル: ~/.awi.status"
echo "   - エイリアス設定: $SHELL_CONFIG"
echo ""
echo "🔍 便利なコマンド（awiコマンド）:"
echo "   awi status       # ステータス確認"
echo "   awi reconnect    # 手動再接続"
echo "   awi add          # 現在のWiFiを追加"
echo "   awi list         # 対象WiFi一覧"
echo "   awi remove <名>  # WiFiを削除"
echo "   awi help         # ヘルプを表示"
echo ""
echo "   注意: 新しいターミナルセッションを開くか、"
echo "         source $SHELL_CONFIG を実行してください"
echo ""
echo "🔍 確認コマンド:"
echo "   # ステータスを確認"
echo "   $SCRIPT_DIR/awi-status.sh"
echo ""
echo "   # サービスが実行中か確認"
echo "   launchctl list | grep com.awi"
echo ""
echo "   # ログを確認"
echo "   tail -f ~/.awi.log"
echo ""
echo "   # サービスを停止"
echo "   launchctl unload ~/Library/LaunchAgents/com.awi.plist"
echo ""
echo "   # サービスを再開"
echo "   launchctl load ~/Library/LaunchAgents/com.awi.plist"
echo ""
echo "   # サービスを削除"
echo "   launchctl unload ~/Library/LaunchAgents/com.awi.plist"
echo "   rm ~/Library/LaunchAgents/com.awi.plist"
echo ""
