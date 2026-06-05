import os
from database.client import supabase

def test_connection():
    try:
        print("Connecting to Supabase...")
        res = supabase.table("products").select("*").limit(1).execute()
        print("Connection status: SUCCESS")
        print("Sample product:", res.data)
        
        print("\nTesting text_search without limit...")
        try:
            search_res = supabase.table("products").select("*").text_search("fts_vector", "cream").execute()
            print("fts_vector search success:", len(search_res.data), "results")
            if search_res.data:
                print("First result product name:", search_res.data[0]['product'])
        except Exception as e:
            print("fts_vector search failed:", str(e))
            
    except Exception as e:
        print("Connection failed:", str(e))

if __name__ == "__main__":
    test_connection()
