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

# WiFi名の検証（改行文字や制御文字を除去）
WIFI_NAME=$(echo "$WIFI_NAME" | tr -d '\n\r\t' | sed 's/[[:cntrl:]]//g')

# 空文字列のチェック
if [ -z "$WIFI_NAME" ]; then
    echo "❌ 無効なWiFi名です。"
    exit 1
fi

if [ ! -f "$WHITELIST_FILE" ]; then
    echo "❌ ホワイトリストファイルが見つかりません。"
    exit 1
fi

# WiFi名が存在するかチェック（固定文字列として扱う）
if ! grep -Fxq "$WIFI_NAME" "$WHITELIST_FILE" 2>/dev/null; then
    echo "⚠️  このWiFiはリストに存在しません: $WIFI_NAME"
    exit 1
fi

# WiFi名を削除（コメント行は保持）
grep -Fxv "$WIFI_NAME" "$WHITELIST_FILE" > "${WHITELIST_FILE}.tmp" 2>/dev/null || true
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
