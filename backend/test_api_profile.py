import requests

def test_api():
    url = "http://127.0.0.1:8000/api/auth/update_profile"
    # User ID from our previous tests
    user_id = "00f8c008-1903-4fa8-bd9d-272b3533acf4"
    
    # 1. Update username
    payload = {
        "user_id": user_id,
        "username": "api_test_user",
        "email": None
    }
    
    print("Sending POST request to update profile...")
    try:
        res = requests.post(url, json=payload)
        print("Status Code:", res.status_code)
        print("Response Content:", res.json())
        
        # Verify from database
        from database.client import supabase
        db_res = supabase.table("profiles").select("*").eq("id", user_id).maybe_single().execute()
        print("Profile in DB after API call:", db_res.data if db_res else None)
        
        # Restore
        supabase.table("profiles").update({"username": "missu"}).eq("id", user_id).execute()
        print("Restored username in DB.")
    except Exception as e:
        print("Error:", str(e))

if __name__ == "__main__":
    test_api()
