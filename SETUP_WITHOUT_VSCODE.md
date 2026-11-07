# Setup without VS Code (Supabase + GitHub + Vercel only)

You never need to install anything. Everything below is done in your web browser.

## Step 0 — Replace your leaked secret key (do this first)
Your `sb_secret_…` key was pasted into a chat. This website never uses it, so simply replace it:
1. Supabase → **Project Settings → API Keys**.
2. Find the **Secret keys** section → delete or rotate the exposed key.
3. Never paste a secret key into chats, GitHub or Vercel for this project.

## Step 1 — Run the SQL in Supabase (3 files, in this order)
Supabase → **SQL Editor → New query**. For each file: open it, copy all, paste, click **Run**.
1. `supabase/schema.sql` — products, categories, settings, admins, image storage, security rules
2. `supabase/orders.sql` — orders table, `place_order` function, auto stock updates
3. `supabase/seed.sql` — *(optional)* 6 demo products

Then make yourself the admin:
1. **Authentication → Users → Add user → Create new user** (your email + strong password, tick **Auto Confirm User**).
2. **SQL Editor** → run this (use your email):
```sql
insert into public.admins (user_id)
select id from auth.users where email = 'YOUR-EMAIL@example.com';
```
3. **Authentication → Sign In / Providers** → turn **off** "Allow new users to sign up" → Save.

## Step 2 — Find your Project URL
Supabase → **Project Settings → API** (or **Data API**) → copy **Project URL** (looks like `https://abcdefgh.supabase.co`).

## Step 3 — Put the project on GitHub (browser only)
1. Unzip `jerseywala.zip` on your computer.
2. github.com → **New repository** → name `jerseywala` → **Private** → Create.
3. Click **uploading an existing file**. Open the unzipped folder and drag in **everything inside it** (folders `app`, `components`, `lib`, `supabase` and the files `package.json`, `middleware.js`, etc.).
   The files `.gitignore` and `.env.example` start with a dot and may be hidden. Turn on "show hidden files" in your file manager if you want to upload them. The site works without them.
4. Click **Commit changes**.
   If GitHub says too many files at once, upload one folder at a time.

## Step 4 — Deploy on Vercel
1. vercel.com → sign in with GitHub → **Add New → Project** → import `jerseywala`.
2. Open **Environment Variables** and add:
| Name | Value |
|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | your Project URL (Step 2) |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | your **publishable** key (`sb_publishable_…`) |
| `NEXT_PUBLIC_SITE_URL` | your Vercel address, or `https://jerseywala.pk` |
| `NEXT_PUBLIC_INSTAGRAM_USERNAME` | your Instagram username |
3. Click **Deploy**.
4. Supabase → **Authentication → URL Configuration** → set **Site URL** to your website address.

## Step 5 — Use it
- Open `your-site/admin` → log in → **Store Settings** (set Instagram username) → **Add Product**.
- When a customer taps **Order via Instagram**, a **New** order appears in **Admin → Orders**.
- Set it to **Confirmed** after you agree the sale in Instagram. Stock drops automatically. **Cancelled** puts stock back.

## Making changes later using Claude
Ask Claude for the change, then in GitHub open the file → pencil icon (**Edit**) → paste → **Commit changes**. Vercel redeploys by itself in about a minute.
