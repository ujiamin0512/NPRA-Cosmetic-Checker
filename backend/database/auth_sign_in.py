from supabase import create_client
from database.client import supabase, url, key

def auth_login(email: str, password: str) -> dict:
    temp_client = create_client(url, key)
    response = temp_client.auth.sign_in_with_password({
        "email": email,
        "password": password
    })

    if response.user:
        user_id = response.user.id

        # Fetch profile
        profile_response = supabase.table("profiles").select("*").eq("id", user_id).maybe_single().execute()
        profile = profile_response.data

        # Fetch skin profile
        skin_response = supabase.table("skin_profiles").select("*").eq("id", user_id).maybe_single().execute()
        skin_profile = skin_response.data

        username = profile.get("username")
        email_val = profile.get("email")

        return {
            "id": user_id,
            "username": username,
            "email": email_val,
            "skinProfile": {
                "profileCompleted": skin_profile.get("profile_completed", False) if skin_profile else False,
                "wizardSkipCount": skin_profile.get("wizard_skip_count", 0) if skin_profile else 0,
                "skinTypes": skin_profile.get("skin_types", []) if skin_profile else [],
                "skinConcerns": skin_profile.get("skin_concerns", []) if skin_profile else [],
                "allergies": skin_profile.get("allergies", []) if skin_profile else [],
            }
        }
    raise Exception("Invalid email or PIN")
