#!/bin/bash

# Название скрипта
SCRIPT_NAME="Gimnazist"
VERSION="1.0.0"

# Проверка на root права
if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами root"
    exit 1
fi

# Определение дистрибутива
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VERSION=$VERSION_ID
fi

# Функция для установки на Debian/Ubuntu
install_debian() {
    echo "Установка $SCRIPT_NAME на Debian/Ubuntu..."
    
    # Обновление системы
    apt update
    apt upgrade -y
    
    # Установка необходимых пакетов
    apt install -y nginx apache2-utils certbot python3-certbot-nginx fail2ban ufw
    
    # Создание директории
    mkdir -p /var/www/gimnazist
    
    # Копирование файлов
    cp -r ./* /var/www/gimnazist/
    
    # Настройка прав доступа
    chown -R www-data:www-data /var/www/gimnazist
    chmod -R 755 /var/www/gimnazist
    
    # Настройка Nginx
    cat > /etc/nginx/conf.d/gimnazist.conf << 'EOL'
server {
    listen 80;
    server_name _;

    root /var/www/gimnazist;
    index index.html;

    # Базовые настройки безопасности
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";
    add_header Referrer-Policy "strict-origin-when-cross-origin";

    # Настройки для статических файлов
    location / {
        try_files $uri $uri/ /index.html;
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }

    location /js/ {
        alias /var/www/gimnazist/js/;
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }

    # Запрет доступа к скрытым файлам
    location ~ /\. {
        deny all;
    }

    # Запрет доступа к файлам конфигурации
    location ~* \.(conf|config|ini|log|sh|sql)$ {
        deny all;
    }

    # Настройки для обработки ошибок
    error_page 404 /index.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
EOL
    
    # Перезапуск Nginx с проверкой конфигурации
    nginx -t && systemctl restart nginx
    
    # Настройка файрвола
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
    
    # Настройка fail2ban
    cat > /etc/fail2ban/jail.d/gimnazist.conf << 'EOL'
[gimnazist]
enabled = true
port = http,https
filter = gimnazist
logpath = /var/log/nginx/access.log
maxretry = 3
bantime = 3600
EOL
    
    systemctl restart fail2ban
    
    echo "Установка $SCRIPT_NAME завершена!"
}

# Функция для установки на CentOS/RHEL
install_centos() {
    echo "Установка $SCRIPT_NAME на CentOS/RHEL..."
    
    # Обновление системы
    yum update -y
    
    # Установка необходимых пакетов
    yum install -y nginx certbot python3-certbot-nginx fail2ban firewalld
    
    # Создание директории
    mkdir -p /var/www/gimnazist
    
    # Копирование файлов
    cp -r ./* /var/www/gimnazist/
    
    # Настройка прав доступа
    chown -R nginx:nginx /var/www/gimnazist
    chmod -R 755 /var/www/gimnazist
    
    # Настройка Nginx
    cat > /etc/nginx/conf.d/gimnazist.conf << 'EOL'
server {
    listen 80;
    server_name _;

    root /var/www/gimnazist;
    index index.html;

    # Базовые настройки безопасности
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";
    add_header Referrer-Policy "strict-origin-when-cross-origin";

    # Настройки для статических файлов
    location / {
        try_files $uri $uri/ /index.html;
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }

    location /js/ {
        alias /var/www/gimnazist/js/;
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }

    # Запрет доступа к скрытым файлам
    location ~ /\. {
        deny all;
    }

    # Запрет доступа к файлам конфигурации
    location ~* \.(conf|config|ini|log|sh|sql)$ {
        deny all;
    }

    # Настройки для обработки ошибок
    error_page 404 /index.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
EOL
    
    # Перезапуск Nginx с проверкой конфигурации
    nginx -t && systemctl restart nginx
    
    # Настройка файрвола
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
    
    # Настройка fail2ban
    cat > /etc/fail2ban/jail.d/gimnazist.conf << 'EOL'
[gimnazist]
enabled = true
port = http,https
filter = gimnazist
logpath = /var/log/nginx/access.log
maxretry = 3
bantime = 3600
EOL
    
    systemctl restart fail2ban
    
    echo "Установка $SCRIPT_NAME завершена!"
}

# Основная логика установки
echo "Определение операционной системы..."
if [[ $OS == *"Debian"* ]] || [[ $OS == *"Ubuntu"* ]]; then
    install_debian
elif [[ $OS == *"CentOS"* ]] || [[ $OS == *"Red Hat"* ]]; then
    install_centos
else
    echo "Неподдерживаемая операционная система"
    exit 1
fi

# Запрос домена для SSL
read -p "Введите ваш домен (например, example.com): " domain
if [ ! -z "$domain" ]; then
    echo "Настройка SSL для домена $domain..."
    certbot --nginx -d $domain
fi

# Создание файла версии
echo "VERSION=$VERSION" > /var/www/gimnazist/version.txt

echo "Установка $SCRIPT_NAME версии $VERSION завершена успешно!"
echo "Для просмотра подробных инструкций по использованию, откройте файл HELP.md" 