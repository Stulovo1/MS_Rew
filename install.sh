#!/bin/bash

# --- Универсальный скрипт установки и настройки 3x-ui, AdGuard Home и Lampa ---
# Репозиторий: https://github.com/Stulovo1/MS_Rew
# ОС: Ubuntu 24.04

# --- Переменные ---
# Пользователь должен будет ввести свои данные
read -p "Введите ваше доменное имя (например, example.com): " DOMAIN
read -p "Введите субдомен для 3x-ui (например, 3xui): " SUBDOMAIN_3XUI
read -p "Введите субдомен для AdGuard Home (например, adguard): " SUBDOMAIN_ADGUARD
read -p "Введите субдомен для Lampa (например, lampa): " SUBDOMAIN_LAMPA
read -p "Введите ваш email для регистрации SSL-сертификатов Let's Encrypt: " EMAIL

# --- Обновление системы ---
echo "Обновление системы..."
sudo apt update && sudo apt upgrade -y

# --- Установка необходимых пакетов ---
echo "Установка Nginx, Certbot и других зависимостей..."
sudo apt install -y nginx certbot python3-certbot-nginx curl wget unzip

# --- Установка 3x-ui ---
echo "Установка 3x-ui..."
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

# --- Установка AdGuard Home ---
echo "Установка AdGuard Home..."
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

# --- Настройка Nginx и SSL ---
echo "Настройка Nginx и получение SSL-сертификатов..."

# Конфигурация для 3x-ui
sudo tee /etc/nginx/sites-available/$SUBDOMAIN_3XUI.$DOMAIN > /dev/null <<EOF
server {
    listen 80;
    server_name $SUBDOMAIN_3XUI.$DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:2053; # Порт по умолчанию для 3x-ui, может измениться при установке
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

# Конфигурация для AdGuard Home
sudo tee /etc/nginx/sites-available/$SUBDOMAIN_ADGUARD.$DOMAIN > /dev/null <<EOF
server {
    listen 80;
    server_name $SUBDOMAIN_ADGUARD.$DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:3000; # Порт для начальной настройки AdGuard
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

# Конфигурация для Lampa
sudo tee /etc/nginx/sites-available/$SUBDOMAIN_LAMPA.$DOMAIN > /dev/null <<EOF
server {
    listen 80;
    server_name $SUBDOMAIN_LAMPA.$DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:8090; # Порт по умолчанию для Lampac
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host \$host;
    }
}
EOF

# Создание символических ссылок
sudo ln -s /etc/nginx/sites-available/$SUBDOMAIN_3XUI.$DOMAIN /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/$SUBDOMAIN_ADGUARD.$DOMAIN /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/$SUBDOMAIN_LAMPA.$DOMAIN /etc/nginx/sites-enabled/

# Получение SSL-сертификатов
sudo certbot --nginx -d $SUBDOMAIN_3XUI.$DOMAIN -d $SUBDOMAIN_ADGUARD.$DOMAIN -d $SUBDOMAIN_LAMPA.$DOMAIN --email $EMAIL --agree-tos --no-eff-email -n

# Перезапуск Nginx
sudo systemctl restart nginx

# --- Завершение ---
echo "================================================================="
echo "Установка завершена!"
echo ""
echo "Адреса для доступа к сервисам:"
echo "3x-ui: https://$SUBDOMAIN_3XUI.$DOMAIN"
echo "AdGuard Home: https://$SUBDOMAIN_ADGUARD.$DOMAIN"
echo "Lampa: https://$SUBDOMAIN_LAMPA.$DOMAIN"
echo ""
echo "ВАЖНО: Дальнейшая настройка производится через веб-интерфейсы."
echo "================================================================="
