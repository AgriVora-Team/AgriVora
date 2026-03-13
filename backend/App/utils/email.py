from datetime import datetime
from google.cloud import firestore
from google.oauth2 import service_account

cred = service_account.Credentials.from_service_account_file(
    "firebase-key.json"
)

db = firestore.Client(credentials=cred)


def get_current_time():
    return datetime.utcnow()


def save_scan_history(data: dict):
    try:
        data["createdAt"] = get_current_time()
        db.collection("scan_history").add(data)
        print("Scan saved to Firestore")
        return True
    except Exception as e:
        print("Firestore error:", e)
        return False


def get_scan_history(user_id: str):
    try:
        docs = (
            db.collection("scan_history")
            .where("userId", "==", user_id)
            .stream()
        )

        results = []
        for doc in docs:
            item = doc.to_dict()
            item["id"] = doc.id
            results.append(item)

        def get_sort_key(x):
            ts = x.get("createdAt")
            if ts is None:
                return "1970"
            try:
                return ts.isoformat()
            except:
                return str(ts)

        results.sort(key=get_sort_key, reverse=True)
        return results

    except Exception as e:
        print("Firestore fetch error:", e)
        return []