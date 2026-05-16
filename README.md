# Linux System Automation & Lightweight DevOps Practice

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Linux](https://img.shields.io/badge/OS-Linux%20%2F%20Ubuntu-orange.svg)](https://ubuntu.com/)

本專案旨在透過自動化 Shell 腳本解決 Linux 伺服器運維中的常見痛點，包含**批次權限配置、服務動態自癒、以及基於 Docker 容器的自動化部署機制**。實踐「基礎設施即程式碼 (IaC)」與運維安全（SecOps）的核心思維。

## 🛠️ 技術棧 (Tech Stack)
- **Operating System:** Ubuntu 24.04 LTS / Debian
- **Scripting Language:** Bash Shell Scripting (`awk`, `sed`, `grep` 文字流處理)
- **Containerization:** Docker (Alpine Linux base)
- **Version Control:** Git Distributed Version Control

---

## 📦 核心功能說明

### 1. 使用者權限與安全稽核 (`scripts/manage_users.sh`)
- **批次處理：** 解析 CSV/TXT 文字串流，自動化建立帳號、配置群組（Group）。
- **資安實踐：** 強制執行最小權限原則（Least Privilege），透過 `chage` 限制密碼有效期限。
- **後門掃描：** 動態稽核 `/etc/passwd`，主動偵測是否有非 root 使用者具備 UID 0 的特權異常。

### 2. 系統監控與服務自癒 (`scripts/sys_monitor.sh`)
- **資源審查：** 定時監測 CPU 與 Memory 負載率，若超越臨界值（Threshold）自動觸發警報日誌。
- **動態自癒 (Self-Healing)：** 整合 `systemctl`，當偵測到目標服務（如 Nginx）異常中斷時，於秒級內嘗試自動重啟修復，確保服務高可用性。

### 3. 自動化部署流程 (`deployment/`)
- **環境隔離：** 撰寫 `Dockerfile`，利用多階段構建（Multi-stage build）將應用封裝至輕量化 Alpine 映像檔中。
- **CI/CD 精神：** `deploy.sh` 透過比對 Git Commit SHA-1 雜湊值偵測程式碼更新，實作自動拉取（Pull）與重構容器。

---

## 🚀 如何執行與測試

### 環境準備
建議於 **VirtualBox (Ubuntu)** 或 **AWS EC2 雲端伺服器** 環境下運行。

### 執行步驟
1. 克隆專案 (Clone the repository):
   ```bash
   git clone [https://github.com/vincent560/linux-automation-devops.git](https://github.com/vincent560/linux-automation-devops.git)
   cd linux-automation-devops
