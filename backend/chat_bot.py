import os
from typing import List, Dict, Any, Optional
from dotenv import load_dotenv
from supabase import create_client, Client
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage
from sentence_transformers import SentenceTransformer

from pathlib import Path

# Load environment variables
env_path = Path(__file__).resolve().parent / '.env'
load_dotenv(dotenv_path=env_path)

# ================= Configuration =================
SUPABASE_URL = "https://hgogvynnpedjjnnnbxon.supabase.co"
SUPABASE_KEY = "sb_publishable_eeF2CCpuGp5WP1y6USa8kg_yQWw5_rx" 
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
# =================================================

class ChatBotManager:
    def __init__(self):
        # Initialize Gemini model
        self.llm = ChatGoogleGenerativeAI(
            model="gemini-2.5-flash-lite",
            google_api_key=GEMINI_API_KEY,
            temperature=0.7,
            convert_system_message_to_human=True # Required for some older Gemini SDK versions if system messages cause issues
        )
        
        # Initialize Embedding model (384 dimensions)
        self.embedding_model = SentenceTransformer('all-MiniLM-L6-v2')
        
    def _parse_history(self, history: List[Dict[str, str]]):
        """Converts raw dictionary history into Langchain message objects."""
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

Task: Analyze suitability. Be extremely concise. 
If recommending others, ask: "Need help finding a better alternative?" """

    def get_home_system_prompt(self, context: Dict[str, Any]) -> str:
        skin_profile = context.get('skin_profile', 'Unknown')
        
        return f"""Professional Skincare Consultant.
User Skin: {skin_profile}
Task: Give skincare advice. Be friendly but extremely concise. Language: English."""


    def generate_initial_analysis(self, context: Dict[str, Any]) -> str:
        """Called when user first opens the chat from a product page."""
        sys_prompt = self.get_product_system_prompt(context)
        
        # Prepare a context summary to show in UI
        summary = f"📋 **Analysis Context:**\n- **Product:** {context.get('product_name')}\n- **Skin Type:** {context.get('skin_profile')}\n\n"
        
        messages = [
            SystemMessage(content=sys_prompt),
            HumanMessage(content="Perform initial analysis. Brief only.")
        ]
        try:
            response = self.llm.invoke(messages)
            # Prepend the summary so it's visible in the UI
            return summary + response.content
        except Exception as e:
            print(f"Error in generate_initial_analysis: {e}")
            return summary + "I'm sorry, I'm currently experiencing high demand. Please try asking me again in a moment! 🧘‍♀️"

    def process_message(self, flow_type: str, history: List[Dict[str, str]], new_message: str, context: Dict[str, Any]) -> Dict[str, Any]:
        """Process an ongoing chat message."""
        # 1. Determine System Prompt
        sys_prompt = ""
        if flow_type == "product":
            sys_prompt = self.get_product_system_prompt(context)
        else:
            sys_prompt = self.get_home_system_prompt(context)
            
        messages = [SystemMessage(content=sys_prompt)]
        messages.extend(self._parse_history(history))
        messages.append(HumanMessage(content=new_message))
        
        # 2. Check if we need to do vector search (Product Flow only)
        # We can use a simple LLM classification to check if the user is asking for recommendations.
        recommendations = []
        if flow_type == "product":
            intent_prompt = f"""Analyze the user's latest reply and determine if they are explicitly asking for product recommendations.
User's latest reply: "{new_message}"
If the user is asking for recommendations, reply ONLY with 'YES', otherwise reply ONLY with 'NO'."""
            intent_res = self.llm.invoke([HumanMessage(content=intent_prompt)]).content.strip().upper()
            
            if "YES" in intent_res:
                # Trigger vector search
                recommendations = self._perform_vector_search(new_message, context.get('skin_profile', ''))

        # 3. Generate response from Gemini
        # If we have recommendations, inject them into the system prompt or as context
        if recommendations:
            rec_text = "\n".join([f"- {r['product']} ({r['brand']})" for r in recommendations])
            injection = f"\nThe system found the following recommended products:\n{rec_text}\nPlease provide advice to the user based on these products."
            messages[0] = SystemMessage(content=sys_prompt + injection)

        try:
            response = self.llm.invoke(messages)
            return {
                "reply": response.content,
                "recommendations": recommendations
            }
        except Exception as e:
            print(f"Error in process_message: {e}")
            return {
                "reply": "I apologize, but I'm having a bit of trouble responding right now due to high traffic. 😅 Please try sending your message again!",
                "recommendations": []
            }

    def _perform_vector_search(self, query: str, skin_profile: str) -> List[Dict[str, Any]]:
        """Generates embedding for the query and searches Supabase."""
        try:
            # 1. Generate embedding
            query_embedding = self.embedding_model.encode(query).tolist()
            
            # 2. Query Supabase
            # Note: We pass skin_profile to the RPC so it can optionally filter or rank based on it if implemented.
            # Assuming the RPC 'match_products_embeddings' takes 'query_embedding' and 'match_threshold', 'match_count'
            response = supabase.rpc(
                "match_products_embeddings",
                {
                    "query_embedding": query_embedding,
                    "match_threshold": 0.5, # Adjust as needed
                    "match_count": 5
                }
            ).execute()
            
            if response.data:
                return response.data
            return []
        except Exception as e:
            print(f"Vector search error: {e}")
            return []

# Singleton instance
chat_bot = ChatBotManager()
