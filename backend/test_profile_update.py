from database.client import supabase

def test_profile():
    try:
        print("Fetching profiles...")
        res = supabase.table("profiles").select("*").limit(5).execute()
        print("Profiles:", res.data)
        
        if res.data:
            user = res.data[0]
            user_id = user['id']
            old_username = user.get('username')
            print(f"Testing profile update for user {user_id} (old username: {old_username})...")
            
            # Try updating username
            new_username = f"test_{old_username}" if old_username else "test_user"
            update_res = supabase.table("profiles").update({"username": new_username}).eq("id", user_id).execute()
            print("Update response data:", update_res.data)
            
            # Re-fetch profile
            refetch = supabase.table("profiles").select("*").eq("id", user_id).maybe_single().execute()
            print("Re-fetched profile:", refetch.data)
            
            # Restore username
            supabase.table("profiles").update({"username": old_username}).eq("id", user_id).execute()
            print("Restored username.")
        else:
            print("No profiles found in database.")
    except Exception as e:
        print("Error:", str(e))

if __name__ == "__main__":
    test_profile()
