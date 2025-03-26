import streamlit as st
from openai import OpenAI
import os
from dotenv import load_dotenv

# Загрузка переменных окружения из .env файла
load_dotenv()

# Загрузка API-ключа из переменных окружения
api_key = os.getenv("OPENAI_API_KEY")

# Проверка, загружен ли API-ключ
if not api_key:
    st.error("❌ Ошибка: API-ключ OpenAI не найден! Проверьте файл .env")
    st.stop()

# Инициализация клиента OpenAI
client = OpenAI(api_key=api_key)

# Инициализация состояния сессии
if "messages" not in st.session_state:
    st.session_state.messages = []

# Заголовок приложения
st.title("Чатик с ChatGPT-4o")

# Определение стиля для линии
line_style = """
    <style>
        .divider {
            border: none;
            height: 1px;
            background-color: rgba(0, 0, 0, 0.1);
            margin: 10px 0;
        }
    </style>
"""
st.markdown(line_style, unsafe_allow_html=True)

# Отображение истории сообщений
for msg in st.session_state.messages:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])
    if msg["role"] == "assistant":
        st.markdown('<div class="divider"></div>', unsafe_allow_html=True)

# Поле ввода сообщения
if prompt := st.chat_input("Введите ваше сообщение:"):
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # Получение ответа от модели OpenAI
    try:
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=st.session_state.messages,
            temperature=0.5,
            max_tokens=4000,
        )
        assistant_reply = response.choices[0].message.content
        st.session_state.messages.append({"role": "assistant", "content": assistant_reply})
        with st.chat_message("assistant"):
            st.markdown(assistant_reply)
        st.markdown('<div class="divider"></div>', unsafe_allow_html=True)
    except Exception as e:
        st.error(f"Произошла ошибка при обращении к API: {e}")