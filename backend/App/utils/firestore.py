from datetime import datetime
from google.cloud import firestore
from google.oauth2 import service_account

# Load credentials
cred = service_account.Credentials.from_service_account_file(
    "firebase-key.json"
)

db = firestore.Client(credentials=cred)


# -----------------------------
# SAVE SCAN HISTORY
# -----------------------------
def save_scan_history(data: dict):
    try:
        data["createdAt"] = datetime.utcnow()
        db.collection("scan_history").add(data)
        print("Scan saved to Firestore")
        return True
    except Exception as e:
        print("Firestore error:", e)
        return False


# -----------------------------
# GET SCAN HISTORY BY USER
# -----------------------------
def get_scan_history(user_id: str):
    try:
        docs = (
            db.collection("scan_history")
            .where("userId", "==", user_id)
            .order_by("createdAt", direction=firestore.Query.DESCENDING)
            .stream()
        )

        results = []
        for doc in docs:
            item = doc.to_dict()
            item["id"] = doc.id
            results.append(item)

        return results

    except Exception as e:
        print("Firestore fetch error:", e)
        return []
