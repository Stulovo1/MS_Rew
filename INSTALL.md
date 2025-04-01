# Инструкция по установке Bing Auto Search на Linux-серверах

## Содержание
1. [Требования](#требования)
2. [Установка на Debian/Ubuntu](#установка-на-debianubuntu)
3. [Установка на CentOS/RHEL](#установка-на-centosrhel)
4. [Настройка веб-сервера](#настройка-веб-сервера)
5. [Настройка SSL](#настройка-ssl)
6. [Управление скриптом](#управление-скриптом)
7. [Возможности программы](#возможности-программы)
8. [Безопасность](#безопасность)
9. [Устранение неполадок](#устранение-неполадок)

## Требования

### Минимальные требования:
- Linux-сервер (Debian/Ubuntu или CentOS/RHEL)
- 1 ГБ RAM
- 10 ГБ свободного места
- Статический IP-адрес или домен
- Доступ к интернету

### Рекомендуемые требования:
- 2+ ГБ RAM
- 20+ ГБ свободного места
- SSL-сертификат
- Защищенный файрвол

## Установка на Debian/Ubuntu

1. Обновление системы:
```bash
sudo apt update
sudo apt upgrade -y
```

2. Установка необходимых пакетов:
```bash
sudo apt install -y nginx apache2-utils certbot python3-certbot-nginx
```

3. Создание директории для скрипта:
```bash
sudo mkdir -p /var/www/bing_autosearch
```

4. Копирование файлов:
```bash
sudo cp -r bing_autosearch-master/* /var/www/bing_autosearch/
```

5. Настройка прав доступа:
```bash
sudo chown -R www-data:www-data /var/www/bing_autosearch
sudo chmod -R 755 /var/www/bing_autosearch
```

## Установка на CentOS/RHEL

1. Обновление системы:
```bash
sudo yum update -y
```

2. Установка необходимых пакетов:
```bash
sudo yum install -y nginx certbot python3-certbot-nginx
```

3. Создание директории для скрипта:
```bash
sudo mkdir -p /var/www/bing_autosearch
```

4. Копирование файлов:
```bash
sudo cp -r bing_autosearch-master/* /var/www/bing_autosearch/
```

5. Настройка прав доступа:
```bash
sudo chown -R nginx:nginx /var/www/bing_autosearch
sudo chmod -R 755 /var/www/bing_autosearch
```

## Настройка веб-сервера

### Nginx (рекомендуется)

1. Создание конфигурационного файла:
```bash
sudo nano /etc/nginx/conf.d/bing_autosearch.conf
```

2. Добавление конфигурации:
```nginx
server {
    listen 80;
    server_name your_domain.com;

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
```

3. Проверка конфигурации:
```bash
sudo nginx -t
```

4. Перезапуск Nginx:
```bash
sudo systemctl restart nginx
```

### Apache

1. Создание конфигурационного файла:
```bash
sudo nano /etc/apache2/sites-available/bing_autosearch.conf
```

2. Добавление конфигурации:
```apache
<VirtualHost *:80>
    ServerName your_domain.com
    DocumentRoot /var/www/bing_autosearch

    <Directory /var/www/bing_autosearch>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/bing_autosearch_error.log
    CustomLog ${APACHE_LOG_DIR}/bing_autosearch_access.log combined
</VirtualHost>
```

3. Активация сайта:
```bash
sudo a2ensite bing_autosearch
sudo systemctl restart apache2
```

## Настройка SSL

1. Получение SSL-сертификата:
```bash
sudo certbot --nginx -d your_domain.com
```

2. Проверка автоматического обновления:
```bash
sudo certbot renew --dry-run
```

## Управление скриптом

### Запуск
```bash
sudo systemctl start nginx  # для Nginx
sudo systemctl start apache2  # для Apache
```

### Остановка
```bash
sudo systemctl stop nginx  # для Nginx
sudo systemctl stop apache2  # для Apache
```

### Перезапуск
```bash
sudo systemctl restart nginx  # для Nginx
sudo systemctl restart apache2  # для Apache
```

### Проверка статуса
```bash
sudo systemctl status nginx  # для Nginx
sudo systemctl status apache2  # для Apache
```

## Возможности программы

### Основные функции:
1. Автоматический поиск в Bing
   - Настраиваемое количество поисков
   - Настраиваемый интервал между поисками
   - Случайный выбор поисковых запросов

2. Режимы работы:
   - Десктопный режим (35 поисков)
   - Мобильный режим (30 поисков)
   - Мультитаб режим

3. Настройки:
   - Сохранение настроек в cookie
   - Настраиваемые интервалы
   - Настраиваемые лимиты поисков

4. Интерфейс:
   - Прогресс-бар
   - Кнопка остановки
   - Настройки в реальном времени

### Дополнительные возможности:
1. Безопасность:
   - HTTPS поддержка
   - Защита от автоматических ботов
   - Безопасное хранение настроек

2. Мониторинг:
   - Логирование действий
   - Отслеживание прогресса
   - Статистика использования

## Безопасность

### Рекомендуемые настройки:
1. Настройка файрвола:
```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

2. Настройка fail2ban:
```bash
sudo apt install fail2ban  # для Debian/Ubuntu
sudo yum install fail2ban  # для CentOS/RHEL
```

3. Регулярное обновление:
```bash
sudo apt update && sudo apt upgrade  # для Debian/Ubuntu
sudo yum update  # для CentOS/RHEL
```

## Устранение неполадок

### Частые проблемы:
1. Ошибка доступа к файлам:
```bash
sudo chown -R www-data:www-data /var/www/bing_autosearch
sudo chmod -R 755 /var/www/bing_autosearch
```

2. Проблемы с SSL:
```bash
sudo certbot renew
```

3. Проблемы с правами доступа:
```bash
sudo chmod -R 755 /var/www/bing_autosearch
sudo chown -R www-data:www-data /var/www/bing_autosearch
```

### Просмотр логов:
```bash
sudo tail -f /var/log/nginx/error.log  # для Nginx
sudo tail -f /var/log/apache2/error.log  # для Apache
``` 