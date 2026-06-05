from database.client import supabase

def fetch_reports(user_id: str) -> list:
    """
    Retrieve all reports for a given user ID, ordered by ID in descending order.
    """
    response = supabase.table("reports").select("*").eq("user_id", user_id).order("id", desc=True).execute()
    return response.data
