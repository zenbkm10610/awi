#!/bin/bash

# WiFi自動再接続スクリプト
# ホワイトリストに登録されたWiFiで45分ごとに再接続が必要な場合に使用

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ログファイルのパス
LOG_FILE="$HOME/.awi.log"
STATUS_FILE="$HOME/.awi.status"

# ログ関数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ステータスファイルに最後の再接続時間を記録
update_status() {
    local status="$1"
    local wifi_name="$2"
    echo "last_reconnect=$(date '+%Y-%m-%d %H:%M:%S')" > "$STATUS_FILE"
    echo "status=$status" >> "$STATUS_FILE"
    echo "wifi_name=$wifi_name" >> "$STATUS_FILE"
}

# WiFiインターフェース名を取得（通常はen0）
WIFI_INTERFACE=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $NF}')

# 現在接続中のWiFiネットワーク名を取得
CURRENT_WIFI=$(networksetup -getairportnetwork "$WIFI_INTERFACE" 2>/dev/null | sed 's/Current Wi-Fi Network: //')
if [ -z "$CURRENT_WIFI" ] || [ "$CURRENT_WIFI" = "none" ]; then
    CURRENT_WIFI=""
fi

# WiFiが接続されていない場合は終了
if [ -z "$CURRENT_WIFI" ]; then
    log "WiFiが接続されていません。スキップします。"
    update_status "disconnected" ""
    if [ -t 1 ]; then
        echo "⚠️  WiFiが接続されていません。スキップします。"
    fi
    exit 0
fi

log "現在のWiFi: $CURRENT_WIFI"

# ホワイトリストファイルのパス
WHITELIST_FILE="$HOME/.awi-whitelist"

# ホワイトリストに登録されているかチェック
if [ ! -f "$WHITELIST_FILE" ] || [ ! -s "$WHITELIST_FILE" ]; then
    log "ホワイトリストが空または存在しません（$CURRENT_WIFI）。スキップします。"
    log "現在のWiFiを追加するには: $SCRIPT_DIR/awi-add.sh または awi add"
    update_status "skipped" "$CURRENT_WIFI"
    if [ -t 1 ]; then
        echo "⚠️  ホワイトリストが空です。スキップします。"
        echo "   追加するには: awi add"
    fi
    exit 0
fi

# ホワイトリストに登録されているか確認
if ! grep -q "^${CURRENT_WIFI}$" "$WHITELIST_FILE" 2>/dev/null; then
    log "ホワイトリストに登録されていません（$CURRENT_WIFI）。スキップします。"
    update_status "skipped" "$CURRENT_WIFI"
    if [ -t 1 ]; then
        echo "⚠️  ホワイトリストに登録されていません（$CURRENT_WIFI）。スキップします。"
        echo "   追加するには: awi add"
    fi
    exit 0
fi

log "ホワイトリストに登録されているWiFiです。再接続を実行します。"

# WiFiインターフェース名を取得（通常はen0）
WIFI_INTERFACE=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $NF}')

if [ -z "$WIFI_INTERFACE" ]; then
    log "WiFiインターフェースが見つかりません。"
    update_status "error" ""
    exit 1
fi

log "WiFiインターフェース: $WIFI_INTERFACE"

# WiFiをオフにしてからオンにする（再接続）
log "WiFiを再接続中..."

# ターミナルに実行中のUIを表示（標準出力がある場合のみ）
if [ -t 1 ]; then
    echo ""
    echo "🔄 WiFi再接続中..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -n "   ステップ 1/3: WiFiをオフにしています"
    for i in {1..3}; do
        echo -n "."
        sleep 0.5
    done
    echo " ✅"
fi

# WiFiをオフ
networksetup -setairportpower "$WIFI_INTERFACE" off
sleep 2

if [ -t 1 ]; then
    echo -n "   ステップ 2/3: WiFiをオンにしています"
    for i in {1..3}; do
        echo -n "."
        sleep 0.5
    done
    echo " ✅"
fi

# WiFiをオン
networksetup -setairportpower "$WIFI_INTERFACE" on
sleep 8

if [ -t 1 ]; then
    echo -n "   ステップ 3/3: 再接続を確認中"
fi

# 再接続後の状態を確認（最大5回、1秒間隔でリトライ）
NEW_WIFI=""
for i in {1..5}; do
    if [ -t 1 ]; then
        echo -n "."
    fi
    sleep 1
    NEW_WIFI=$(networksetup -getairportnetwork "$WIFI_INTERFACE" 2>/dev/null | sed 's/Current Wi-Fi Network: //')
    # エラーメッセージや無効な値を除外
    if [ -n "$NEW_WIFI" ] && [ "$NEW_WIFI" != "none" ] && [[ ! "$NEW_WIFI" =~ "not associated" ]] && [[ ! "$NEW_WIFI" =~ "AirPort" ]]; then
        break
    fi
    NEW_WIFI=""
done

if [ -t 1 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

if [ -n "$NEW_WIFI" ]; then
    log "再接続成功: $NEW_WIFI"
    update_status "connected" "$NEW_WIFI"
    if [ -t 1 ]; then
        echo ""
        echo "✅ 再接続成功！"
        echo "   ネットワーク: $NEW_WIFI"
        echo ""
    fi
else
    log "再接続に失敗しました。手動で確認してください。"
    update_status "failed" "$CURRENT_WIFI"
    if [ -t 1 ]; then
        echo ""
        echo "❌ 再接続に失敗しました"
        echo "   手動で確認してください"
        echo ""
    fi
    exit 1
fi
