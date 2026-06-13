# EcoHub Flutter + Supabase

This repository contains a Flutter implementation for a responsive zero-waste product marketplace and Supabase backend code for the data model, seed content, storage, and row-level security policies.

The app includes product discovery plus a user dashboard for profile photos, saved products, order settings, help center issue reporting, realtime notifications, waste tracking, and automatic Eco Score ranking.

## Project structure

```text
lib/
  main.dart
  src/
    data/                 Demo data and Supabase repository
    models/               Marketplace domain models
    screens/              Marketplace UI screens
    theme/                App theme
    widgets/              Reusable cards and chips
supabase/
  migrations/             Database schema, RLS policies, storage setup
  seed.sql                Sample marketplace data
scripts/
  apply_supabase_schema.sh
```

## Flutter setup

This cloud machine does not include Flutter, so the app source was generated manually. On a machine with Flutter installed:

```bash
flutter create --platforms=android,ios,web .
flutter pub get
flutter run --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

If the Supabase values are omitted, the app runs with bundled demo data.

## Implemented features

- Profile photo upload/update/delete through the `profile-photos` Supabase Storage bucket, including image type and size validation.
- Saved products through the `saved_products` table, with persistent save/unsave controls and a dashboard list.
- Order preferences through `order_preferences` with delivery, packaging, substitution, contactless, and notes fields.
- Help Center with FAQ, contact number `01747104029`, live support info, and support issue submissions to `support_issues`.
- Fixed notification bar backed by `notifications`, unread count, realtime stream updates, and read/unread actions.
- Waste tracker backed by `waste_records`, with automatic totals for waste reduced, recycled items, food saved, and monthly stats.
- Eco Score calculation backed by `eco_scores` and `eco_score_history`, recalculated by database triggers after waste and saved-product changes.
- RLS policies and indexes for all new CRUD surfaces.

## Supabase setup

Install the Supabase CLI and PostgreSQL client tools. For a linked/local Supabase project, or for any Postgres URL exposed through `SUPABASE_DB_URL`, run:

```bash
./scripts/apply_supabase_schema.sh
```

The script applies every SQL migration and loads `supabase/seed.sql`. If the Supabase CLI is not available, provide a database URL:

```bash
SUPABASE_DB_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres ./scripts/apply_supabase_schema.sh
```

## Environment values

Copy `.env.example` to `.env` for local reference. Flutter reads these values through `--dart-define`, not directly from `.env`.
