# Skin Profile Wizard Implementation Plan

This plan details the steps to introduce the Skin Profile Wizard upon login, update the Supabase profiles schema, and add the editable Skin Profile page.

## User Review Required

> [!IMPORTANT]
> - **Database Schema**: The `profiles` table in Supabase will need to be updated to support the new fields. Ensure you add these columns manually in the Supabase dashboard (unless you prefer I generate a SQL command for it):
>   - `profile_completed` (boolean, default false)
>   - `wizard_skip_count` (integer, default 0)
>   - `skin_types` (text)
>   - `skin_concerns` (text)
>   - `allergies` (text)
> - **Session State**: We will manage the `wizard_skipped` state via in-memory parameters (passed during navigation) so that the banner displays properly after a user skips the wizard during that session.

## Open Questions

> [!QUESTION]
> - For "allergies", do you prefer a free-text input field where users can type anything, or another predefined Multi-select list? (The plan assumes a free-text input for now).
> - Should "Skin Types" be a Multi-select (user can pick both Oily and Sensitive) or Single-select (only one choice)? The plan assumes Multi-select as requested for the overall page.

## Proposed Changes

---

### Database & Models

#### [MODIFY] `frontend/lib/models/user.dart`
- Add `profileCompleted` (bool), `wizardSkipCount` (int), `skinTypes` (String), `skinConcerns` (String), and `allergies` (String).
- Update `fromMap` and `toMap` serialization logic for local SQLite.

#### [MODIFY] `frontend/lib/databases/user_db.dart`
- Update the SQLite `CREATE TABLE` query to include the new columns.
- Update `getCurrentUser` and `validateCredentials` to fetch these new columns from Supabase.
- Add `updateSkinProfile()` method to update `skin_types`, `skin_concerns`, `allergies`, and `profile_completed` in Supabase & SQLite.
- Add `incrementWizardSkipCount()` method to update `wizard_skip_count` in Supabase & SQLite.

---

### Authentication Flow

#### [MODIFY] `frontend/lib/views/login_page.dart`
- Update `_handleLogin()` navigation logic:
  - If `profileCompleted == true` -> Navigate to `Dashboard`.
  - Else if `wizardSkipCount >= 3` -> Navigate to `Dashboard(showProfileBanner: true)`.
  - Else -> Navigate to `SkinProfileWizard`.

---

### UI / Views

#### [NEW] `frontend/lib/views/skin_profile_wizard.dart`
- Create a new Wizard view shown after login.
- Include Multi-select FilterChips for Skin Types and Skin Concerns.
- Include a text field for Allergies.
- Add `[Save]` button: Calls `updateSkinProfile()`, then navigates to Dashboard.
- Add `[Skip this time]` button: Calls `incrementWizardSkipCount()`, sets `showProfileBanner: true`, then navigates to Dashboard.

#### [MODIFY] `frontend/lib/views/dashboard.dart`
- Add support for accepting a `showProfileBanner` boolean and passing it to the `HomePage`.

#### [MODIFY] `frontend/lib/views/homepage.dart`
- If `showProfileBanner` is true, or if we fetch the user and `profileCompleted == false && wizardSkipCount >= 3`, display a banner at the top of the Home page: "完善 Skin Profile 获得个性化分析 →".
- Clicking the banner navigates to `SkinProfilePage`.

#### [MODIFY] `frontend/lib/models/profile.dart`
- Add a new `ProfileOption` entry for "Skin Profile" in the profile settings.

#### [MODIFY] `frontend/lib/views/profile_detail.dart`
- Route the new "Skin Profile" option to the `SkinProfilePage`.

#### [NEW] `frontend/lib/views/skin_profile_page.dart`
- Create an editable version of the Skin Profile page (similar to the Wizard).
- Pre-fill values if `profileCompleted == true`.
- Update Supabase and SQLite on `[Save]`.

## Verification Plan

### Manual Verification
1. **Login Flow**: Log in with an account where `profile_completed` is false. Ensure the Wizard pops up.
2. **Skip Logic**: Click "Skip this time" 3 times (logging in and out) to ensure the Wizard stops popping up and the Banner shows on the Home page instead.
3. **Saving Data**: Fill out the Wizard and click "Save". Verify navigation goes to Dashboard without the Banner. Log out and log back in to ensure the Wizard does not show up.
4. **Profile Editing**: Go to Profile -> Skin Profile, verify data is pre-filled, edit the data, save, and check if Supabase reflects the changes.
