import re
from database.client import supabase

def search_products(query: str) -> list:
    trimmed_query = query.strip()
    if not trimmed_query:
        return []

    fts_results = []
    trigram_results = []

    # 1. FTS on fts_vector (fast, exact prefix match)
    try:
        sanitized = re.sub(r'[^\w\s]', '', trimmed_query)
        words = [f"{word}:*" for word in sanitized.split() if word]
        if words:
            formatted_query = ' & '.join(words)
            response = supabase.table("products").select("*").text_search("fts_vector", formatted_query).execute()
            fts_results = response.data or []
    except Exception as e:
        print(f"FTS failed: {e}")

    # 2. Trigram RPC (fuzzy, typo-tolerant) on product and brand
    try:
        response = supabase.rpc("search_products_trigram", {"query_text": trimmed_query}).execute()
        trigram_results = response.data or []
    except Exception as e:
        print(f"Trigram search failed: {e}")

    # Merge: trigram results carry similarity_score, FTS results get score 1.0
    seen = {}
    for item in fts_results:
        key = item["notif_no"]
        item["similarity_score"] = 1.0
        seen[key] = item

    for item in trigram_results:
        key = item["notif_no"]
        if key not in seen:
            seen[key] = item
        else:
            seen[key]["similarity_score"] = max(seen[key]["similarity_score"], item.get("similarity_score", 0))

    merged = sorted(seen.values(), key=lambda x: x["similarity_score"], reverse=True)

    # Strip similarity_score before returning — Flutter model doesn't expect it
    for item in merged:
        item.pop("similarity_score", None)

    return merged[:20]
