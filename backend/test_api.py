import requests
import time

URL = "http://localhost:8000/sensor/ph/123"
REQUEST_COUNT = 3
DELAY_SECONDS = 2

def fetch_sensor_data():
    try:
        response = requests.get(URL)

        if response.status_code == 200:
            print("Response:", response.json())
        else:
            print("Request failed:", response.status_code)

    except Exception as e:
        print("Error:", e)


for _ in range(REQUEST_COUNT):
    fetch_sensor_data()
    time.sleep(DELAY_SECONDS)