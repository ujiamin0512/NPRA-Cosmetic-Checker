from database.client import supabase

def fetch_products_by_status(status: str, limit: int, offset: int) -> list:
    """
    Fetch products by status range using offset and limit parameters.
    """
    status_variations = [
        status,
        status.lower(),
        status.upper(),
    ]
    if status == 'Cancelled':
        status_variations.extend(['Canceled', 'CANCELED'])

    response = supabase.table("products").select("*").in_("status", status_variations).range(offset, offset + limit - 1).execute()
    return response.data
