#!/bin/bash

# Automatic WiFi Connecting Tool (awi)
# コマンドラインインターフェース

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# サブコマンド
case "$1" in
    "status")
        exec "$SCRIPT_DIR/awi-status.sh"
        ;;
    "reconnect")
        exec "$SCRIPT_DIR/awi-reconnect.sh"
        ;;
    "list")
        exec "$SCRIPT_DIR/awi-list.sh"
        ;;
    "add")
        exec "$SCRIPT_DIR/awi-add.sh"
        ;;
    "remove")
        if [ -z "$2" ]; then
            echo "使用方法: awi remove <WiFi名>"
            echo ""
            echo "例:"
            echo "  awi remove \"MyWiFi\""
            exit 1
        fi
        exec "$SCRIPT_DIR/awi-remove.sh" "$2"
        ;;
    "log"|"logs")
        LOG_FILE="$HOME/.awi.log"
        if [ "$2" = "-f" ] || [ "$2" = "--follow" ]; then
            echo "ログをリアルタイムで表示中... (Ctrl+Cで終了)"
            echo ""
            tail -f "$LOG_FILE"
        else
            # 最後の20行を表示
            if [ -f "$LOG_FILE" ]; then
                echo "最近のログ（最後の20行）:"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                tail -n 20 "$LOG_FILE"
                echo ""
                echo "リアルタイム表示: awi log -f"
            else
                echo "⚠️  ログファイルが見つかりません"
            fi
        fi
        ;;
    "stop")
        LAUNCHD_FILE="$HOME/Library/LaunchAgents/com.awi.plist"
        if [ ! -f "$LAUNCHD_FILE" ]; then
            echo "❌ サービスが登録されていません。"
            exit 1
        fi
        if launchctl list | grep -q "com.awi"; then
            launchctl unload "$LAUNCHD_FILE" 2>/dev/null
            echo "✅ サービスを停止しました"
        else
            echo "⚠️  サービスは既に停止しています"
        fi
        ;;
    "start")
        LAUNCHD_FILE="$HOME/Library/LaunchAgents/com.awi.plist"
        if [ ! -f "$LAUNCHD_FILE" ]; then
            echo "❌ サービスが登録されていません。"
            echo "   セットアップを実行してください: ./setup-awi.sh"
            exit 1
        fi
        # launchctl listに表示されているかチェック
        if launchctl list | grep -q "com.awi"; then
            SERVICE_PID=$(launchctl list | grep "com.awi" | awk '{print $1}')
            if [ "$SERVICE_PID" != "-" ] && [ -n "$SERVICE_PID" ]; then
                echo "⚠️  サービスは既に実行中です (PID: $SERVICE_PID)"
            else
                echo "✅ サービスは既に読み込み済みです (OnDemand待機中)"
            fi
        else
            launchctl load "$LAUNCHD_FILE" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "✅ サービスを開始しました"
            else
                echo "❌ サービスの開始に失敗しました"
                exit 1
            fi
        fi
        ;;
    "restart")
        LAUNCHD_FILE="$HOME/Library/LaunchAgents/com.awi.plist"
        if [ ! -f "$LAUNCHD_FILE" ]; then
            echo "❌ サービスが登録されていません。"
            echo "   セットアップを実行してください: ./setup-awi.sh"
            exit 1
        fi
        echo "サービスを再起動中..."
        if launchctl list | grep -q "com.awi"; then
            launchctl unload "$LAUNCHD_FILE" 2>/dev/null || true
            sleep 1
        fi
        launchctl load "$LAUNCHD_FILE" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "✅ サービスを再起動しました"
        else
            echo "❌ サービスの再起動に失敗しました"
            exit 1
        fi
        ;;
    "uninstall")
        LAUNCHD_FILE="$HOME/Library/LaunchAgents/com.awi.plist"
        echo "サービスをアンインストール中..."
        if [ -f "$LAUNCHD_FILE" ]; then
            if launchctl list | grep -q "com.awi"; then
                launchctl unload "$LAUNCHD_FILE" 2>/dev/null || true
            fi
            rm "$LAUNCHD_FILE"
            echo "✅ サービスを削除しました"
        else
            echo "⚠️  サービスは登録されていません"
        fi
        
        # エイリアスも削除するか確認
        SHELL_CONFIG=""
        if [ -f "$HOME/.zshrc" ]; then
            SHELL_CONFIG="$HOME/.zshrc"
        elif [ -f "$HOME/.bashrc" ]; then
            SHELL_CONFIG="$HOME/.bashrc"
        fi
        
        if [ -n "$SHELL_CONFIG" ] && grep -q "awi" "$SHELL_CONFIG" 2>/dev/null; then
            echo ""
            echo "エイリアス設定を削除しますか？ (y/N)"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                # エイリアスブロックを削除
                sed -i.bak '/# Automatic WiFi Connecting Tool (awi)/,/^$/d' "$SHELL_CONFIG" 2>/dev/null || \
                sed -i '' '/# Automatic WiFi Connecting Tool (awi)/,/^$/d' "$SHELL_CONFIG" 2>/dev/null || true
                echo "✅ エイリアス設定を削除しました: $SHELL_CONFIG"
                echo "   反映するには: source $SHELL_CONFIG"
            fi
        fi
        
        echo ""
        echo "✅ アンインストール完了"
        echo "   注意: ログファイルやステータスファイルは残っています"
        echo "   完全に削除する場合は手動で削除してください:"
        echo "   - ~/.awi.log"
        echo "   - ~/.awi.status"
        echo "   - ~/.awi-whitelist"
        ;;
    "help"|"--help"|"-h"|"")
        echo "Automatic WiFi Connecting Tool (awi)"
        echo ""
        echo "使用方法:"
        echo "  awi <command> [options]"
        echo ""
        echo "コマンド:"
        echo "  status      - WiFi再接続ステータスを確認"
        echo "  reconnect   - 手動でWiFiを再接続"
        echo "  list        - 自動再接続対象WiFi一覧を表示"
        echo "  add         - 現在接続中のWiFiを対象に追加"
        echo "  remove <名> - 指定したWiFiを対象から削除"
        echo "  start       - サービスを開始"
        echo "  stop        - サービスを停止"
        echo "  restart     - サービスを再起動"
        echo "  uninstall   - サービスをアンインストール"
        echo "  log [-f]    - ログを表示（-fでリアルタイム）"
        echo "  help        - このヘルプを表示"
        echo ""
        echo "例:"
        echo "  awi status"
        echo "  awi reconnect"
        echo "  awi list"
        echo "  awi add"
        echo "  awi remove \"MyWiFi\""
        echo "  awi start"
        echo "  awi stop"
        echo "  awi restart"
        echo "  awi uninstall"
        echo "  awi log"
        echo "  awi log -f"
        ;;
    *)
        echo "エラー: 不明なコマンド '$1'"
        echo ""
        echo "使用方法: awi <command>"
        echo "ヘルプ: awi help"
        exit 1
        ;;
esac

