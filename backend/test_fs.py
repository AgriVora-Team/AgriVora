from app.utils.firestore import save_scan_history, get_scan_history

# Save a test scan record
res = save_scan_history({"userId": "test_user_jk", "crop": "Peas", "confidence": 0.99})
print("save result:", res)

# Retrieve scan history for the user
print("get result:", get_scan_history("test_user_jk"))
