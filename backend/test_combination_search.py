import re
from database.client import supabase

def search_products_combined(query: str) -> list:
    trimmed_query = query.strip()
    if not trimmed_query:
        return []

    results = []
    # 1. Try Full Text Search
    try:
        sanitized = re.sub(r'[^\w\s]', '', trimmed_query)
        words = [f"{word}:*" for word in sanitized.split() if word]
        if words:
            formatted_query = ' & '.join(words)
            response = supabase.table("products").select("*").text_search("fts_vector", formatted_query).execute()
            results = response.data or []
            print(f"FTS found: {len(results)} items")
    except Exception as e:
        print(f"Full text search failed: {e}")

    # 2. Try ILIKE search on product, brand, and company
    try:
        or_filter = f"product.ilike.%{trimmed_query}%,brand.ilike.%{trimmed_query}%,company.ilike.%{trimmed_query}%"
        ilike_response = supabase.table("products").select("*").or_(or_filter).limit(50).execute()
        ilike_results = ilike_response.data or []
        print(f"ILIKE found: {len(ilike_results)} items")
        
        seen_notif_nos = {item['notif_no'] for item in results}
        for item in ilike_results:
            if item['notif_no'] not in seen_notif_nos:
                results.append(item)
                seen_notif_nos.add(item['notif_no'])
    except Exception as e:
        print(f"ILIKE fallback search failed: {e}")
        
    return results

def run_tests():
    queries = ["cream", "night cream", "BL MIRA", "ordinary"]
    for q in queries:
        res = search_products_combined(q)
        print(f"Query: '{q}' -> Total Found {len(res)} results")
        if res:
            print(f"  First: {res[0]['product']} ({res[0]['company']})")
        print("-" * 40)

if __name__ == "__main__":
    run_tests()
