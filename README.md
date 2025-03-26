# ChatGPT-4o Streamlit Web-приложение

Интерактивное веб-приложение на основе Streamlit для общения с моделью OpenAI GPT-4o.

## Содержание

- [Описание](#описание)
- [Структура проекта](#структура-проекта)
- [Установка и запуск](#установка-и-запуск)
  - [Локальная установка](#локальная-установка)
  - [Развертывание на VPS](#развертывание-на-vps)
- [Конфигурация](#конфигурация)
- [Использование](#использование)
- [Требования](#требования)
- [Устранение неполадок](#устранение-неполадок)

## Описание

Это приложение представляет собой простой веб-интерфейс для общения с языковой моделью GPT-4o от OpenAI. Приложение позволяет вести диалог с ИИ, отправлять сообщения и получать ответы в режиме реального времени.

## Структура проекта

```
chatgpt4o/
├── app.py             # Основной файл приложения
├── requirements.txt   # Зависимости Python
├── .env               # Переменные окружения (API-ключи)
├── .env.example       # Пример файла с переменными окружения
├── setup.sh           # Скрипт для развертывания на VPS
└── README.md          # Документация (этот файл)
```

## Установка и запуск

### Локальная установка

1. **Клонирование репозитория:**
   ```bash
   git clone <репозиторий> chatgpt4o
   cd chatgpt4o
   ```

2. **Создание виртуального окружения:**
   ```bash
   # Windows
   python -m venv venv
   venv\Scripts\activate

   # Linux/macOS
   python3 -m venv venv
   source venv/bin/activate
   ```

3. **Установка зависимостей:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Настройка API-ключа:**
   Создайте файл `.env` на основе `.env.example`:
   ```bash
   cp .env.example .env
   ```
   Откройте `.env` и вставьте ваш API-ключ OpenAI:
   ```
   OPENAI_API_KEY=your_api_key_here
   ```

5. **Запуск приложения:**
   ```bash
   streamlit run app.py
   ```
   Приложение будет доступно по адресу: http://localhost:8501

### Развертывание на VPS

1. **Загрузите файлы проекта на ваш VPS:**
   ```bash
   # Создайте директорию для проекта
   mkdir -p ~/chatgpt4o
   cd ~/chatgpt4o

   # Загрузите все файлы проекта в эту директорию
   ```

2. **Создайте файл `.env` с вашим API-ключом OpenAI:**
   ```bash
   echo "OPENAI_API_KEY=your_api_key_here" > .env
   ```

3. **Сделайте скрипт установки исполняемым:**
   ```bash
   chmod +x setup.sh
   ```

4. **Запустите скрипт установки:**
   ```bash
   ./setup.sh
   ```

5. **Настройка Nginx:**
   После запуска скрипта отредактируйте файл конфигурации Nginx:
   ```bash
   sudo nano /etc/nginx/sites-available/chatgpt4o
   ```
   
   Замените `YOUR_DOMAIN_OR_IP` на ваш домен или IP-адрес VPS.
   
   Перезагрузите конфигурацию Nginx:
   ```bash
   sudo systemctl reload nginx
   ```

6. **Проверка доступности:**
   Ваше приложение будет доступно по адресу:
   ```
   http://your_domain_or_ip/chatgpt4o/
   ```

## Конфигурация

### Переменные окружения

- `OPENAI_API_KEY`: API-ключ OpenAI (обязательный)

### Настройки Streamlit

Вы можете настроить Streamlit, создав файл `.streamlit/config.toml`:
```toml
[server]
port = 8501
```

## Использование

1. Откройте приложение в браузере
2. Введите сообщение в поле внизу страницы
3. Нажмите Enter или кнопку отправки
4. Получите ответ от GPT-4o

## Требования

- Python 3.8+
- streamlit==1.44.0
- openai==1.68.2
- python-dotenv==1.1.0
- Доступ к API OpenAI с активным платежным методом

## Устранение неполадок

### Проблемы с API-ключом
- Убедитесь, что ключ API корректный и активен
- Проверьте баланс в аккаунте OpenAI

### Проблемы с запуском на VPS
- Проверьте логи systemd:
  ```bash
  sudo journalctl -u chatgpt4o.service
  ```
- Проверьте статус сервиса:
  ```bash
  sudo systemctl status chatgpt4o.service
  ```
- Проверьте конфигурацию Nginx:
  ```bash
  sudo nginx -t
  ```

### Проблемы с доступом к приложению
- Убедитесь, что порт 80 открыт в брандмауэре:
  ```bash
  sudo ufw allow 80/tcp
  ```
- Проверьте, работает ли Nginx:
  ```bash
  sudo systemctl status nginx
  ```

---

© 2025 ChatGPT-4o Streamlit App