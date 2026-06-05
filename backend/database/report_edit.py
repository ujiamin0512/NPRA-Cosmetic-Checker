from database.client import supabase

def edit_report(report_id: int, report_data: dict) -> dict:
    """
    Update an existing report record in the database.
    """
    # Avoid updating the primary key id
    report_data.pop("id", None)
    
    response = supabase.table("reports").update(report_data).eq("id", report_id).execute()
    return {"status": "success", "report": response.data[0]}
