# Local Caching & History for Ingredient Analysis

This plan implements local caching of product ingredient analysis using SQLite to reduce API calls to the FastAPI backend, along with a new History page to view previously analyzed products.

## Proposed Changes

### 1. Model Updates (JSON Serialization)
#### [MODIFY] [analysis.dart](file:///c:/Flutter%20Project/NPRA%20Cosmetic%20Checker/frontend/lib/models/analysis.dart)
- Add `toJson()` methods to `AnalysisResponse`, `ReportSummary`, and `IngredientDetail` to allow serialization of the API response into a JSON string for SQLite storage.

### 2. Local Database Setup
#### [NEW] [analysis_cache_db.dart](file:///c:/Flutter%20Project/NPRA%20Cosmetic%20Checker/frontend/lib/databases/analysis_cache_db.dart)
- Create a new SQLite database helper using `sqflite`.
- Define the `analysis_cache` table with columns: `product_id` (PRIMARY KEY), `product_name`, `analysis_data` (JSON string), `created_at`, and `last_viewed_at`.
- Implement methods:
  - `getCache(productId)`: Retrieve cached report and update `last_viewed_at`.
  - `upsertCache(productId, productName, analysisData)`: Insert new or update existing cache, update timestamps, and automatically trigger `cleanupCache()`.
  - `cleanupCache(keepCount: 50)`: Keep only the 50 most recently viewed records based on `last_viewed_at` DESC, deleting older ones.
  - `getAllCache()`: Fetch all cached records ordered by `last_viewed_at` DESC for the history page.
  - `deleteCache(productId)`: Allow manual deletion of a cached record.

### 3. Integrate Caching Logic into Product Details
#### [MODIFY] [product_detail.dart](file:///c:/Flutter%20Project/NPRA%20Cosmetic%20Checker/frontend/lib/views/product_detail.dart)
- Update the "Analyze Ingredients" button `onPressed` logic.
- **First Step**: Check `AnalysisCacheDb` for an existing record using the product's `notifNo` (as `product_id`).
  - If found: Decode the cached JSON directly into `AnalysisResponse`, dismiss the loading dialog, and navigate to `AnalysisReportPage` (no API call needed).
  - If not found: Proceed with calling `ApiService.analyzeIngredients(product.ingredients!)`.
- **Second Step**: Upon receiving a successful response from `ApiService`, encode the `AnalysisResponse` into JSON and insert/replace it in the SQLite cache using `upsertCache`.
- Navigation and error handling will remain smooth and robust.

### 4. Create History Page
#### [NEW] [analysis_history_page.dart](file:///c:/Flutter%20Project/NPRA%20Cosmetic%20Checker/frontend/lib/views/analysis_history_page.dart)
- Build a new view that reads all cache records from `AnalysisCacheDb.getAllCache()`.
- Display a list of products (by name and last viewed time) using `ListView.builder`.
- Tapping an item navigates immediately to `AnalysisReportPage` using the cached data.
- Provide a swipe-to-delete (Dismissible) or trailing delete button to remove a specific history record.

### 5. Update Navigation
#### [MODIFY] [dashboard.dart](file:///c:/Flutter%20Project/NPRA%20Cosmetic%20Checker/frontend/lib/views/dashboard.dart)
- Add a new `BottomNavigationBarItem` for the "History" tab next to the "Home" icon.
- Add `AnalysisHistoryPage` to the `pages` list so the user can navigate to it from the bottom app bar.

## User Review Required

> [!IMPORTANT]
> - I am using `product.notifNo` as the unique `product_id` for the cache. Is this correct?
> - The history page will be added to the bottom navigation bar. Is "History" a good name for this tab?
> - The maximum number of cached products is set to 50 to prevent infinite storage growth. Let me know if you prefer a different limit.

## Verification Plan

### Manual Verification
1. Open a product with ingredients and click "Analyze Ingredients". It should call the API (loading indicator shows) and show the report.
2. Go back and click "Analyze Ingredients" on the same product again. It should load instantly from the cache (loading indicator barely shows, no backend logs).
3. Navigate to the new "History" tab in the bottom bar. The previously analyzed product should be listed there.
4. Tap the product in the History tab; it should open the report instantly.
5. Manually delete the product from the History tab and verify it disappears.
