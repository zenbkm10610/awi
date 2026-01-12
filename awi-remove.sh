#!/bin/bash

# WiFi自動再接続対象から削除するコマンド

WHITELIST_FILE="$HOME/.awi-whitelist"

if [ -z "$1" ]; then
    echo "使用方法: $0 <WiFi名>"
    echo ""
    echo "例:"
    echo "  $0 \"MyWiFi\""
    echo "  $0 \"at_STARBUCKS_Wi2\""
    exit 1
fi

WIFI_NAME="$1"

if [ ! -f "$WHITELIST_FILE" ]; then
    echo "❌ ホワイトリストファイルが見つかりません。"
    exit 1
fi

# WiFi名が存在するかチェック
if ! grep -q "^${WIFI_NAME}$" "$WHITELIST_FILE"; then
    echo "⚠️  このWiFiはリストに存在しません: $WIFI_NAME"
    exit 1
fi

# WiFi名を削除（コメント行は保持）
grep -v "^${WIFI_NAME}$" "$WHITELIST_FILE" > "${WHITELIST_FILE}.tmp"
mv "${WHITELIST_FILE}.tmp" "$WHITELIST_FILE"

echo "✅ 削除しました: $WIFI_NAME"
echo ""
echo "現在の対象WiFi一覧:"
echo "----------------------------------------"
if [ -s "$WHITELIST_FILE" ]; then
    grep -v "^#" "$WHITELIST_FILE" | grep -v "^$" | nl
else
    echo "（リストは空です）"
fi
echo "----------------------------------------"
echo ""
