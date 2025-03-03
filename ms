import time
import json
import logging
import os
import pickle
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import NoSuchElementException, TimeoutException
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from clarifai_grpc.channel.clarifai_channel import ClarifaiChannel
from clarifai_grpc.grpc.api import resources_pb2, service_pb2, service_pb2_grpc
from clarifai_grpc.grpc.api.status import status_code_pb2

# Настройки
ACCOUNTS_FILE = "accounts.json"
LOG_FILE = "microsoft_rewards.log"
COOKIES_FILE = "cookies.pkl"
BING_URL = "https://www.bing.com"
REWARDS_URL = "https://rewards.microsoft.com"
CLARIFAI_API_KEY = "your_clarifai_api_key"  # Замени на свой API-ключ

# Настройка логирования
logging.basicConfig(filename=LOG_FILE, level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# Инициализация Clarifai
channel = ClarifaiChannel.get_grpc_channel()
stub = service_pb2_grpc.V2Stub(channel)
metadata = (("authorization", f"Key {CLARIFAI_API_KEY}"),)

def load_accounts():
    """Загружает аккаунты из JSON-файла."""
    with open(ACCOUNTS_FILE, "r") as file:
        return json.load(file)

def save_cookies(driver, username):
    """Сохраняет cookies в файл."""
    cookies = driver.get_cookies()
    with open(f"{username}_cookies.pkl", "wb") as file:
        pickle.dump(cookies, file)

def load_cookies(driver, username):
    """Загружает cookies из файла."""
    try:
        with open(f"{username}_cookies.pkl", "rb") as file:
            cookies = pickle.load(file)
            for cookie in cookies:
                driver.add_cookie(cookie)
        return True
    except FileNotFoundError:
        return False

def login(driver, username, password):
    """Авторизация в Microsoft."""
    try:
        driver.get("https://login.live.com")
        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.NAME, "loginfmt"))).send_keys(username)
        driver.find_element(By.ID, "idSIButton9").click()
        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.NAME, "passwd"))).send_keys(password)
        driver.find_element(By.ID, "idSIButton9").click()
        time.sleep(5)
        save_cookies(driver, username)
    except Exception as e:
        logging.error(f"Ошибка при авторизации: {e}")

def perform_searches(driver, queries):
    """Выполняет поисковые запросы в Bing."""
    try:
        for query in queries:
            driver.get(BING_URL)
            WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.NAME, "q"))).send_keys(query)
            driver.find_element(By.NAME, "q").send_keys(Keys.RETURN)
            time.sleep(2)
    except Exception as e:
        logging.error(f"Ошибка при выполнении поиска: {e}")

def complete_daily_tasks(driver):
    """Выполняет ежедневные задания."""
    try:
        driver.get(REWARDS_URL)
        time.sleep(5)

        # Обработка заданий
        tasks = driver.find_elements(By.CSS_SELECTOR, ".task-card")
        for task in tasks:
            try:
                title = task.find_element(By.CSS_SELECTOR, ".title").text
                logging.info(f"Найдено задание: {title}")

                # Проверка типа задания
                if "опрос" in title.lower() or "quiz" in title.lower():
                    handle_quiz(task)
                elif "клик" in title.lower() or "click" in title.lower():
                    handle_click_task(task)
                elif "изображение" in title.lower() or "image" in title.lower():
                    handle_image_task(task)
                else:
                    logging.warning(f"Неизвестный тип задания: {title}")
            except Exception as e:
                logging.error(f"Ошибка при обработке задания: {e}")
    except Exception as e:
        logging.error(f"Ошибка при выполнении заданий: {e}")

def handle_quiz(task):
    """Обрабатывает опросы и тесты."""
    try:
        task.click()
        time.sleep(2)

        # Пример: Выбор первого варианта ответа
        options = task.find_elements(By.CSS_SELECTOR, ".option")
        if options:
            options[0].click()
            logging.info("Выбран первый вариант ответа.")
        else:
            logging.warning("Варианты ответа не найдены.")
    except Exception as e:
        logging.error(f"Ошибка при обработке опроса: {e}")

def handle_click_task(task):
    """Обрабатывает задания, требующие клика."""
    try:
        task.click()
        logging.info("Задание выполнено (клик).")
    except Exception as e:
        logging.error(f"Ошибка при выполнении задания (клик): {e}")

def handle_image_task(task):
    """Обрабатывает задания с изображениями с помощью Clarifai."""
    try:
        task.click()
        time.sleep(2)

        # Получаем URL изображения
        image_url = task.find_element(By.CSS_SELECTOR, "img").get_attribute("src")
        logging.info(f"URL изображения: {image_url}")

        # Анализ изображения с помощью Clarifai
        response = stub.PostModelOutputs(
            service_pb2.PostModelOutputsRequest(
                model_id="general-image-recognition",
                inputs=[
                    resources_pb2.Input(
                        data=resources_pb2.Data(image=resources_pb2.Image(url=image_url))
                ]
            ),
            metadata=metadata
        )

        if response.status.code != status_code_pb2.SUCCESS:
            logging.error(f"Ошибка Clarifai: {response.status.description}")
            return

        # Вывод результатов анализа
        for concept in response.outputs[0].data.concepts:
            logging.info(f"{concept.name}: {concept.value:.2f}")

        # Пример: Выбор первого варианта ответа
        options = task.find_elements(By.CSS_SELECTOR, ".option")
        if options:
            options[0].click()
            logging.info("Выбран первый вариант ответа.")
    except Exception as e:
        logging.error(f"Ошибка при обработке задания с изображением: {e}")

def main_menu():
    """Меню для выбора функций."""
    print("1. Выполнить поисковые запросы")
    print("2. Выполнить ежедневные задания")
    print("3. Выход")
    choice = input("Выберите действие: ")
    return choice

def main():
    """Основная функция."""
    accounts = load_accounts()
    queries = ["Microsoft Rewards", "Python", "Selenium", "AI", "Machine Learning", "OpenAI"]

    for account in accounts:
        try:
            # Настройка Chrome
            options = Options()
            options.add_argument("--headless")
            options.add_argument("--disable-gpu")
            options.add_argument("--no-sandbox")
            driver = webdriver.Chrome(options=options)

            # Загрузка cookies
            if not load_cookies(driver, account["username"]):
                login(driver, account["username"], account["password"])

            while True:
                choice = main_menu()
                if choice == "1":
                    perform_searches(driver, queries)
                elif choice == "2":
                    complete_daily_tasks(driver)
                elif choice == "3":
                    break
                else:
                    print("Неверный выбор.")

            # Закрытие браузера
            driver.quit()
            logging.info(f"Аккаунт {account['username']} обработан успешно.")
        except Exception as e:
            logging.error(f"Ошибка при обработке аккаунта {account['username']}: {e}")

if __name__ == "__main__":
    main()
