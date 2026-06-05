from database.client import supabase

def make_report(report_data: dict) -> dict:
    """
    Insert a new user cosmetic report record in the database.
    """
    # Remove primary key 'id' to let Supabase auto-generate it
    report_data.pop("id", None)
    
    response = supabase.table("reports").insert(report_data).execute()
    return {"status": "success", "report": response.data[0]}
