# Implementation Plan: Guest Mode for NPRA Cosmetic Checker

This plan outlines the changes required to add a **Guest Mode** to the NPRA Cosmetic Checker app. Guest users can click **"Continue as Guest"** on the Login Page to access the app's homepage to check cosmetic product status, while all restricted features (AI advice, ingredient analysis, and reporting) are disabled or hidden.

---

## User Review Required

> [!IMPORTANT]
> **Guest User Navigation Restriction**
> To satisfy the requirement that a guest user is *only* allowed to check product status and access the homepage with no other restricted capabilities, the implementation plan proposes **hiding the Bottom Navigation Bar entirely** for guest sessions. 
> Since Guest users do not have profiles, history, or reporting abilities, pinning them to the Home Page ensures they can only search and view status lists.

---

## Proposed Changes

We will introduce a `isGuest` boolean flag, passed from the `LoginPage` down to the `Dashboard` and through to the `ProductDetailPage`.

### Frontend: Core Views

---

#### [MODIFY] [login_page.dart](file:///c:/Flutter%20Project/NPRA%20Cosmetic%20Checker/frontend/lib/views/login_page.dart)

- Add a premium, modern `"Continue as Guest"` OutlinedButton right below the `"Log In"` ElevatedButton.
- Implement the `_handleGuestLogin()` handler that navigates to the `Dashboard` with `isGuest: true`, clearing the navigation stack so the user cannot pop back to login.

```dart
// Example Button Style & Navigation:
SizedBox(
  height: 52,
  child: OutlinedButton(
    onPressed: _submitting ? null : _handleGuestLogin,
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: Color(0xFF1D0CC2), width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    ),
    child: const Text(
      'Continue as Guest',
      style: TextStyle(
        color: Color(0xFF1D0CC2),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),
),
```

---

#### [MODIFY] [dashboard.dart](file:///c:/Flutter%20Project/NPRA%20Cosmetic%20Checker/frontend/lib/views/dashboard.dart)

- Update `Dashboard` and `_DashboardShell` constructors to accept a `bool isGuest` parameter (defaults to `false`).
- Pass `isGuest` down to `HomePage` during initialization.
- In `_DashboardShellState.build()`, conditionally hide/remove the `bottomNavigationBar` if `widget.isGuest` is `true`.
  - Setting `bottomNavigationBar: widget.isGuest ? null : DecoratedBox(...)` naturally expands the `HomePage` content and blocks navigation to `AnalysisHistoryPage`, `ReportPage`, and `ProfilePage`.

---

#### [MODIFY] [homepage.dart](file:///c:/Flutter%20Project/NPRA%20Cosmetic%20Checker/frontend/lib/views/homepage.dart)

- Update `HomePage` and `_SearchSection` constructors to accept a `bool isGuest` parameter (defaults to `false`).
- In `_HomePageState`:
  - Skip calling `_checkBannerStatus()` and keep the banner hidden (`_showBanner = false`) if `widget.isGuest` is `true`.
  - Conditionally hide the FloatingActionButton for **AI Chatbot History** (represented by the `Icons.smart_toy_outlined` FAB) if `widget.isGuest` is `true`.
- In `_SearchSection`:
  - Pass `isGuest` down to the `ProductResultsPage` navigation call.

---

#### [MODIFY] [product_result.dart](file:///c:/Flutter%20Project/NPRA%20Cosmetic%20Checker/frontend/lib/views/product_result.dart)

- Update `ProductResultsPage` constructor to accept a `bool isGuest` parameter.
- Pass `isGuest` to the `ProductDetailPage` navigation call when a user taps a product from the list.

---

#### [MODIFY] [product_detail.dart](file:///c:/Flutter%20Project/NPRA%20Cosmetic%20Checker/frontend/lib/views/product_detail.dart)

- Update `ProductDetailPage` constructor to accept a `bool isGuest` parameter.
- Conditionally hide the premium action buttons inside the product details:
  - **"Report Product"** (disable report function)
  - **"Ask AI Advice"** (disable AI chatbot/advice function)
  - **"Analyze Ingredients"** (disable ingredient analysis function)
- Guest users will still be able to view all search result details such as: Brand, Notification Number, Type, Company, Country, and Status (Notified / Cancelled), satisfying the requirement to allow checking product status.

---

## Verification Plan

### Automated/Build Verification
- Run a project build check via `flutter build` or analyze it to ensure syntax correctness.

### Manual Verification
1. **Login Page Visual Check**: Confirm that the `"Continue as Guest"` button looks premium, clean, and perfectly aligned.
2. **Navigation Flow Check**: Click `"Continue as Guest"` and verify that the user goes directly to the `HomePage`.
3. **Guest Restrictions on Home Page**:
   - Verify that the bottom navigation bar is **absent**.
   - Verify that the **AI Chat FAB** is hidden.
   - Verify that the skin profile completion banner is **absent**.
4. **Search and Product Status Verification**:
   - Enter a search query in the search bar.
   - Verify that matching products are listed successfully.
   - Select a product to view details.
5. **Guest Restrictions on Product Details**:
   - Verify that no "Report Product" button is displayed.
   - Verify that no "Ask AI Advice" button is displayed.
   - Verify that no "Analyze Ingredients" button is displayed.
   - Ensure all product details (notification no, brand, company, status, etc.) are fully readable.
