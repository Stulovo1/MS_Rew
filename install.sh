#!/bin/bash

# ====================================================================================
#              ЗОЛОТОЙ ФИНАЛЬНЫЙ СКРИПТ УСТАНОВКИ v1.0
# ====================================================================================
# Репозиторий: https://github.com/Stulovo1/MS_Rew
# ОС: Ubuntu 20.04
# Включает: AdGuard, Lampa, x-ui (англ.) с полной автоматической настройкой и всеми исправлениями.

echo "--- Начало установки мультисервисного сервера. Этот скрипт делает ВСЁ. ---"

# --- ШАГ 1: Обновление системы и установка базовых пакетов ---
echo "--> [1/6] Обновление системы и установка зависимостей (nginx, ufw, curl...)"
sudo apt-get update > /dev/null 2>&1
sudo apt-get install -y curl wget unzip ufw nginx > /dev/null 2>&1

# --- ШАГ 2: Установка и ПОЛНОЕ ИСПРАВЛЕНИЕ Lampa ---
echo "--> [2/6] Установка Lampa..."
sudo apt-get install -y libnss3-dev libgdk-pixbuf2.0-dev libgtk-3-dev libxss-dev libasound2 xvfb coreutils > /dev/null 2>&1
curl -L -k -o dotnet-install.sh https://dot.net/v1/dotnet-install.sh
sudo chmod +x dotnet-install.sh
sudo ./dotnet-install.sh --channel 6.0 --runtime aspnetcore --install-dir /usr/share/dotnet > /dev/null 2>&1
sudo ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
rm dotnet-install.sh

DEST="/home/lampac"
sudo mkdir -p $DEST
cd $DEST
sudo curl -L -k -o publish.zip https://github.com/immisterio/Lampac/releases/latest/download/publish.zip > /dev/null 2>&1
sudo unzip -o publish.zip > /dev/null 2>&1
sudo rm -f publish.zip
cd ~

echo "--> [2/6] Применение исправления №1: Замена конфига Lampa на рабочий..."
sudo tee /home/lampac/appsettings.json > /dev/null <<'EOF'
{
  "Kestrel": { "EndPoints": { "Http": { "Url": "http://0.0.0.0:8090" } } }, "AllowedHosts": "*"
}
EOF

echo "--> [2/6] Применение исправления №2: Настройка прав доступа для Lampa..."
sudo tee /etc/systemd/system/lampac.service > /dev/null <<EOF
[Unit]
Description=Lampac
Wants=network.target
After=network.target
[Service]
WorkingDirectory=$DEST
ExecStart=/usr/bin/dotnet Lampac.dll
Restart=always
User=www-data
LimitNOFILE=32000
[Install]
WantedBy=multi-user.target
EOF
sudo chown -R www-data:www-data /home/lampac
sudo systemctl daemon-reload
sudo systemctl restart lampac.service

# --- ШАГ 3: Установка AdGuard Home ---
echo "--> [3/6] Установка AdGuard Home в фоновом режиме..."
wget --no-verbose -O - https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sudo sh -s -- -v > /dev/null 2>&1

# --- ШАГ 4: Установка англоязычной панели x-ui ---
echo "--> [4/6] Установка англоязычной панели x-ui."
echo "!!! ВНИМАНИЕ: СЛЕДУЮЩИЙ ШАГ ТРЕБУЕТ ВАШЕГО УЧАСТИЯ !!!"
echo "Вам нужно будет ввести логин, пароль и порт (используйте 2053)."
bash <(curl -Ls https://raw.githubusercontent.com/alireza0/x-ui/master/install.sh)

# --- ШАГ 5: Финальная, самая надежная настройка Nginx ---
echo "--> [5/6] Получение секретного пути x-ui для настройки Nginx..."
BASE_PATH=$(sudo x-ui settings | grep 'WebBasePath' | awk '{print $3}')
if [ -z "$BASE_PATH" ]; then
    echo "!!! ОШИБКА: Не удалось автоматически определить WebBasePath. Настройка Nginx пропущена. !!!"
else
    echo "--> Секретный путь найден. Настройка Nginx с полным исправлением ссылок..."
    sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    # Маршрут для AdGuard с исправлением всех ссылок
    location /adguard/ {
        proxy_pass http://127.0.0.1:3000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_redirect / /adguard/;
        sub_filter_once off;
        sub_filter 'action="/' 'action="/adguard/';
        sub_filter 'href="/' 'href="/adguard/';
        sub_filter 'src="/' 'src="/adguard/';
    }

    # Маршрут для Lampa с исправлением всех ссылок
    location /lampa/ {
        proxy_pass http://127.0.0.1:8090/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_redirect / /lampa/;
        sub_filter_once off;
        sub_filter 'href="/' 'href="/lampa/';
        sub_filter 'src="/' 'src="/lampa/';
    }

    # Маршрут по умолчанию для X-UI с учетом секретного пути
    location / {
        proxy_pass http://127.0.0.1:2053${BASE_PATH};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF
    sudo systemctl restart nginx
fi

# --- ШАГ 6: Настройка брандмауэра ---
echo "--> [6/6] Настройка брандмауэра (UFW)."
sudo ufw allow ssh > /dev/null 2>&1
sudo ufw allow 80/tcp > /dev/null 2>&1
sudo ufw --force enable

# --- Завершение ---
echo ""
echo "================================================================="
echo "       УСТАНОВКА ПОЛНОСТЬЮ ЗАВЕРШЕНА!       "
echo "================================================================="
echo ""
echo "Адреса для доступа к сервисам:"
echo "Панель x-ui:  http://185.217.199.157/"
echo "AdGuard Home: http://185.217.199.157/adguard/"
echo "Lampa:        http://185.217.199.157/lampa/"
echo ""
echo "--- ВАЖНЫЕ ДАЛЬНЕЙШИЕ ШАГИ ---"
echo "1. AdGuard: При первом входе пройдите мастер настройки."
echo "2. Lampa: В настройках Lampa вручную добавьте IPTV плейлист:"
echo "   http://m3u.uztv.su/57/moskov.m3u8"
echo "3. x-ui: Настройте VLESS Reality и правила маршрутизации для РФ."
echo ""
echo "================================================================="
