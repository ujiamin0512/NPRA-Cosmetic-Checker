<p align="center">
  <img src="frontend/assets/images/logo.png" alt="NPRA Cosmetic Checker logo" width="120" />
</p>

<h1 align="center">NPRA Cosmetic Checker</h1>

<p align="center">
  A mobile app that helps Malaysian consumers verify cosmetic product safety against the
  <a href="https://www.npra.gov.my/">National Pharmaceutical Regulatory Agency (NPRA)</a> notification database,
  analyze ingredient lists, and get AI-powered skincare advice.
</p>

## About

Cosmetic products sold in Malaysia must be notified with the NPRA, and products found to contain banned
substances are periodically flagged and pulled from the register. This project makes that information
accessible: users can search for a product by name or notification number, see its NPRA status, scan its
ingredient list for red flags (parabens, silicones, sulphates, fragrance, allergens), and chat with an
AI assistant for personalized advice based on their own skin profile.

> [!NOTE]
> This project was built as a university assignment (`assignment_2`) and is not affiliated with or
> endorsed by the NPRA.

## Features

- **Product lookup** — search the NPRA notification register by product name, brand, or ingredients, with fuzzy and full-text search.
- **Ingredient analysis** — read the ingredient list and get a strict-matching breakdown of whether a
  product is natural, vegan, fragrance-free, paraben-free, silicone-free, sulphate-free, and gluten-free.
- **AI beauty advisor** — a Gemini-powered chatbot, orchestrated as an [n8n](https://n8n.io/) workflow
  (`AI Beauty Advisor.json`), that classifies whether a question is skincare-relevant, pulls the user's
  skin profile and (if applicable) product data from Supabase, and generates a context-aware, structured
  reply for the home, product-intro, and ongoing-chat flows.
- **Skin profile** — a short onboarding wizard captures skin type, concerns, and allergies to personalize
  analysis and chat responses.
- **Incident reports** — users can file a report against a product, attaching a location picked from an
  interactive map, purchase details, and a description of the issue.
- **Accounts** — email/password authentication, profile editing, and password management backed by Supabase.

## Architecture

```
frontend/               Flutter app (Android, iOS, web, desktop) — the user-facing client
backend/                FastAPI service — ingredient analysis and Supabase-backed REST API
AI Beauty Advisor.json  n8n workflow — the AI beauty advisor chatbot
```

The frontend talks to the FastAPI backend over HTTP for ingredient analysis, and to Supabase directly
(via the backend's REST wrapper) for auth, products, reports, and skin profile data. Chat messages are
sent to a webhook (`cosmetic-chat`) exposed by the **n8n** workflow in `AI Beauty Advisor.json`, which
runs independently of the FastAPI service: it routes by flow type (home / product intro / ongoing chat),
uses a Gemini agent to filter out off-topic questions, fetches skin-profile and product context from
Supabase, and generates a structured reply with a Gemini LLM agent and short-term conversation memory.
Product and substance data originate from the NPRA register (see
`frontend/assets/database/cosmetics.csv`) and are served from a Supabase Postgres database with
full-text and trigram search functions.

> [!NOTE]
> `backend/chat_bot.py` contains an earlier LangChain-based implementation of the same chat logic; the
> app's chat feature is now served by the n8n workflow described above.

## Tech stack

| Layer      | Technology                                                              |
| ---------- | ------------------------------------------------------------------------ |
| Frontend   | Flutter, `flutter_map`, `sqflite`, `flutter_chat_ui`                     |
| Backend    | FastAPI, Uvicorn, Pydantic                                               |
| AI / Chat  | n8n (LangChain nodes) + Google Gemini                                    |
| Data       | Supabase (Postgres, Auth)                                                |

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.9.2`
- Python `3.11`
- A [Supabase](https://supabase.com/) project with the products/ingredients schema and RPC functions
  (`smart_search_high_precision`, `search_products_trigram`)
- A [Google Gemini API key](https://ai.google.dev/)
- An [n8n](https://n8n.io/) instance (self-hosted or n8n Cloud) to run the AI beauty advisor workflow

### Backend

```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # .venv\Scripts\activate on Windows
pip install -r requirements.txt
```

Create a `.env` file in `backend/`:

```env
SUPABASE_URL=your-supabase-project-url
SUPABASE_SERVICE_KEY=your-supabase-service-role-key
GEMINI_API_KEY=your-gemini-api-key
```

Run the API locally:

```bash
uvicorn main:app --reload
```

The API is available at `http://localhost:8000`. A `Procfile` is included for deployment to platforms
such as Render or Heroku.

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

> [!IMPORTANT]
> Update the backend base URL in `frontend/lib/services/api_service.dart` and
> `frontend/lib/services/chat_api_service.dart` to point at your running backend instance.

### AI beauty advisor (n8n)

1. Import `AI Beauty Advisor.json` into your n8n instance.
2. Add credentials for **Supabase** and **Google Gemini (PaLM)** and attach them to the corresponding
   nodes (`Fetch Skin Profile*`, `Fetch Product Data`, `Gemini * Model` nodes).
3. Activate the workflow and note the production webhook URL for `cosmetic-chat`.
4. Point `frontend/lib/services/chat_api_service.dart` at that webhook URL.

## Project structure

<details>
<summary>Backend (<code>backend/</code>)</summary>

```
main.py                  FastAPI app and route definitions
ingredients_analysis.py  Ingredient matching and safety analysis
chat_bot.py              Earlier LangChain/Gemini chat logic, superseded by the n8n workflow
database/                Supabase-backed auth, product, report, and skin profile functions
```
</details>

<details>
<summary>Frontend (<code>frontend/lib/</code>)</summary>

```
views/       App screens (login, dashboard, product results, reports, chat, profile)
models/      Data models
databases/   Local (SQLite) and remote data access
services/    HTTP clients for the backend API
widgets/     Shared UI components
```
</details>
