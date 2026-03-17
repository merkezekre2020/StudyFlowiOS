# StudyFlowiOS

Supabase-backed data/auth layer for StudyFlow iOS.

## Backend stack
This implementation uses **Supabase** for:
- Authentication (`signUp`, `signIn`, `signOut`, `resetPassword`)
- Postgres persistence for users, subjects, plans, tasks, and progress logs

## Setup
1. Add `Config/Supabase.xcconfig` to your Xcode project configurations.
2. Set real values for:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
3. Keep Info.plist passthrough keys enabled (`INFOPLIST_KEY_*`) or inject values as environment variables.

## Database
Run `Database/supabase_schema.sql` in Supabase SQL editor to create tables, foreign keys, and per-user RLS policies.

## Swift package dependency
`Package.swift` includes `supabase-swift` and exposes one library target: `StudyFlowiOS`.

## Implemented APIs
- `SupabaseAuthService` implements async auth flows with `AppError` mapping.
- `SupabaseProfileRepository` implements profile CRUD against `users`.
- `SupabaseSubjectRepository` implements subject CRUD.
- `SupabaseStudyPlannerRepository` implements read/write for plans, tasks, and progress logs.
- `AuthViewModel` and `StudyPlannerViewModel` consume async APIs and expose UI-ready error messages.
