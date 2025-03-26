#!/bin/bash

# Название вашего приложения (уникальное)
APP_NAME="chatgpt4o"
APP_PORT=8506  # Уникальный порт, чтобы избежать конфликтов

echo "Установка необходимых пакетов Python..."
pip3 install -r requirements.txt

echo "Создание сервиса systemd для автоматического запуска Streamlit..."
cat > ${APP_NAME}.service << EOF
[Unit]
Description=Streamlit ChatGPT-4o App
After=network.target

[Service]
User=$USER
WorkingDirectory=$PWD
ExecStart=$(which streamlit) run app.py --server.port=${APP_PORT}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Проверяем, существует ли уже такой сервис
if [ -f "/etc/systemd/system/${APP_NAME}.service" ]; then
    echo "Сервис ${APP_NAME} уже существует. Останавливаем и удаляем..."
    sudo systemctl stop ${APP_NAME}.service
    sudo systemctl disable ${APP_NAME}.service
    sudo rm /etc/systemd/system/${APP_NAME}.service
fi

sudo mv ${APP_NAME}.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable ${APP_NAME}.service
sudo systemctl start ${APP_NAME}.service

echo "Настройка Nginx для нового приложения..."
# Проверяем наличие Nginx, но не устанавливаем, если его нет
if command -v nginx &> /dev/null; then
    echo "Nginx найден, создаем конфигурацию для нового приложения..."
    
    # Создаем отдельный конфиг для нашего приложения с уникальным именем
    cat > ${APP_NAME}_nginx << EOF
server {
    listen 80;
    server_name YOUR_DOMAIN_OR_IP;
    
    # Указываем путь к нашему приложению
    location /${APP_NAME}/ {
        proxy_pass http://localhost:${APP_PORT}/;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$host;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }
}
EOF

    # Проверяем, существует ли уже файл конфигурации
    if [ -f "/etc/nginx/sites-available/${APP_NAME}" ]; then
        echo "Конфигурация ${APP_NAME} уже существует. Удаляем..."
        sudo rm /etc/nginx/sites-available/${APP_NAME}
        # Если есть символическая ссылка, удаляем и её
        if [ -L "/etc/nginx/sites-enabled/${APP_NAME}" ]; then
            sudo rm /etc/nginx/sites-enabled/${APP_NAME}
        fi
    fi

    # Добавляем новую конфигурацию
    sudo mv ${APP_NAME}_nginx /etc/nginx/sites-available/${APP_NAME}
    sudo ln -s /etc/nginx/sites-available/${APP_NAME} /etc/nginx/sites-enabled/
    
    # Проверяем конфигурацию Nginx
    echo "Проверка конфигурации Nginx..."
    sudo nginx -t
    if [ $? -eq 0 ]; then
        echo "Конфигурация Nginx корректна, применяем изменения..."
        sudo systemctl reload nginx
    else
        echo "ОШИБКА: Конфигурация Nginx содержит ошибки!"
        echo "Откатываем изменения..."
        sudo rm /etc/nginx/sites-enabled/${APP_NAME}
        sudo rm /etc/nginx/sites-available/${APP_NAME}
        echo "Изменения отменены. Пожалуйста, проверьте конфигурацию Nginx вручную."
    fi
else
    echo "Nginx не обнаружен! Настройка Nginx пропущена."
    echo "Ваше приложение доступно только локально по адресу: http://localhost:${APP_PORT}"
    echo "Установите и настройте Nginx вручную, если требуется внешний доступ."
fi

echo ""
echo "====== УСТАНОВКА ЗАВЕРШЕНА ======"
echo "Приложение: ${APP_NAME}"
echo "Порт: ${APP_PORT}"

if command -v nginx &> /dev/null; then
    echo "URL доступа (после настройки DNS): http://YOUR_DOMAIN_OR_IP/${APP_NAME}"
    echo ""
    echo "ВАЖНО: Не забудьте заменить YOUR_DOMAIN_OR_IP в файле /etc/nginx/sites-available/${APP_NAME}"
    echo "После изменения выполните: sudo systemctl reload nginx"
fi

echo ""
echo "Статус сервиса приложения:"
sudo systemctl status ${APP_NAME}.service