from supabase import create_client, Client
import json
import sys
import re
import os
from pathlib import Path
from dotenv import load_dotenv
from concurrent.futures import ThreadPoolExecutor

# Fix Windows terminal emoji printing crash
if sys.stdout and sys.stdout.encoding.lower() != 'utf-8':
    sys.stdout.reconfigure(encoding='utf-8')


# ================= 配置区 =================
env_path = Path(__file__).resolve().parent / '.env'
load_dotenv(dotenv_path=env_path)

SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    raise EnvironmentError("Missing SUPABASE_URL or SUPABASE_SERVICE_KEY in environment variables. Please check your .env file.")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
# ==========================================

def analyze_single_ingredient(name: str, retries: int = 3):
    clean_name = name.lower().strip()

    if not clean_name:
        return None

    last_error = None
    for attempt in range(retries):
        try:
            res = supabase.rpc("smart_search_high_precision", {"search_text": clean_name}).execute()

            if res.data and len(res.data) > 0:
                temp_match = res.data[0]
                score = temp_match.get('similarity_score', 0)
                m_type = temp_match.get('matched_type', 'unknown')
                inci_name = temp_match.get('inci_name', 'N/A')

                if m_type.startswith('exact') or (m_type == 'fuzzy_match' and score >= 0.7):
                    print(f"✅ DEBUG: '{name}' -> '{inci_name}' (Score: {score:.4f})")
                    return temp_match

            # No match found for this ingredient — no point retrying.
            break
        except Exception as e:
            last_error = e
            print(f"⚠️ Attempt {attempt + 1}/{retries} failed for '{name}': {e}")

    if last_error is not None:
        print(f"❌ DEBUG: Giving up on '{clean_name}' after {retries} attempts: {last_error}")
    else:
        print(f"❌ DEBUG: No results found for '{clean_name}'")
    return {
        "inci_name": name,
        "matched_type": "not_found",
        "ing_function": "N/A",
        "ing_origin": "N/A",
        "is_natural": False, "is_vegan": True, "is_fragrance": False,
        "is_paraben": False, "is_silicone": False, "is_sulphate": False, "is_gluten": False
    }

def analyze_ingredients_strict(ingredients_input: str):
    # Only split by comma and strip whitespace from ends
    input_names = [i.strip() for i in ingredients_input.split(",") if i.strip()]

    print(f"\n🧪 分析中: 发现 {len(input_names)} 个成分...\n")

    with ThreadPoolExecutor(max_workers=5) as executor:
        final_details = list(executor.map(analyze_single_ingredient, input_names))

    summary = {
        "is_natural": all(d.get("is_natural", False) for d in final_details if d['matched_type'] != 'not_found'),
        "is_vegan": all(d.get("is_vegan", True) for d in final_details),
        "is_fragrance_free": not any(d.get("is_fragrance", False) for d in final_details),
        "is_paraben_free": not any(d.get("is_paraben", False) for d in final_details),
        "is_silicone_free": not any(d.get("is_silicone", False) for d in final_details),
        "is_sulphate_free": not any(d.get("is_sulphate", False) for d in final_details),
        "is_gluten_free": not any(d.get("is_gluten", False) for d in final_details),
    }

    return {"summary": summary, "ingredients_report": final_details}

def format_bool(value):
    return "Yes ✅" if value else "No ❌"

if __name__ == "__main__":
    user_input = input("请输入成分列表 (用逗号隔开): ")
    result = analyze_ingredients_strict(user_input)
    s = result['summary']

    print("\n" + "="*50)
    print("      📋 化妆品成分分析报告 (严格匹配模式)")
    print("="*50)
    print(f"🌿 Natural (全天然):         {format_bool(s['is_natural'])}")
    print(f"🦁 Vegan (纯素):           {format_bool(s['is_vegan'])}")
    print(f"🌸 Fragrance-Free (无香精):  {format_bool(s['is_fragrance_free'])}")
    print(f"🛡️  Paraben-Free (无防腐剂): {format_bool(s['is_paraben_free'])}")
    print(f"💧 Silicone-Free (无硅油):  {format_bool(s['is_silicone_free'])}")
    print(f"🧼 Sulphate-Free (无硫酸盐): {format_bool(s['is_sulphate_free'])}")
    print(f"🌾 Gluten-Free (无麸质):    {format_bool(s['is_gluten_free'])}")
    print("="*50)
    
    print("\n详细明细:")
    print(f"{'成分 (INCI)':<30} | {'匹配类型':<15} | {'来源'}")
    print("-" * 60)
    for d in result['ingredients_report']:
        name_display = d['inci_name'].upper()
        m_type = d['matched_type']
        print(f"{name_display[:28]:<30} | {m_type:<15} | {d['ing_origin']}")
        if d['matched_type'] != 'not_found':
            print(f"   └─ 功能: {d['ing_function']}")
    print("-" * 60)