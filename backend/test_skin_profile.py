from database.client import supabase

def test_skin_profile():
    try:
        print("Fetching skin profiles...")
        res = supabase.table("skin_profiles").select("*").limit(5).execute()
        print("Skin profiles:", res.data)
        
        if res.data:
            sp = res.data[0]
            print("Keys:", list(sp.keys()))
        else:
            print("No skin profiles found.")
    except Exception as e:
        print("Error:", str(e))

if __name__ == "__main__":
    test_skin_profile()
