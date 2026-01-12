#!/bin/bash

# WiFi再接続ステータス確認コマンド

STATUS_FILE="$HOME/.awi.status"
LOG_FILE="$HOME/.awi.log"

# 色の定義（ターミナルが色をサポートしている場合のみ）
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    GREEN=''
    YELLOW=''
    RED=''
    BLUE=''
    NC=''
fi

echo "========================================="
echo "WiFi再接続ステータス"
echo "========================================="
echo ""

# WiFiインターフェース名を取得
WIFI_INTERFACE=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $NF}')

# 現在のWiFi接続状態を取得
CURRENT_WIFI=$(networksetup -getairportnetwork "$WIFI_INTERFACE" 2>/dev/null | sed 's/Current Wi-Fi Network: //')
if [ -z "$CURRENT_WIFI" ] || [ "$CURRENT_WIFI" = "none" ]; then
    CURRENT_WIFI=""
fi

# WiFiの電源状態を確認
WIFI_POWER=$(ifconfig "$WIFI_INTERFACE" 2>/dev/null | grep -q "status: active" && echo "接続中" || echo "未接続")

echo "📡 現在のWiFi接続:"
if [ -n "$CURRENT_WIFI" ]; then
    echo -e "   ネットワーク名: ${GREEN}$CURRENT_WIFI${NC}"
    echo -e "   状態: ${GREEN}$WIFI_POWER${NC}"
else
    echo -e "   ネットワーク名: ${RED}未接続${NC}"
    echo -e "   状態: ${RED}オフライン${NC}"
fi
echo ""

# ステータスファイルから情報を読み取り
if [ -f "$STATUS_FILE" ]; then
    # sourceの代わりに、個別に値を読み取る
    last_reconnect=$(grep "^last_reconnect=" "$STATUS_FILE" | cut -d'=' -f2-)
    status=$(grep "^status=" "$STATUS_FILE" | cut -d'=' -f2-)
    wifi_name=$(grep "^wifi_name=" "$STATUS_FILE" | cut -d'=' -f2-)
    
    echo "🔄 自動再接続サービス:"
    
    # launchdサービスの状態を確認
    LAUNCHD_FILE="$HOME/Library/LaunchAgents/com.awi.plist"
    if [ ! -f "$LAUNCHD_FILE" ]; then
        echo -e "   サービス状態: ${RED}未登録${NC}"
    elif launchctl list | grep -q "com.awi"; then
        # launchctl listに表示されていれば読み込み済み
        # PIDが-の場合はOnDemandで待機中、数字の場合は実行中
        SERVICE_PID=$(launchctl list | grep "com.awi" | awk '{print $1}')
        if [ "$SERVICE_PID" != "-" ] && [ -n "$SERVICE_PID" ]; then
            echo -e "   サービス状態: ${GREEN}実行中${NC} (PID: $SERVICE_PID)"
        else
            echo -e "   サービス状態: ${GREEN}読み込み済み${NC} (OnDemand待機中)"
        fi
    else
        echo -e "   サービス状態: ${YELLOW}停止中${NC}"
    fi
    echo ""
    
    echo "📅 最後の再接続:"
    if [ -n "$last_reconnect" ]; then
        echo -e "   日時: ${BLUE}$last_reconnect${NC}"
        
        # 経過時間を計算
        LAST_EPOCH=$(date -j -f "%Y-%m-%d %H:%M:%S" "$last_reconnect" +%s 2>/dev/null)
        if [ $? -eq 0 ]; then
            NOW_EPOCH=$(date +%s)
            ELAPSED=$((NOW_EPOCH - LAST_EPOCH))
            
            if [ $ELAPSED -lt 60 ]; then
                echo -e "   経過時間: ${GREEN}${ELAPSED}秒前${NC}"
            elif [ $ELAPSED -lt 3600 ]; then
                MINUTES=$((ELAPSED / 60))
                echo -e "   経過時間: ${GREEN}${MINUTES}分前${NC}"
            else
                HOURS=$((ELAPSED / 3600))
                MINUTES=$(((ELAPSED % 3600) / 60))
                echo -e "   経過時間: ${YELLOW}${HOURS}時間${MINUTES}分前${NC}"
            fi
        fi
    else
        echo -e "   日時: ${YELLOW}記録なし${NC}"
    fi
    echo ""
    
    echo "📊 ステータス:"
    case "$status" in
        "connected")
            echo -e "   状態: ${GREEN}接続済み${NC}"
            if [ -n "$wifi_name" ]; then
                echo -e "   ネットワーク: ${GREEN}$wifi_name${NC}"
            fi
            ;;
        "disconnected")
            echo -e "   状態: ${YELLOW}WiFi未接続（スキップ）${NC}"
            ;;
        "skipped")
            echo -e "   状態: ${BLUE}スタバ以外のWiFi（スキップ）${NC}"
            if [ -n "$wifi_name" ]; then
                echo -e "   ネットワーク: ${BLUE}$wifi_name${NC}"
            fi
            ;;
        "failed")
            echo -e "   状態: ${RED}再接続失敗${NC}"
            if [ -n "$wifi_name" ]; then
                echo -e "   ネットワーク: ${YELLOW}$wifi_name${NC}"
            fi
            ;;
        "error")
            echo -e "   状態: ${RED}エラー${NC}"
            ;;
        *)
            echo -e "   状態: ${YELLOW}不明${NC}"
            ;;
    esac
else
    echo "⚠️  ステータスファイルが見つかりません"
    echo "   サービスがまだ実行されていない可能性があります"
fi
echo ""

# ログファイルの最後の数行を表示
if [ -f "$LOG_FILE" ]; then
    echo "📝 最近のログ（最後の5行）:"
    tail -n 5 "$LOG_FILE" | sed 's/^/   /'
else
    echo -e "📝 ログファイル: ${YELLOW}まだログがありません${NC}"
fi
echo ""
