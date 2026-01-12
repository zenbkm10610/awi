#!/bin/bash

# 自動再接続対象WiFi一覧を表示するコマンド

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WHITELIST_FILE="$HOME/.awi-whitelist"

echo "========================================="
echo "自動再接続対象WiFi一覧"
echo "========================================="
echo ""

if [ ! -f "$WHITELIST_FILE" ] || [ ! -s "$WHITELIST_FILE" ]; then
    echo "対象WiFiは登録されていません。"
    echo ""
    echo "現在接続中のWiFiを追加するには:"
    echo "  $SCRIPT_DIR/awi-add.sh"
    echo "  または: awi add"
    exit 0
fi

echo "登録されているWiFi:"
echo "----------------------------------------"
grep -v "^#" "$WHITELIST_FILE" | grep -v "^$" | nl
echo "----------------------------------------"
echo ""

# 現在接続中のWiFiを表示
WIFI_INTERFACE=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $NF}')
CURRENT_WIFI=$(networksetup -getairportnetwork "$WIFI_INTERFACE" 2>/dev/null | sed 's/Current Wi-Fi Network: //')

if [ -n "$CURRENT_WIFI" ] && [ "$CURRENT_WIFI" != "none" ]; then
    # WiFi名の検証（改行文字や制御文字を除去）
    CURRENT_WIFI=$(echo "$CURRENT_WIFI" | tr -d '\n\r\t' | sed 's/[[:cntrl:]]//g')
    echo "現在接続中のWiFi: $CURRENT_WIFI"
    if grep -Fxq "$CURRENT_WIFI" "$WHITELIST_FILE" 2>/dev/null; then
        echo "  ✅ 自動再接続対象です"
    else
        echo "  ⚠️  自動再接続対象ではありません"
        echo "  追加するには: $SCRIPT_DIR/awi-add.sh または awi add"
    fi
else
    echo "現在接続中のWiFi: （未接続）"
fi
echo ""
