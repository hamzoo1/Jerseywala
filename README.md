# JerseyWala.pk — Football Jersey Store

A premium football jersey website for Pakistan. Customers browse jerseys and order through **Instagram DM**. There is no online payment or checkout. You manage everything from a simple admin panel at `/admin`, with no code editing.

**Built with:** Next.js 14 · Tailwind CSS · Supabase (database, login, image storage)

> **Honest note:** this project was written without being able to install packages or run the site in the build environment. The code was syntax-checked, but you should run through the **test checklist (Part 8)** after setup to confirm everything works on your side. If something fails, the error message plus the step number is enough for anyone to fix it quickly.

---

## What you get

| Area | What it does |
|---|---|
| Home | Hero, New Arrivals, Featured, Best Sellers, Shop by Club, Why Choose Us, Instagram section, footer |
| Shop | Search, category pills, club filter, sorting (newest / price), sold-out badges |
| Product page | Photo gallery, size and quantity selector, stock status, specifications, **ORDER VIA INSTAGRAM** |
| About / Contact | Text and contact details come from Store Settings |
| Admin (`/admin`) | Dashboard, All Products, Add Product, Categories, Store Settings, Logout |

### How Instagram ordering works
1. The customer picks a size and quantity and taps **ORDER VIA INSTAGRAM**.
2. The order message is **copied automatically**, and `https://ig.me/m/your_username` opens in a new tab.
3. A pop-up shows the message, a **Copy message** button, an **Open Instagram chat** button and a link to your profile as a fallback.
4. The customer pastes the message into the chat and sends it.

Instagram does **not** reliably support pre-filled messages, so the copy-and-paste step is on purpose.

### Security (three locks)
1. **Login required:** anyone who is not logged in is sent to the admin login page.
2. **Admin list:** even a logged-in user must be listed in the `admins` table.
3. **Database rules (Row Level Security):** the database itself refuses product, category, settings and image changes from anyone who is not an admin.

The project uses only the public **anon** key. The Supabase `service_role` key is never used. Never paste it anywhere in this project.

---

## Part 1 — Install the tools (one time)

1. Install **Node.js** (the "LTS" version) from <https://nodejs.org>. Click Next through the installer.
2. Check it worked. Open a terminal (Windows: search "Command Prompt"; Mac: "Terminal") and type:
   ```
   node -v
   ```
   You should see a version number like `v20.x.x` or higher.
3. A code editor is helpful. **VS Code** (<https://code.visualstudio.com>) is free.

## Part 2 — Create your Supabase project

Supabase stores your products, your admin login and your photos. The free plan is enough to start.

1. Go to <https://supabase.com> and click **Start your project**. Sign up.
2. Click **New project**. Choose a name (e.g. `jerseywala`), set a **database password** (save it somewhere safe) and pick the region closest to your customers. Click **Create new project** and wait 1–2 minutes.

### 2a. Create the database tables
1. In the left menu, click **SQL Editor**, then **New query**.
2. Open the file `supabase/schema.sql` from this project, copy **everything**, paste it into the editor and click **Run**.
3. You should see "Success. No rows returned". This creates your tables, security rules, the image storage bucket (`product-images`) and starter categories.

### 2b. (Optional) Add demo products
Run `supabase/seed.sql` the same way. It adds 6 sample jerseys with grey placeholder images so you can see the website working. You can delete them later from the admin panel.

### 2c. Create your admin account
1. In the left menu, go to **Authentication → Users**.
2. Click **Add user → Create new user**.
3. Enter **your email** and a **strong password**. Tick **Auto Confirm User**. Click **Create user**.
4. Now make this user an admin. Go back to **SQL Editor → New query**, paste this (change the email to yours) and click **Run**:
   ```sql
   insert into public.admins (user_id)
   select id from auth.users where email = 'YOUR-EMAIL@example.com';
   ```
   It should say "Success. 1 row affected" (if it says 0 rows, the email is spelled differently from the user you created).

### 2d. Turn OFF public sign-ups (important)
1. Go to **Authentication → Sign In / Providers** (on some versions: **Authentication → Providers → Email**).
2. Switch **off** "Allow new users to sign up".
3. Click **Save**.

Even if someone did sign up, the database would still refuse to let them change anything, because they are not in the `admins` table. Turning sign-ups off is an extra layer. The website has no sign-up page at all.

### 2e. Copy your two keys
1. Go to **Project Settings** (gear icon) **→ API** (on some versions: **Data API / API Keys**).
2. Copy the **Project URL**.
3. Copy the **anon public** key (it may be labelled "anon" or "publishable"). **Do not copy the `service_role` / secret key.**

## Part 3 — Run the website on your computer

1. Put the project folder somewhere easy, e.g. `Documents/jerseywala`.
2. Open a terminal **inside the folder**. In VS Code: open the folder, then **Terminal → New Terminal**.
3. Create your settings file:
   - **Mac / Linux:** `cp .env.example .env.local`
   - **Windows (Command Prompt):** `copy .env.example .env.local`
4. Open `.env.local` and paste your values:
   ```
   NEXT_PUBLIC_SUPABASE_URL=https://xxxxxxxx.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOi...
   NEXT_PUBLIC_SITE_URL=http://localhost:3000
   NEXT_PUBLIC_INSTAGRAM_USERNAME=your_instagram_username
   ```
5. Install the project's packages (takes a minute):
   ```
   npm install
   ```
6. Start the website:
   ```
   npm run dev
   ```
7. Open <http://localhost:3000> in your browser. That is your store.
8. Open <http://localhost:3000/admin> and log in with the email and password from step 2c.

To stop the server, press `Ctrl + C` in the terminal. If you change `.env.local`, stop and start the server again.

## Part 4 — First things to do in the admin

1. **Store Settings** (do this first):
   - Enter your **Instagram username**, without the `@`. This is what powers the order buttons.
   - Add your email, phone, WhatsApp, address and social links.
   - Upload a **home page hero picture**, a dark and wide jersey photo, or leave it empty for the default design.
2. **Categories:** rename or add the ones you need.
3. **Add Product:** fill in the form, upload your **real** photos (the first photo is the main one) and click **Publish Product**.
4. Delete the demo products, if you added them, from **All Products**.

### Managing products day to day
- **Edit:** All Products → Edit → change anything → Save Changes. The website updates immediately.
- **Sold out:** use the **Mark sold out** button, or set stock to 0. Customers can't order sold-out jerseys.
- **Hide without deleting:** in Edit, turn off "Visible in the shop".
- **Delete:** All Products → Delete → confirm. The product and its photos are removed.
- **Orders:** run `supabase/orders.sql` too. Each tap on “Order via Instagram” creates a **New** order in Admin → Orders. Setting it to **Confirmed** lowers stock automatically; **Cancelled** puts it back. See `SETUP_WITHOUT_VSCODE.md` for a browser-only guide.

### Photo tips
- JPG, PNG or WEBP. Photos are automatically resized to about 1600 px before upload to keep the site fast. The limit is 5 MB per photo.
- iPhone photos in HEIC format aren't supported by browsers for this. In the Photos app, share/export as JPG, or take them with "Most Compatible" format.
- A vertical (portrait) photo, about 4:5, looks best.

### Changing wording on the home page
The four "Why Choose JerseyWala" boxes are in `app/(site)/page.js` (look for `const WHY`). The About page text is editable in **Store Settings**. Please check the "Why Choose" wording matches your real business (delivery, etc.).

## Part 5 — Put it online with Vercel

1. Create a free account at <https://github.com> and a free account at <https://vercel.com> (sign in with GitHub).
2. Upload the project to GitHub:
   - On GitHub click **New repository**, name it `jerseywala`, and set it to **Private**.
   - Follow GitHub's "push an existing repository" steps in your terminal:
     ```
     git init
     git add .
     git commit -m "JerseyWala store"
     git branch -M main
     git remote add origin https://github.com/YOUR-USERNAME/jerseywala.git
     git push -u origin main
     ```
   - Your `.env.local` is **not** uploaded (it is listed in `.gitignore`). That is intentional.
3. On Vercel click **Add New → Project**, pick your `jerseywala` repo and click **Import**.
4. Under **Environment Variables**, add these (same names as `.env.local`):
   | Name | Value |
   |---|---|
   | `NEXT_PUBLIC_SUPABASE_URL` | your Supabase Project URL |
   | `NEXT_PUBLIC_SUPABASE_ANON_KEY` | your anon/public key |
   | `NEXT_PUBLIC_SITE_URL` | your final address, e.g. `https://jerseywala.pk` (or the Vercel address for now) |
   | `NEXT_PUBLIC_INSTAGRAM_USERNAME` | your Instagram username |
5. Click **Deploy**. After a minute you get a link like `jerseywala.vercel.app`.
6. Tell Supabase your website address: **Authentication → URL Configuration** → set **Site URL** to your Vercel (or final) address. Save.
7. Open `https://YOUR-SITE/admin` and log in.

### Using your own domain (jerseywala.pk)
In Vercel: **Project → Settings → Domains → Add** `jerseywala.pk`. Vercel shows the DNS records to add at wherever you bought the domain (usually an **A record** for `@` and a **CNAME** for `www`). It can take from a few minutes up to a day. After it works, update `NEXT_PUBLIC_SITE_URL` in Vercel and **Redeploy**.

### Updating the website later
Changes to products and settings go live instantly from `/admin`. Only changes to the code need a `git push`, and Vercel redeploys on its own.

## Part 6 — Project map

```
app/
  (site)/            public pages: home, shop, product/[slug], about, contact
  admin/login        admin login page
  admin/(panel)/     dashboard, products, products/new, products/[id], categories, settings
components/          reusable pieces (OrderPanel.js = the Instagram order button)
lib/                 helpers + Supabase connections
middleware.js        redirects logged-out visitors away from /admin
supabase/schema.sql  database + security setup (run first)
supabase/seed.sql    optional demo products
```

## Part 7 — Troubleshooting

| Problem | Fix |
|---|---|
| Website shows "Almost there!" | `.env.local` is missing or wrong. Re-check Part 3 step 4, then restart `npm run dev`. |
| Can log in but see "Not authorised" | You skipped step 2c-4 (the `insert into public.admins` SQL), or the email there differs from your login email. |
| "Wrong email or password" | In Supabase → Authentication → Users, check the user exists and is confirmed. Reset the password there if needed. |
| Dashboard says "Could not load products" | `schema.sql` didn't run fully. Run it again (it is safe to re-run). |
| Photo upload fails | Make sure the file is JPG/PNG/WEBP under 5 MB, and that `schema.sql` created the `product-images` bucket (Supabase → Storage). |
| Product doesn't show in the shop | In Edit, check "Visible in the shop" is on. |
| Instagram doesn't open | Customers can use the **Open Instagram chat** button in the pop-up or the profile link. Check the username in Store Settings. |
| `npm install` errors | Make sure Node.js is version 18.17 or newer (`node -v`). |

## Part 8 — Test checklist (run this once after setup)

1. Log in at `/admin`.
2. **Add Product:** fill the form with 2 photos, price 5000, sale price 4200, sizes S–XL, stock 5, Featured = Yes. Click **Publish Product**.
3. Open the website → **Shop**. The jersey appears with a `-16%` badge. Search for its name and filter by its club.
4. Open the jersey page. Check the gallery, price, and "Only 5 left".
5. Pick size **L**, quantity **2**, and click **Order via Instagram**.
6. Instagram opens in a new tab. In the pop-up, check the message shows the right product, price, size and quantity. Tap **Copy message**, paste it into the Instagram chat.
7. In admin, **Edit** the product: change the price and mark it **sold out**. Refresh the website and check that the new price shows and the button says **Sold Out**.
8. **Delete** the product (confirm). It disappears from the shop.
9. Try opening `/admin` in a private/incognito window. You should be sent to the login page.

If all nine steps pass, your store is ready.
--------------------------------------------------------------------
