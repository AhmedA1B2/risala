import base64
import json
import requests

client_id = "e3af92df-f3d7-4d3a-9ccc-152c532492ee"
client_secret = "1tfKz8HWd3w9iyGkBTkv_b~N8t"
token_endpoint = "https://oauth2.quran.foundation/oauth2/token"
reciters_endpoint = "https://apis.quran.foundation/content/api/v4/resources/recitations"


def fetch_access_token():
    auth_string = f"{client_id}:{client_secret}"
    encoded_auth = base64.b64encode(auth_string.encode()).decode()

    headers = {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Basic " + encoded_auth
    }

    data = {
        "grant_type": "client_credentials",
        "scope": "content"
    }

    response = requests.post(token_endpoint, headers=headers, data=data)

    if response.status_code == 200:
        token = response.json()['access_token']
        print("✅ Token:", token)
        return token
    else:
        print("❌ Token Error:", response.text)
        return None


def fetch_reciters_json(token):
    headers = {
        "Accept": "application/json",
        "x-auth-token": token,
        "x-client-id": client_id
    }

    response = requests.get(reciters_endpoint, headers=headers)

    if response.status_code == 200:
        data = response.json()
        print(f"✅ Reciters Count: {len(data)}")

        # تخزين البيانات في ملف JSON
        with open("reciters.json", "w", encoding="utf-8") as file:
            json.dump(data, file, ensure_ascii=False, indent=2)

        print("💾 تم تخزين البيانات في ملف: reciters.json")

    else:
        print("❌ Fetch Error:", response.text)


# تشغيل السكربت
token = fetch_access_token()
if token:
    fetch_reciters_json(token)
