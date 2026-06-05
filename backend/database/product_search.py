import re
from database.client import supabase

def search_products(query: str) -> list:
    """
    Search products using a combination of Supabase Full Text Search (on fts_vector)
    and ILIKE fallback search on product, brand, and company.
    """
    trimmed_query = query.strip()
    if not trimmed_query:
        return []

    results = []
    # 1. Try Full Text Search (which indexes product and brand in fts_vector)
    try:
        sanitized = re.sub(r'[^\w\s]', '', trimmed_query)
        words = [f"{word}:*" for word in sanitized.split() if word]
        if words:
            formatted_query = ' & '.join(words)
            response = supabase.table("products").select("*").text_search("fts_vector", formatted_query).execute()
            results = response.data or []
    except Exception as e:
        print(f"Full text search failed: {e}")

    # 2. Try ILIKE search on product, brand, and company
    try:
        or_filter = f"product.ilike.%{trimmed_query}%,brand.ilike.%{trimmed_query}%,company.ilike.%{trimmed_query}%"
        ilike_response = supabase.table("products").select("*").or_(or_filter).limit(50).execute()
        ilike_results = ilike_response.data or []
        
        seen_notif_nos = {item['notif_no'] for item in results}
        for item in ilike_results:
            if item['notif_no'] not in seen_notif_nos:
                results.append(item)
                seen_notif_nos.add(item['notif_no'])
    except Exception as e:
        print(f"ILIKE fallback search failed: {e}")
        
    return results
