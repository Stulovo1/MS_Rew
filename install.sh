# --- НАЧАЛО ФИНАЛЬНОГО ИСПРАВЛЕНИЯ ---

# ШАГ 1: ИСПРАВЛЕНИЕ LAMPA
echo "--> Исправляем Lampa: возвращаем запуск от имени root..."
# Убираем строку "User=www-data" из файла службы
sudo sed -i '/User=www-data/d' /etc/systemd/system/lampac.service
# Возвращаем владельца папки обратно root
sudo chown -R root:root /home/lampac
# Перечитываем конфиги и перезапускаем Lampa
sudo systemctl daemon-reload
sudo systemctl restart lampac

# ШАГ 2: ИСПРАВЛЕНИЕ NGINX (400 Bad Request)
echo "--> Исправляем Nginx: меняем заголовок Host..."
# Получаем текущий секретный путь, чтобы конфиг был правильным
BASE_PATH=$(sudo x-ui settings | grep 'WebBasePath' | awk '{print $3}')
if [ -z "$BASE_PATH" ]; then
    echo "!!! ОШИБКА: Не удалось определить WebBasePath. Настройка Nginx пропущена. !!!"
else
    # Пересоздаем конфиг Nginx с правильным proxy_set_header
    sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80 default_server; server_name _;
    location /adguard/ {
        proxy_pass http://127.0.0.1:3000/; proxy_set_header Host \$proxy_host; proxy_redirect / /adguard/;
        sub_filter_once off; sub_filter 'action="/' 'action="/adguard/'; sub_filter 'href="/' 'href="/adguard/'; sub_filter 'src="/' 'src="/adguard/';
    }
    location /lampa/ {
        proxy_pass http://127.0.0.1:8090/; proxy_http_version 1.1; proxy_set_header Upgrade \$http_upgrade; proxy_set_header Connection "upgrade"; proxy_set_header Host \$proxy_host; proxy_redirect / /lampa/;
        sub_filter_once off; sub_filter 'href="/' 'href="/lampa/'; sub_filter 'src="/' 'src="/lampa/';
    }
    location / {
        proxy_pass http://127.0.0.1:2053${BASE_PATH}; proxy_set_header Host \$proxy_host;
    }
}
EOF
    # Перезапускаем Nginx
    sudo systemctl restart nginx
fi

echo "--- ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ ЗАВЕРШЕНО ---"
echo "Проверьте статус Lampa и адреса в браузере."
sleep 3
sudo systemctl status lampac

```После выполнения этого скрипта все три сервиса должны заработать корректно.

---

### Шаг 2: "Платиновый" финальный скрипт (v3.0)

Я внес эти последние, самые важные исправления в наш главный скрипт. Теперь он действительно финальный.

```bash
#!/bin/bash
# ====================================================================================
#              ПЛАТИНОВЫЙ ФИНАЛЬНЫЙ СКРИПТ УСТАНОВКИ v3.0
# ====================================================================================
# Учтены все проблемы: права Lampa, заголовок Host в Nginx, автоматизация.

echo "--- Начало установки мультисервисного сервера v3.0 ---"

# --- ШАГ 1: Базовая настройка ---
echo "--> [1/6] Обновление и установка зависимостей..."
sudo apt-get update > /dev/null 2>&1
sudo apt-get install -y curl wget unzip ufw nginx > /dev/null 2>&1

# --- ШАГ 2: Установка и ИСПРАВЛЕНИЕ Lampa ---
echo "--> [2/6] Установка Lampa..."
sudo apt-get install -y libnss3-dev libgdk-pixbuf2.0-dev libgtk-3-dev libxss-dev libasound2 xvfb coreutils > /dev/null 2>&1
curl -L -k -o dotnet-install.sh https://dot.net/v1/dotnet-install.sh
sudo chmod +x dotnet-install.sh && sudo ./dotnet-install.sh --channel 6.0 --runtime aspnetcore --install-dir /usr/share/dotnet > /dev/null 2>&1
sudo ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
rm dotnet-install.sh
DEST="/home/lampac"
sudo mkdir -p $DEST && cd $DEST
sudo curl -L -k -o publish.zip https://github.com/immisterio/Lampac/releases/latest/download/publish.zip > /dev/null 2>&1
sudo unzip -o publish.zip > /dev/null 2>&1 && sudo rm -f publish.zip
cd ~

echo "--> [2/6] Применение исправлений для Lampa (конфиг и запуск от root)..."
sudo tee /home/lampac/appsettings.json > /dev/null <<'EOF'
{ "Kestrel": { "EndPoints": { "Http": { "Url": "http://0.0.0.0:8090" } } }, "AllowedHosts": "*" }
EOF
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
sudo systemctl daemon-reload && sudo systemctl restart lampac.service

# --- ШАГ 3: Установка AdGuard Home ---
echo "--> [3/6] Установка AdGuard Home..."
wget --no-verbose -O - https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sudo sh -s -- -v > /dev/null 2>&1

# --- ШАГ 4: Установка англоязычной панели x-ui ---
echo "--> [4/6] Установка англоязычной панели x-ui..."
echo "!!! ВНИМАНИЕ: СЛЕДУЮЩИЙ ШАГ ТРЕБУЕТ ВАШЕГО УЧАСТИЯ !!!"
bash <(curl -Ls https://raw.githubusercontent.com/alireza0/x-ui/master/install.sh)

# --- ШАГ 5: Финальная, самая надежная настройка Nginx ---
echo "--> [5/6] Автоматическая настройка Nginx (исправлен Host header)..."
sleep 2
BASE_PATH=$(sudo x-ui settings | grep 'WebBasePath' | awk '{print $3}')
if [ -z "$BASE_PATH" ]; then
    echo "!!! ОШИБКА: Не удалось определить WebBasePath. Настройка Nginx пропущена. !!!"
else
    echo "--> Секретный путь найден. Настройка Nginx..."
    sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80 default_server; server_name _;
    location /adguard/ {
        proxy_pass http://127.0.0.1:3000/; proxy_set_header Host \$proxy_host; proxy_redirect / /adguard/;
        sub_filter_once off; sub_filter 'action="/' 'action="/adguard/'; sub_filter 'href="/' 'href="/adguard/'; sub_filter 'src="/' 'src="/adguard/';
    }
    location /lampa/ {
        proxy_pass http://127.0.0.1:8090/; proxy_http_version 1.1; proxy_set_header Upgrade \$http_upgrade; proxy_set_header Connection "upgrade"; proxy_set_header Host \$proxy_host; proxy_redirect / /lampa/;
        sub_filter_once off; sub_filter 'href="/' 'href="/lampa/'; sub_filter 'src="/' 'src="/lampa/';
    }
    location / {
        proxy_pass http://127.0.0.1:2053${BASE_PATH}; proxy_set_header Host \$proxy_host;
    }
}
EOF
    sudo systemctl restart nginx
fi

# --- ШАГ 6: Настройка брандмауэра ---
echo "--> [6/6] Настройка брандмауэра..."
sudo ufw allow ssh > /dev/null 2>&1
sudo ufw allow 80/tcp > /dev/null 2>&1
sudo ufw --force enable

# --- Завершение ---
echo "==================== УСТАНОВКА ЗАВЕРШЕНА ===================="
echo "Панель x-ui:  http://$(curl -s ifconfig.me)/"
echo "AdGuard Home: http://$(curl -s ifconfig.me)/adguard/"
echo "Lampa:        http://$(curl -s ifconfig.me)/lampa/"
echo "==========================================================="
