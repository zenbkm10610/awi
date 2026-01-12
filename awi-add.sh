#!/bin/bash

# 現在接続中のWiFiを自動再接続対象に追加するコマンド

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WHITELIST_FILE="$HOME/.awi-whitelist"

# WiFiインターフェース名を取得
WIFI_INTERFACE=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $NF}')

# 現在接続中のWiFiネットワーク名を取得
CURRENT_WIFI=$(networksetup -getairportnetwork "$WIFI_INTERFACE" 2>/dev/null | sed 's/Current Wi-Fi Network: //')
if [ -z "$CURRENT_WIFI" ] || [ "$CURRENT_WIFI" = "none" ]; then
    echo "❌ WiFiが接続されていません。"
    exit 1
fi

# WiFi名の検証（改行文字や制御文字を除去）
CURRENT_WIFI=$(echo "$CURRENT_WIFI" | tr -d '\n\r\t' | sed 's/[[:cntrl:]]//g')

echo "========================================="
echo "WiFi自動再接続対象に追加"
echo "========================================="
echo ""
echo "現在のWiFi: $CURRENT_WIFI"
echo ""

# ホワイトリストファイルが存在しない場合は作成
if [ ! -f "$WHITELIST_FILE" ]; then
    touch "$WHITELIST_FILE"
    chmod 600 "$WHITELIST_FILE"  # 所有者のみ読み書き可能
    echo "# WiFi自動再接続対象リスト" >> "$WHITELIST_FILE"
    echo "# 1行に1つのWiFi名を記述" >> "$WHITELIST_FILE"
fi

# 既に追加されているかチェック（固定文字列として扱う）
if grep -Fxq "$CURRENT_WIFI" "$WHITELIST_FILE" 2>/dev/null; then
    echo "⚠️  このWiFiは既に追加されています: $CURRENT_WIFI"
    exit 0
fi

# WiFi名を追加
echo "$CURRENT_WIFI" >> "$WHITELIST_FILE"
echo "✅ 追加しました: $CURRENT_WIFI"
echo ""
echo "現在の対象WiFi一覧:"
echo "----------------------------------------"
grep -v "^#" "$WHITELIST_FILE" | grep -v "^$" | nl
echo "----------------------------------------"
echo ""
echo "削除する場合は:"
echo "  $SCRIPT_DIR/awi-remove.sh \"$CURRENT_WIFI\""
echo "  または: awi remove \"$CURRENT_WIFI\""
echo ""
