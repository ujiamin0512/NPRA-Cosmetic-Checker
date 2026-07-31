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

- **Product lookup** — search the NPRA notification register by product name, brand, or notification
  number, with fuzzy and full-text search.
- **Ingredient analysis** — paste an ingredient list and get a strict-matching breakdown of whether a
  product is natural, vegan, fragrance-free, paraben-free, silicone-free, sulphate-free, and gluten-free.
- **AI beauty advisor** — a Gemini-powered chatbot (via LangChain) that answers skincare and ingredient
  questions in the context of a product or an ongoing conversation, scoped to skincare-relevant topics.
- **Skin profile** — a short onboarding wizard captures skin type, concerns, and allergies to personalize
  analysis and chat responses.
- **Incident reports** — users can file a report against a product, attaching a location picked from an
  interactive map, purchase details, and a description of the issue.
- **Accounts** — email/password authentication, profile editing, and password management backed by Supabase.

## Architecture

```
frontend/   Flutter app (Android, iOS, web, desktop) — the user-facing client
backend/    FastAPI service — ingredient analysis, chat, and Supabase-backed REST API
```

The frontend talks to the FastAPI backend over HTTP for ingredient analysis and chat, and to Supabase
directly (via the backend's REST wrapper) for auth, products, reports, and skin profile data. Product and
substance data originate from the NPRA register (see `frontend/assets/database/cosmetics.csv`) and are
served from a Supabase Postgres database with full-text and trigram search functions.

## Tech stack

| Layer      | Technology                                                              |
| ---------- | ------------------------------------------------------------------------ |
| Frontend   | Flutter, `flutter_map`, `sqflite`, `flutter_chat_ui`                     |
| Backend    | FastAPI, Uvicorn, Pydantic                                               |
| AI         | LangChain + Google Gemini (`langchain-google-genai`)                     |
| Data       | Supabase (Postgres, Auth)                                                |

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.9.2`
- Python `3.11`
- A [Supabase](https://supabase.com/) project with the products/ingredients schema and RPC functions
  (`smart_search_high_precision`, `search_products_trigram`)
- A [Google Gemini API key](https://ai.google.dev/)

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

## Project structure

<details>
<summary>Backend (<code>backend/</code>)</summary>

```
main.py                  FastAPI app and route definitions
ingredients_analysis.py  Ingredient matching and safety analysis
chat_bot.py              LangChain/Gemini chat logic
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
