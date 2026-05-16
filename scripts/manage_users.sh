#!/bin/bash
# -----------------------------------------------------------------------------
# Script Name: manage_users.sh
# Description: 批次使用者建立、權限分配與安全稽核工具
# Author: 何柏霆 (Student ID: 213410136)
# -----------------------------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    echo "[-] 錯誤：請使用 root 權限 (sudo) 執行此腳本。"
    exit 1
fi

INPUT_FILE="config/users_list.txt"

if [ ! -f "$INPUT_FILE" ]; then
    echo "[-] 錯誤：找不到使用者清單 $INPUT_FILE"
    exit 1
fi

echo "[+] 開始批次處理使用者建立與權限配置..."

while IFS=',' read -r username group expire_days || [ -n "$username" ]; do
    [[ "$username" =~ ^#.*$ ]] || [ -z "$username" ] && continue

    username=$(echo "$username" | xargs)
    group=$(echo "$group" | xargs)
    expire_days=$(echo "$expire_days" | xargs)

    if ! getent group "$group" > /dev/null 2>&1; then
        echo "[*] 群組 $group 不存在，正在建立..."
        groupadd "$group"
    fi

    if id "$username" > /dev/null 2>&1; then
        echo "[-] 警告：使用者 $username 已存在，略過建立。"
    else
        useradd -m -g "$group" -s /bin/bash "$username"
        echo "[+] 成功建立使用者：$username 並加入群組 $group"
        chage -M "$expire_days" "$username"
        echo "[+] 已設定 $username 的密碼強制過期天數為 $expire_days 天"
    fi
done < "$INPUT_FILE"

echo "[+] 使用者權限配置完成。"

echo "[*] 正在進行系統安全稽核：檢查 UID 0 帳號..."
illegal_root=$(awk -F: '($3 == 0) && ($1 != "root") {print $1}' /etc/passwd)

if [ -n "$illegal_root" ]; then
    echo "[-] ⚠️ 警告：發現異常 UID 0 帳號：$illegal_root"
else
    echo "[+] 安全稽核通過：未發現異常特權帳號。"
fi