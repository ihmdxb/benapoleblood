# BenapoleBlood

Blood donor app for Benapole — renamed from LifeBlood.
User app: `index.html` · Admin console: `admin.html`

## Status
- [x] App renamed: LifeBlood → BenapoleBlood (title, splash, logo, headers in both files)
- [x] Supabase database schema ready: `supabase.sql`
- [x] Supabase project created (A1–A3 reported done by owner, 2026-11-04)
- [x] Code converted: Firebase → Supabase Auth + database in both files. JS syntax verified. Splash bug fixed. Admin hardcoded password removed — admin now requires an account with profiles.role = 'admin'.
- [x] KEY CHECK PASSED (2026-11-04): Supabase Auth health returned 200 and all 4 tables (profiles, requests, donations, team) respond correctly with the publishable key in the code. Note: an earlier "Invalid API key" result was caused by an extra character added when the key was first copied into the code — the owner's original key was correct; the files have been fixed and re-verified.
- [ ] Pushed to GitHub
- [ ] Deployed on Vercel
- [ ] Live test: register, login, post request, admin login (see SETUP-TOGETHER.md Part D)

## Step 1 — Create Supabase project
1. https://supabase.com → New Project → Name: `benapoleblood`
2. Save the database password somewhere safe, wait for project to be ready
3. SQL Editor → paste all of `supabase.sql` → Run
4. Authentication → Providers → Email: ON. For testing, turn "Confirm email" OFF
5. Settings → API → copy **Project URL** and **anon public key** (safe for frontend)
   - Never share the `service_role` key

## Step 2 — Supabase conversion (done by Muse with your keys)
- User login/register: Supabase Auth (email + password), profile saved in `profiles`
- Splash bug fixed: splash hides even if a data read fails, and login never gets stuck
- Admin: no hardcoded password anymore — admin.html will ask for email + password login and only open if `profiles.role = 'admin'`
- After you register yourself, set yourself admin in SQL Editor:
  `update public.profiles set role = 'admin' where email = 'your@email.com';`

## Step 3 — GitHub
1. Create a new GitHub repo named `benapoleblood` (Public or Private)
2. Upload / push these files: `index.html`, `admin.html`, `README.md`
   (Do not upload `supabase.sql` keys or passwords — the anon key in code is fine, service_role is not)

## Step 4 — Vercel
1. https://vercel.com → Add New → Project → Import your `benapoleblood` GitHub repo
2. Framework Preset: **Other**. No build command, no env vars needed for this static site (Supabase keys live in the code, anon key only)
3. Deploy → you get a live URL like `benapoleblood.vercel.app`
4. In Supabase → Authentication → URL Configuration → Site URL: set it to your Vercel URL so email links work

## Data model (from the original Firebase app)
- `profiles` (was `users`): name, email, phone, blood, role, district, available, donation_count
- `requests`: patient, problem, hospital, blood, date, location, phone, note, is_emergency, status, created_by
- `donations`: donor_id, request_id, patient, date, status
- `team`: name, role, img
