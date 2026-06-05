from database.client import supabase

def update_skin_profile(user_id: str, skin_types: list, skin_concerns: list, allergies: list) -> dict:
    """
    Create or update a user's skin profile details.
    """
    existing = None
    uses_user_id = True
    try:
        existing_res = supabase.table("skin_profiles").select("*").eq("user_id", user_id).maybe_single().execute()
        existing = existing_res.data
    except Exception:
        try:
            existing_res = supabase.table("skin_profiles").select("*").eq("id", user_id).maybe_single().execute()
            existing = existing_res.data
            uses_user_id = False
        except Exception as e:
            print(f"Error checking skin profile table columns: {e}")
        
    data = {
        "skin_types": skin_types,
        "skin_concerns": skin_concerns,
        "allergies": allergies,
        "profile_completed": True
    }
    
    if existing:
        supabase.table("skin_profiles").update(data).eq("user_id" if uses_user_id else "id", user_id).execute()
    else:
        data["user_id" if uses_user_id else "id"] = user_id
        supabase.table("skin_profiles").insert(data).execute()
        
    return {"status": "success"}
