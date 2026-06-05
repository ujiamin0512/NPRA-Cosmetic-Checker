from database.client import supabase
from database.auth_update_password import update_user_password

def test_password():
    try:
        print("Fetching profiles to get a user ID...")
        res = supabase.table("profiles").select("*").limit(1).execute()
        if res.data:
            user_id = res.data[0]['id']
            print(f"Testing password update for user {user_id}...")
            # Attempt password update using the function
            update_res = update_user_password(user_id, "123456")
            print("Update response:", update_res)
        else:
            print("No profiles found.")
    except Exception as e:
        print("Error during password update:", str(e))

if __name__ == "__main__":
    test_password()
