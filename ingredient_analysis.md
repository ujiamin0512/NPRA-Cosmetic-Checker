# Integrating Backend Ingredient Analysis

This plan outlines the steps to connect the Flutter frontend with the FastAPI backend for ingredient analysis, adding a button to product details, and displaying the results.

## Proposed Changes

### Dependencies

#### [MODIFY] pubspec.yaml
Add `http: ^1.2.0` under dependencies.

---

### Models

#### [NEW] lib/models/analysis.dart
Create Dart data models matching the FastAPI response structure:
- `AnalysisResponse` — root object containing `summary` and `ingredients_report`
- `ReportSummary` — handles boolean fields like `is_natural`, `is_vegan`, `is_paraben_free`, etc.
- `IngredientDetail` — handles individual ingredient fields: `inci_name`, `matched_type`, `ing_function`, `ing_origin`
- All models include `fromJson` factory methods for JSON parsing

---

### Services

#### [NEW] lib/services/api_service.dart
Create `ApiService` with a method `analyzeIngredients(String ingredientsStr)`:
- POSTs to the FastAPI `/analyze` endpoint with payload `{"ingredients_str": "..."}`
- Parses the JSON response into `AnalysisResponse` using the models above
- Default backend URL is `http://10.0.2.2:8000` (Android emulator). Change to `http://localhost:8000` for web/iOS simulator, or your machine's local IP for physical device testing

---

### Views

#### [MODIFY] lib/views/product_detail.dart
When product status is `notified` and has ingredients, add an **"Analyze Ingredients"** button:
- On press: show a loading dialog, then call `ApiService.analyzeIngredients`
- Upon successful response, close the loading dialog and navigate to `AnalysisReportPage`
- Pass the decoded `AnalysisResponse` object upon navigation

#### [NEW] lib/views/analysis_report.dart
Create `AnalysisReportPage` to display analysis results. Accepts an `AnalysisResponse` object:
- **Summary Section** — displays chips or icons for overall product properties based on `report.summary` boolean fields (e.g. Vegan, Paraben-Free, Natural)
- **Ingredients List** — iterates over `report.ingredientsReport`, displaying each ingredient's `inci_name`, `ing_function`, `ing_origin`, and `matched_type` in a clean card layout

---

## Open Questions

> [!IMPORTANT]
> **Backend URL** depends on your Flutter test environment:
> - **Android Emulator** → `http://10.0.2.2:8000`
> - **Web / iOS Simulator** → `http://localhost:8000`
> - **Physical Device** → your machine's local IP, e.g. `http://192.168.1.x:8000`
>
> Default is set to `http://10.0.2.2:8000/analyze`. Update in `api_service.dart` as needed.

---

## Verification Plan
1. Add `http` dependency and run `flutter pub get`.
2. Implement all new and modified files in order: models → services → views.
3. Start the FastAPI backend locally.
4. Open a notified product and press **"Analyze Ingredients"**.
5. Verify the loading state appears, then `AnalysisReportPage` populates with real backend data.