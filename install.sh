#!/bin/bash

# --- Универсальный скрипт установки (версия для IP-адреса) ---
# Репозиторий: https://github.com/Stulovo1/MS_Rew
# ОС: Ubuntu 24.04
# Особенность: Не требует домена, доступ по IP:ПОРТ

# --- Обновление системы ---
echo "Обновление системы..."
sudo apt update && sudo apt upgrade -y

# --- Установка необходимых пакетов ---
echo "Установка зависимостей..."
sudo apt install -y curl wget unzip ufw

# --- Установка 3x-ui ---
echo "Установка 3x-ui..."
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

# --- Установка AdGuard Home ---
echo "Установка AdGuard Home..."
# Устанавливаем без запуска мастера настройки в браузере
wget --no-verbose -O - https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v

# --- Установка Lampa (Lampac) ---
echo "Установка Lampa..."
sudo apt-get install -y libnss3-dev libgdk-pixbuf2.0-dev libgtk-3-dev libxss-dev libasound2 xvfb coreutils
curl -L -k -o dotnet-install.sh https://dot.net/v1/dotnet-install.sh
sudo chmod +x dotnet-install.sh
sudo ./dotnet-install.sh --channel 6.0 --runtime aspnetcore --install-dir /usr/share/dotnet
sudo ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
rm dotnet-install.sh

DEST="/home/lampac"
sudo mkdir -p $DEST
cd $DEST
sudo curl -L -k -o publish.zip https://github.com/immisterio/Lampac/releases/latest/download/publish.zip
sudo unzip -o publish.zip
sudo rm -f publish.zip
cd ~

sudo tee /etc/systemd/system/lampac.service > /dev/null <<EOF
[Unit]
Description=Lampac
Wants=network.target
After=network.target

[Service]
WorkingDirectory=$DEST
ExecStart=/usr/bin/dotnet Lampac.dll
Restart=always
LimitNOFILE=32000

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable lampac.service
sudo systemctl start lampac.service

# --- Настройка брандмауэра UFW ---
echo "Настройка брандмауэра..."
sudo ufw allow ssh # Разрешаем подключения по SSH
sudo ufw allow 443/tcp # Порт для VLESS Reality
sudo ufw allow 2053/tcp # Порт для веб-интерфейса 3x-ui
sudo ufw allow 3000/tcp # Порт для первоначальной настройки AdGuard
sudo ufw allow 8090/tcp # Порт для Lampa
sudo ufw --force enable # Включаем брандмауэр

# --- Завершение ---
echo "================================================================="
echo "Установка завершена!"
echo ""
echo "ВАЖНО: Доступ к сервисам осуществляется по IP-адресу и порту."
echo "Не забудьте завершить настройку в веб-интерфейсах."
echo ""
echo "Адреса для доступа:"
echo "AdGuard Home (первоначальная настройка): http://185.217.199.157:3000"
echo "3x-ui (логин/пароль в выводе установки): http://185.217.199.157:2053"
echo "Lampa: http://185.217.199.157:8090"
echo ""
echo "Брандмауэр настроен для разрешения доступов к этим портам."
echo "================================================================="
