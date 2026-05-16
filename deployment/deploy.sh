#!/bin/bash
TARGET_DIR="/var/www/my-app"
cd "$TARGET_DIR" || exit 1

echo "[*] 開始執行自動化部署..."
git fetch origin main
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u})

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "[+] 偵測到 GitHub 有新版本，正在拉取程式碼..."
    git pull origin main
    
    echo "[+] 正在重新構建 Docker 容器..."
    docker build -t my-web-app:latest .
    docker stop my-web-app-container || true
    docker rm my-web-app-container || true
    docker run -d --name my-web-app-container -p 80:3000 my-web-app:latest
    echo "[+] 部署完成！服務已重啟。"
else
    echo "[+] 系統已是最新版本，無需部署。"
fi