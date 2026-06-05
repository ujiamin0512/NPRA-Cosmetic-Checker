from database.client import supabase

def delete_user_account(user_id: str) -> dict:
    """
    Delete a user profile record and their Auth record.
    """
    try:
        supabase.table("profiles").delete().eq("id", user_id).execute()
    except Exception as e:
        print(f"Warning: Failed to delete user profile database record: {e}")
        
    supabase.auth.admin.delete_user(user_id)
    return {"status": "success"}
