#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Ошибка: Скрипт должен быть запущен с правами root${NC}"
    exit 1
fi

echo -e "${YELLOW}Начало установки Bing Auto Search...${NC}"

# Обновление системы
echo -e "${GREEN}Обновление системы...${NC}"
apt update && apt upgrade -y

# Установка необходимых пакетов
echo -e "${GREEN}Установка необходимых пакетов...${NC}"
apt install -y nginx git curl certbot python3-certbot-nginx

# Создание директории для проекта
echo -e "${GREEN}Создание директории для проекта...${NC}"
mkdir -p /var/www/bing_autosearch
cd /var/www/bing_autosearch

# Клонирование репозитория
echo -e "${GREEN}Клонирование репозитория...${NC}"
git clone https://github.com/Stulovo1/MS_Rew.git .

# Настройка прав доступа
echo -e "${GREEN}Настройка прав доступа...${NC}"
chown -R www-data:www-data /var/www/bing_autosearch
chmod -R 755 /var/www/bing_autosearch

# Настройка Nginx
echo -e "${GREEN}Настройка Nginx...${NC}"
cat > /etc/nginx/sites-available/bing_autosearch << EOF
server {
    listen 80;
    server_name _;
    root /var/www/bing_autosearch;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }
}
EOF

# Активация конфигурации
ln -sf /etc/nginx/sites-available/bing_autosearch /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Перезапуск Nginx
echo -e "${GREEN}Перезапуск Nginx...${NC}"
systemctl restart nginx

# Настройка SSL (опционально)
read -p "Хотите настроить SSL через Let's Encrypt? (y/n): " ssl_choice
if [ "$ssl_choice" = "y" ]; then
    read -p "Введите доменное имя: " domain_name
    certbot --nginx -d $domain_name
fi

# Настройка автоматического обновления сертификатов
if [ "$ssl_choice" = "y" ]; then
    echo "0 0 1 * * certbot renew --quiet" | crontab -
fi

echo -e "${GREEN}Установка завершена!${NC}"
echo -e "${YELLOW}Доступ к приложению:${NC}"
if [ "$ssl_choice" = "y" ]; then
    echo -e "https://$domain_name"
else
    echo -e "http://$(hostname -I | awk '{print $1}')"
fi 