from database.client import url, key
from supabase import create_client

def resend_verification_email(email: str) -> None:
    temp_client = create_client(url, key)
    temp_client.auth.resend({"type": "signup", "email": email})
