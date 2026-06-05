import os
from supabase import create_client, Client
from dotenv import load_dotenv

from pathlib import Path

# Load .env file
env_path = Path(__file__).resolve().parent.parent / '.env'
load_dotenv(dotenv_path=env_path)

url: str = os.environ.get("SUPABASE_URL", "")
key: str = os.environ.get("SUPABASE_SERVICE_KEY", "")

# Verify config is loaded
if not url or key == "YOUR_SUPABASE_SERVICE_ROLE_KEY" or not key:
    print("⚠️ WARNING: SUPABASE_URL or SUPABASE_SERVICE_KEY is missing or using default placeholder. Please update the .env file.")

supabase: Client = create_client(url, key)
