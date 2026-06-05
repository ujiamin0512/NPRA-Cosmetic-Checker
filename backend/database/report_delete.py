from database.client import supabase

def delete_report(report_id: int) -> dict:
    """
    Delete a report from the database using its ID.
    """
    supabase.table("reports").delete().eq("id", report_id).execute()
    return {"status": "success"}
