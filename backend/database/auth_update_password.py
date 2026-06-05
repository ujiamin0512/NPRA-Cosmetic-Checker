from database.client import supabase

def update_user_password(user_id: str, new_password: str) -> dict:
    """
    Update a user's password/PIN using Supabase Auth Admin API.
    """
    supabase.auth.admin.update_user_by_id(
        user_id,
        attributes={"password": new_password}
    )
    return {"status": "success"}
