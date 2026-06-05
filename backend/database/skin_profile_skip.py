from database.client import supabase

def increment_wizard_skip(user_id: str) -> dict:
    """
    Increment the wizard skip count for a given user ID.
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
            print(f"Error checking skin profiles: {e}")
            
    current_count = existing.get("wizard_skip_count", 0) if existing else 0
    new_count = current_count + 1
    
    data = {
        "wizard_skip_count": new_count
    }
    
    if existing:
        supabase.table("skin_profiles").update(data).eq("user_id" if uses_user_id else "id", user_id).execute()
    else:
        data["user_id" if uses_user_id else "id"] = user_id
        supabase.table("skin_profiles").insert(data).execute()
        
    return {"status": "success", "new_count": new_count}
