from database.client import supabase

def update_user_profile(user_id: str, username: str, email: str) -> dict:
    """
    Update username and/or email in the public.profiles database table.
    """
    updates = {}
    if username:
        updates["username"] = username
    if email:
        updates["email"] = email
        
    print(f"[debug] update_user_profile called for user_id={user_id}")
    print(f"[debug] updates dictionary: {updates}")
    
    if updates:
        response = supabase.table("profiles").update(updates).eq("id", user_id).execute()
        print(f"[debug] Supabase update response data: {response.data}")
        
    if email:
        try:
            supabase.auth.admin.update_user_by_id(
                user_id,
                attributes={"email": email}
            )
            print("[debug] Supabase auth email update success")
        except Exception as e:
            print(f"[debug] Supabase auth email update failed: {e}")
            raise e
        
    return {"status": "success"}


