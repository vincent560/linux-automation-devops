#!/bin/bash
# -----------------------------------------------------------------------------
# Script Name: sys_monitor.sh
# Description: 伺服器資源監控、Nginx 服務自癒與日誌自動備份
# -----------------------------------------------------------------------------

THRESHOLD=85
LOG_DIR="/var/log/sys_monitor"
REPORT_FILE="$LOG_DIR/daily_report.log"

mkdir -p "$LOG_DIR"

echo "=== 監控檢查時間: $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$REPORT_FILE"

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
echo "[*] 當前 CPU 使用率: $CPU_USAGE%" >> "$REPORT_FILE"

MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
echo "[*] 當前記憶體使用率: $(printf "%.2f" "$MEM_USAGE")%" >> "$REPORT_FILE"

if (( $(echo "$CPU_USAGE > $THRESHOLD" | bc -l) )) || (( $(echo "$MEM_USAGE > $THRESHOLD" | bc -l) )); then
    echo "[-] ⚠️ 警告：系統資源耗盡！CPU: $CPU_USAGE%, MEM: $(printf "%.2f" "$MEM_USAGE")%" >> "$REPORT_FILE"
fi

SERVICE="nginx"
if ! systemctl is-active --quiet "$SERVICE"; then
    echo "[-] ⚠️ 偵測到 $SERVICE 服務中斷！嘗試自動重啟..." >> "$REPORT_FILE"
    systemctl start "$SERVICE"
    
    if systemctl is-active --quiet "$SERVICE"; then
        echo "[+] $SERVICE 服務已成功重啟並恢復運作。" >> "$REPORT_FILE"
    else
        echo "[-] ❌ 嚴重錯誤：$SERVICE 自動重啟失敗，需要人工介入。" >> "$REPORT_FILE"
    fi
else
    echo "[+] $SERVICE 服務運作正常。" >> "$REPORT_FILE"
fi

echo "=======================================" >> "$REPORT_FILE"