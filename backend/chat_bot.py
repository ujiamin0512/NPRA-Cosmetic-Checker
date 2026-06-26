import os
from typing import List, Dict, Any
from dotenv import load_dotenv
from supabase import create_client, Client
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage

from pathlib import Path

# Load environment variables (local .env only — Render injects them directly)
env_path = Path(__file__).resolve().parent / '.env'
load_dotenv(dotenv_path=env_path)

# ================= Configuration =================
SUPABASE_URL = os.environ.get("SUPABASE_URL", "")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_KEY", "")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
# =================================================

SKINCARE_KEYWORDS = [
    'skin', 'skincare', 'moistur', 'sunscreen', 'spf', 'serum', 'toner', 'cleanser',
    'ingredient', 'acne', 'pimple', 'breakout', 'cosmetic', 'makeup', 'foundation',
    'lipstick', 'blush', 'concealer', 'eyeshadow', 'mascara', 'product', 'cream',
    'lotion', 'oil', 'retinol', 'niacinamide', 'hyaluronic', 'vitamin c', 'aha', 'bha',
    'paraben', 'fragrance', 'allerg', 'sensitiv', 'dry', 'oily', 'combination', 'normal',
    'pore', 'wrinkle', 'aging', 'brightening', 'whitening', 'pigment', 'dark spot',
    'redness', 'eczema', 'rosacea', 'dermatitis', 'npra', 'halal', 'beauty', 'hair',
    'shampoo', 'conditioner', 'body wash', 'spf', 'uv', 'sunburn', 'collagen', 'peptide',
]

def _is_skincare_relevant(message: str) -> bool:
    lower = message.lower()
    return any(kw in lower for kw in SKINCARE_KEYWORDS)


class ChatBotManager:
    def __init__(self):
        self.llm = ChatGoogleGenerativeAI(
            model="gemini-3.1-flash-lite",
            google_api_key=GEMINI_API_KEY,
            temperature=0.7,
        )

    def _parse_history(self, history: List[Dict[str, str]]):
        """Converts raw dictionary history into LangChain message objects."""
        messages = []
        for msg in history:
            role = msg.get("role", "")
            content = msg.get("content", "")
            if role == "user":
                messages.append(HumanMessage(content=content))
            elif role == "assistant":
                messages.append(AIMessage(content=content))
            elif role == "system":
                messages.append(SystemMessage(content=content))
        return messages

    def get_product_system_prompt(self, context: Dict[str, Any]) -> str:
        product_name = context.get('product_name', 'Unknown')
        ingredients = context.get('ingredients', 'None')
        skin_profile = context.get('skin_profile', 'Unknown')

        return f"""Professional Skincare Consultant.
Context:
- Product: {product_name}
- Ingredients: {ingredients}
- User Skin: {skin_profile}

Task: Analyze suitability. Be extremely concise."""

    def get_home_system_prompt(self, context: Dict[str, Any]) -> str:
        skin_profile = context.get('skin_profile', 'Unknown')

        return f"""Professional Skincare Consultant.
User Skin: {skin_profile}
Task: Give skincare advice. Be friendly but extremely concise. Language: English."""

    def generate_initial_analysis(self, context: Dict[str, Any]) -> str:
        """Called when user first opens the chat from a product page."""
        sys_prompt = self.get_product_system_prompt(context)

        summary = f"📋 **Analysis Context:**\n- **Product:** {context.get('product_name')}\n- **Skin Type:** {context.get('skin_profile')}\n\n"

        messages = [
            SystemMessage(content=sys_prompt),
            HumanMessage(content="Perform initial analysis. Brief only.")
        ]
        try:
            response = self.llm.invoke(messages)
            return summary + response.content
        except Exception as e:
            print(f"Error in generate_initial_analysis: {e}")
            return summary + "I'm sorry, I'm currently experiencing high demand. Please try asking me again in a moment! 🧘‍♀️"

    def process_message(self, flow_type: str, history: List[Dict[str, str]], new_message: str, context: Dict[str, Any]) -> Dict[str, Any]:
        """Process an ongoing chat message."""
        # 1. Reject off-topic questions for home flow
        if flow_type == "home" and not _is_skincare_relevant(new_message):
            return {"reply": "I can only help with skincare, cosmetics, and beauty related questions. Please ask me something related to those topics!"}

        # 2. Determine system prompt based on flow type
        if flow_type == "product":
            sys_prompt = self.get_product_system_prompt(context)
        else:
            sys_prompt = self.get_home_system_prompt(context)

        # 3. Build message history for LangChain
        messages = [SystemMessage(content=sys_prompt)]
        messages.extend(self._parse_history(history))
        messages.append(HumanMessage(content=new_message))

        # 4. Generate response from Gemini
        try:
            response = self.llm.invoke(messages)
            return {"reply": response.content}
        except Exception as e:
            print(f"Error in process_message: {e}")
            return {"reply": "I'm sorry, I'm currently experiencing high demand. Please try again in a moment!"}

# Singleton instance
chat_bot = ChatBotManager()
