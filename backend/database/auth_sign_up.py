from supabase import create_client
from database.client import supabase, url, key

def sign_up_user(username: str, email: str, password: str) -> str:
    """
    Sign up a new user with Supabase auth and create their profile in public.profiles.
    """
    temp_client = create_client(url, key)
    response = temp_client.auth.sign_up({
        "email": email,
        "password": password
    })
    
    if response.user:
        user_id = response.user.id
        try:
            # Insert profile row
            supabase.table("profiles").insert({
                "id": user_id,
                "username": username,
                "email": email
            }).execute()
        except Exception as e:
            print(f"Warning: Failed to insert profile row: {e}")
        return user_id
    raise Exception("Sign up failed or user creation rejected by Supabase Auth")
