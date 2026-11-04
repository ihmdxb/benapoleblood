# BenapoleBlood — Setup Together: User + Admin in ONE Supabase, ONE GitHub, ONE Vercel

## How "together" works (important)
You do NOT need separate projects for user and admin. Everything is shared:

| Part | User | Admin |
|---|---|---|
| Website (Vercel) | `benapoleblood.vercel.app/` → index.html | `benapoleblood.vercel.app/admin` → admin.html |
| Login (Supabase Auth) | Same system: email + password | Same system, PLUS check: profiles.role = 'admin' |
| Database (Supabase) | Same tables: profiles, requests, donations, team | Same tables — admin can manage all rows |
| Code (GitHub) | Same repo: `benapoleblood` | Same repo, admin.html sits next to index.html |

Admin is not a different app — it's the same account system, with an extra permission.

---

## PART A — Supabase (do this first)

### A1. Create project
1. Go to https://supabase.com → Sign up / Log in (you can use "Continue with GitHub" — this also creates your GitHub account for Part B, easiest!)
2. Click **New Project**
3. Name: `benapoleblood`
4. Database Password: create a strong one and SAVE it (password manager / notes). You won't need it daily.
5. Region: choose **Singapore** (closest to Bangladesh) if available
6. Click **Create new project**, wait ~2 min

### A2. Create tables
1. Left menu → **SQL Editor** → **+ New query**
2. Open `supabase.sql` from this package, copy ALL of it, paste, click **Run**
3. You should see "Success. No rows returned" — that means tables are created
4. Check: Left menu → **Table Editor** → you should see: profiles, requests, donations, team

### A3. Turn on login
1. Left menu → **Authentication** → **Providers** → **Email**
2. Make sure **Enable Email provider** is ON
3. Turn **Confirm email** OFF for now (so test users can log in instantly). You can turn it ON later for public launch
4. Click Save

### A4. Get your keys — send these to Muse
1. Left menu → **Settings** (gear) → **API**
2. Copy and send Muse:
   - **Project URL** (e.g. https://xyzabc.supabase.co)
   - **Project API Keys → anon public** (long key, starts with eyJ...)
3. ⚠️ Do NOT send the `service_role` key — that one is secret and must never go in a website or chat for storage.

✅ After A4, Muse converts index.html + admin.html from Firebase to Supabase, fixes the splash bug, removes the hardcoded admin password, and returns final files.

---

## PART B — GitHub (one repo for both files)

### B1. Create repo
1. Go to https://github.com → log in (same account as A1 if you used GitHub login)
2. Top right **+** → **New repository**
3. Repository name: `benapoleblood`
4. Choose Public (needed for free Vercel import in most cases) — your code will contain ONLY the anon key, which is safe to be public
5. Do NOT tick "Add a README" (we already have one)
6. Click **Create repository**

### B2. Upload files
On the new repo page → **uploading an existing file** link → drag in the FINAL files Muse gave you:
- `index.html`
- `admin.html`
- `vercel.json`
- `README.md`

Commit message: `BenapoleBlood - Supabase version` → **Commit changes**

> Do NOT upload: supabase.sql is fine to keep in repo as documentation, but never upload any file containing service_role key or your database password.

---

## PART C — Vercel (one project hosts both pages)

### C1. Deploy
1. Go to https://vercel.com → Sign up / Log in with GitHub
2. **Add New… → Project**
3. Find `benapoleblood` repo → **Import**
4. Framework Preset: **Other**
5. Build Command: leave empty. Output Directory: leave default
6. Click **Deploy**, wait ~1 min

### C2. Your live links
- User app: `https://benapoleblood.vercel.app/`
- Admin: `https://benapoleblood.vercel.app/admin`  (vercel.json maps /admin → admin.html)

### C3. Connect Supabase to your live site
1. Supabase → **Authentication** → **URL Configuration**
2. **Site URL**: `https://benapoleblood.vercel.app`
3. Save — this makes email confirmation / password-reset links point to the right site

### C4. Make yourself admin
1. Open your live user app, **Register** with your own email first
2. Supabase → **SQL Editor** → run:
   ```sql
   update public.profiles set role = 'admin' where email = 'YOUR_EMAIL_HERE';
   ```
3. Now log in on `/admin` with that same email + password — only accounts with role='admin' can enter. Everyone else gets "Not an admin account."

---

## PART D — Test everything together (checklist)
- [ ] User: Register a test account → lands in dashboard, no splash stuck
- [ ] User: Log out → Log back in → works
- [ ] User: Post a blood request → appears in list
- [ ] Admin: Log in at /admin with a normal user account → rejected
- [ ] Admin: Log in with your admin account → dashboard opens, you see the test user + test request
- [ ] Admin: Verify a donation / edit a user → change reflects for the user

## Future updates
Edit code → upload new index.html/admin.html to the same GitHub repo (or ask Muse to prepare them) → Vercel redeploys automatically in ~30 seconds. No new Supabase setup needed.
