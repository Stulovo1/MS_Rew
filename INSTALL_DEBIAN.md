# Установка Gimnazist на Debian 12

## Требования
- Сервер с Debian 12
- Минимум 1 ГБ RAM
- Минимум 10 ГБ свободного места
- Root доступ или sudo права
- Статический IP-адрес или домен

## Автоматическая установка

### 1. Подготовка системы
```bash
# Обновление системы
apt install sudo
sudo apt update
sudo apt upgrade -y

# Установка необходимых пакетов
sudo apt install -y curl wget git
```

### 2. Загрузка скрипта
```bash
# Создание временной директории
mkdir -p /tmp/gimnazist
cd /tmp/gimnazist

# Загрузка скрипта
wget https://github.com/example/gimnazist/archive/refs/heads/master.zip
unzip master.zip
cd gimnazist-master
```

### 3. Запуск установки
```bash
# Сделать скрипт исполняемым
chmod +x install.sh

# Запуск установки
sudo ./install.sh
```

### 4. Настройка SSL (опционально)
```bash
# Если у вас есть домен, введите его при запросе
# Скрипт автоматически настроит SSL через Let's Encrypt
```

## Ручная установка

### 1. Установка зависимостей
```bash
# Установка веб-сервера и необходимых пакетов
sudo apt install -y nginx apache2-utils certbot python3-certbot-nginx fail2ban ufw
```

### 2. Настройка Nginx
```bash
# Создание конфигурации
sudo nano /etc/nginx/conf.d/gimnazist.conf
```

Вставьте следующую конфигурацию:
```nginx
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

    location / {
        try_files $uri $uri/ =404;
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
}
```

### 3. Настройка файрвола
```bash
# Разрешение HTTP и HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable
```

### 4. Настройка fail2ban
```bash
# Создание конфигурации
sudo nano /etc/fail2ban/jail.d/gimnazist.conf
```

Вставьте следующую конфигурацию:
```ini
[gimnazist]
enabled = true
port = http,https
filter = gimnazist
logpath = /var/log/nginx/access.log
maxretry = 3
bantime = 3600
```

### 5. Запуск сервисов
```bash
# Перезапуск Nginx
sudo systemctl restart nginx

# Запуск fail2ban
sudo systemctl restart fail2ban
```

## Проверка установки

### 1. Проверка Nginx
```bash
# Проверка статуса
sudo systemctl status nginx

# Проверка конфигурации
sudo nginx -t
```

### 2. Проверка fail2ban
```bash
# Проверка статуса
sudo systemctl status fail2ban

# Проверка заблокированных IP
sudo fail2ban-client status gimnazist
```

### 3. Проверка файрвола
```bash
# Проверка правил
sudo ufw status
```

## Устранение неполадок

### 1. Проблемы с Nginx
```bash
# Проверка логов
sudo tail -f /var/log/nginx/error.log
```

### 2. Проблемы с fail2ban
```bash
# Проверка логов
sudo tail -f /var/log/fail2ban.log
```

### 3. Проблемы с файрволом
```bash
# Проверка правил
sudo ufw status verbose
```

## Обновление

### 1. Обновление системы
```bash
sudo apt update
sudo apt upgrade -y
```

### 2. Обновление скрипта
```bash
cd /var/www/gimnazist
sudo git pull
```

## Удаление

### 1. Удаление файлов
```bash
sudo rm -rf /var/www/gimnazist
```

### 2. Удаление конфигураций
```bash
sudo rm /etc/nginx/conf.d/gimnazist.conf
sudo rm /etc/fail2ban/jail.d/gimnazist.conf
```

### 3. Перезапуск сервисов
```bash
sudo systemctl restart nginx
sudo systemctl restart fail2ban
``` 
