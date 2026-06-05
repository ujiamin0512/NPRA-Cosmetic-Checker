from supabase import create_client
from database.client import supabase, url, key

def auth_login(email: str, password: str) -> dict:
    """
    Authenticate user credentials, verify/fetch profiles and skin_profiles, and return user model data.
    """
    temp_client = create_client(url, key)
    response = temp_client.auth.sign_in_with_password({
        "email": email,
        "password": password
    })
    
    if response.user:
        user_id = response.user.id
        
        # 1. Fetch profile
        profile = None
        try:
            profile_response = supabase.table("profiles").select("*").eq("id", user_id).maybe_single().execute()
            profile = profile_response.data
        except Exception as e:
            print(f"Error reading profile: {e}")
            
        if not profile:
            try:
                # Create missing profile if not exists
                supabase.table("profiles").insert({
                    "id": user_id,
                    "username": email.split("@")[0],
                    "email": email
                }).execute()
                profile_response = supabase.table("profiles").select("*").eq("id", user_id).maybe_single().execute()
                profile = profile_response.data
            except Exception as e:
                print(f"Error creating missing profile during login: {e}")
                
        # 2. Fetch skin profile
        skin_profile = None
        try:
            skin_response = supabase.table("skin_profiles").select("*").eq("id", user_id).maybe_single().execute()
            skin_profile = skin_response.data
        except Exception as e:
            try:
                skin_response = supabase.table("skin_profiles").select("*").eq("user_id", user_id).maybe_single().execute()
                skin_profile = skin_response.data
            except Exception as e2:
                print(f"Error reading skin profile: {e2}")
                
        # Build user data dictionary
        username = profile.get("username", email.split("@")[0]) if profile else email.split("@")[0]
        email_val = profile.get("email", email) if profile else email
        
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
