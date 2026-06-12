# NFT Marketplace Flutter + Supabase

This repository contains a Flutter implementation for an NFT marketplace concept and Supabase backend code for the data model, seed content, storage, and row-level security policies.

The Figma URL could not be fetched from this cloud environment, so the implementation follows the requested project theme: a premium dark NFT marketplace with featured drops, live auctions, top collections, search, favorites, and creator/owner profile data.

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
