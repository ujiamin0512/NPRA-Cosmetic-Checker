from database.client import supabase
from database.auth_sign_in import auth_login
from database.auth_update_password import update_user_password

def test_flow():
    email = "ujiamin0512@gmail.com"
    old_pin = "123456"
    new_pin = "654321"
    
    try:
        print(f"Step 1: Attempting login with pin '{old_pin}'...")
        user_data = auth_login(email, old_pin)
        user_id = user_data['id']
        print("Login SUCCESS. User ID:", user_id)
        
        print(f"Step 2: Updating PIN to '{new_pin}'...")
        res = update_user_password(user_id, new_pin)
        print("Update response:", res)
        
        print(f"Step 3: Attempting login with new PIN '{new_pin}'...")
        user_data_new = auth_login(email, new_pin)
        print("Login with new PIN SUCCESS!")
        
        # Restore PIN
        print(f"Step 4: Restoring PIN to '{old_pin}'...")
        update_user_password(user_id, old_pin)
        print("PIN restored successfully.")
        
    except Exception as e:
        print("Failure in PIN flow:", str(e))

if __name__ == "__main__":
    test_flow()
