#!/bin/bash

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
    echo "Установка на Debian/Ubuntu..."
    
    # Обновление системы
    apt update
    apt upgrade -y
    
    # Установка необходимых пакетов
    apt install -y nginx apache2-utils certbot python3-certbot-nginx fail2ban
    
    # Создание директории
    mkdir -p /var/www/bing_autosearch
    
    # Копирование файлов
    cp -r ./* /var/www/bing_autosearch/
    
    # Настройка прав доступа
    chown -R www-data:www-data /var/www/bing_autosearch
    chmod -R 755 /var/www/bing_autosearch
    
    # Настройка Nginx
    cat > /etc/nginx/conf.d/bing_autosearch.conf << 'EOL'
server {
    listen 80;
    server_name _;

    root /var/www/bing_autosearch;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location /js/ {
        alias /var/www/bing_autosearch/js/;
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }
}
EOL
    
    # Проверка и перезапуск Nginx
    nginx -t
    systemctl restart nginx
    
    # Настройка файрвола
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
    
    echo "Установка завершена!"
}

# Функция для установки на CentOS/RHEL
install_centos() {
    echo "Установка на CentOS/RHEL..."
    
    # Обновление системы
    yum update -y
    
    # Установка необходимых пакетов
    yum install -y nginx certbot python3-certbot-nginx fail2ban
    
    # Создание директории
    mkdir -p /var/www/bing_autosearch
    
    # Копирование файлов
    cp -r ./* /var/www/bing_autosearch/
    
    # Настройка прав доступа
    chown -R nginx:nginx /var/www/bing_autosearch
    chmod -R 755 /var/www/bing_autosearch
    
    # Настройка Nginx
    cat > /etc/nginx/conf.d/bing_autosearch.conf << 'EOL'
server {
    listen 80;
    server_name _;

    root /var/www/bing_autosearch;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location /js/ {
        alias /var/www/bing_autosearch/js/;
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }
}
EOL
    
    # Проверка и перезапуск Nginx
    nginx -t
    systemctl restart nginx
    
    # Настройка файрвола
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
    
    echo "Установка завершена!"
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

echo "Установка завершена успешно!"
echo "Для просмотра подробных инструкций по использованию, откройте файл INSTALL.md" 