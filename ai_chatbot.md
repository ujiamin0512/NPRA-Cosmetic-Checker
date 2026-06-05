# Implement AI Chatbot with Langchain, Gemini, and Supabase Vector Search

This plan outlines the steps to build a contextual AI chatbot with two entry points (Product Details and Home Page), utilizing Langchain, Google Gemini, and Supabase Vector Search on the FastAPI backend, and local SQLite for chat history on the Flutter frontend.

## User Review Required

> [!IMPORTANT]
> The backend will require the `google-generativeai`, `langchain`, `langchain-google-genai`, and `langchain-community` Python packages. You will need to install these or I can run the pip install commands.
> We also need to manage API keys securely (e.g., using a `.env` file in the backend).

## Key Implementation Details

1. **Gemini API Key**: Use the provided key `AIzaSyDCgxK-1MlrJXD0SBzQpFi-962nChN9XV0`.
2. **Supabase Vector Search**: Use the RPC function `match_products_embeddings`.
3. **Flutter Chat UI**: Use the `flutter_chat_ui` package.
4. **Supabase Embedding Model**: Use the `sentence_transformers` model to generate embeddings (dimension: 384) in the backend before querying Supabase.
5. **Product Context**: The frontend will pass the `product` (name) and `ingredients` directly from the `products` table, along with the user's `skin_profile`.

## Proposed Changes

---

### Backend (FastAPI)
Implementing the chat endpoints and Langchain logic.

#### [NEW] `backend/requirements.txt`
Add dependencies: `fastapi`, `uvicorn`, `supabase`, `langchain`, `langchain-google-genai`, `python-dotenv`.

#### [NEW] `backend/chat_bot.py`
Create the Langchain wrapper:
- Initialization of Gemini LLM.
- Function to handle Product Flow (with system prompt containing product details).
- Function to handle Home Flow (with general system prompt).
- Routing logic: Analyze if user wants recommendations, and if yes, query Supabase embeddings using the requested embedding model.

#### [MODIFY] `backend/main.py`
Add endpoints:
- `POST /chat/init/product`: Takes product context, returns initial AI analysis.
- `POST /chat/message`: Takes conversation history + new message + flow type + context. Returns AI reply and optional product recommendations.

---

### Frontend (Flutter) - Database & API
Setting up local SQLite for chat history and FastAPI communication.

#### [NEW] `frontend/lib/models/chat_message.dart`
Define the `ChatSession` and `ChatMessage` models.

#### [NEW] `frontend/lib/databases/chat_db.dart`
Implement SQLite logic using `sqflite` to store and retrieve chat sessions and messages locally.

#### [NEW] `frontend/lib/services/chat_api_service.dart`
Service to handle HTTP requests to the FastAPI backend (`/chat/init/product` and `/chat/message`).

---

### Frontend (Flutter) - UI
Building the chat interface and integrating entry points.

#### [NEW] `frontend/lib/views/chat_page.dart`
The main chat interface displaying message history and a text input field. Will handle both Product and Home flows dynamically.

#### [MODIFY] `frontend/lib/views/product_detail.dart`
Add an "Ask AI" button that navigates to `ChatPage`, passing `flowType: 'product'`, `productId`, `productName`, `ingredients`, and the user's `skinProfile`.

#### [MODIFY] `frontend/lib/views/homepage.dart`
Add an "Ask AI" floating action button (or an icon in the AppBar) that navigates to `ChatPage`, passing `flowType: 'home'` and the user's `skinProfile`.

## Verification Plan

### Automated Tests
- Test FastAPI endpoints using Swagger UI (`http://localhost:8000/docs`) to ensure Langchain chains are responding correctly and state is recreated from history.

### Manual Verification
- **Product Flow**: Enter from a product, verify AI gives initial analysis without user input. Reply with "please recommend", verify vector search is triggered and recommendations are displayed.
- **Home Flow**: Enter from home page, verify AI behaves as a general consultant.
- **Persistence**: Close and reopen the app, verify chat history is retrieved from local SQLite.
