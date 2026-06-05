from database.client import supabase

def email_exists(email: str) -> bool:
    """
    Check if a profile with the given email exists.
    """
    response = supabase.table("profiles").select("id").eq("email", email).execute()
    return len(response.data) > 0
