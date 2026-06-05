from database.client import supabase

def get_user_by_id(user_id: str) -> dict:
    """
    Fetch profile and skin_profile for a given user ID.
    """
    profile_response = supabase.table("profiles").select("*").eq("id", user_id).maybe_single().execute()
    profile = profile_response.data
    
    if profile:
        # Fetch skin profile
        skin_profile = None
        try:
            skin_response = supabase.table("skin_profiles").select("*").eq("id", user_id).maybe_single().execute()
            skin_profile = skin_response.data
        except Exception:
            try:
                skin_response = supabase.table("skin_profiles").select("*").eq("user_id", user_id).maybe_single().execute()
                skin_profile = skin_response.data
            except Exception as e:
                print(f"Error reading skin profile: {e}")
                
        return {
            "id": user_id,
            "username": profile.get("username", ""),
            "email": profile.get("email", ""),
            "skinProfile": {
                "profileCompleted": skin_profile.get("profile_completed", False) if skin_profile else False,
                "wizardSkipCount": skin_profile.get("wizard_skip_count", 0) if skin_profile else 0,
                "skinTypes": skin_profile.get("skin_types", []) if skin_profile else [],
                "skinConcerns": skin_profile.get("skin_concerns", []) if skin_profile else [],
                "allergies": skin_profile.get("allergies", []) if skin_profile else [],
            }
        }
    raise Exception("User not found")
