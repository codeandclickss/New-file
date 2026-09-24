# Shubh Digital Marketing — Website + Supabase Admin Panel

A real admin backend for your website: Supabase Auth for login, a Postgres
database for your content, Supabase Storage for images, and a dashboard at
`/admin` to manage everything — content items (with draft/publish), images,
and site settings. No coding needed after setup.

---

## What's in this folder
```
index.html            → your public website (now loads content from Supabase)
supabase-config.js     → your Supabase connection details (fill this in — see Step 2)
netlify.toml            → makes /admin work correctly on Netlify (no more 404)
robots.txt, sitemap.xml → SEO files
admin/
  index.html           → the admin login + dashboard app
supabase/
  schema.sql            → run this once inside Supabase to create everything
```

`content.json` from the old setup is **no longer used** by the live site —
you can delete it, or keep it as a backup of your original content.

---

## PART 1 — Create your Supabase project (5 minutes)

1. Go to **https://supabase.com** and sign up / log in (free tier is enough).
2. Click **New Project**. Pick any name (e.g. `shubh-digital-marketing`),
   set a database password (save it somewhere safe), pick a region close to
   India, and click **Create new project**. Wait ~1-2 minutes for it to spin up.

### Run the database schema
1. In your new project, open the **SQL Editor** (left sidebar).
2. Click **New query**.
3. Open `supabase/schema.sql` from this folder, copy the **entire file**,
   paste it into the SQL editor, and click **Run**.
4. You should see "Success. No rows returned." This created:
   - `site_settings` table (your business info + hero text)
   - `content_items` table (stats, pricing, testimonials)
   - Security rules (RLS) so only logged-in admins can edit anything
   - A `site-media` storage bucket for images
   - Your current content, pre-loaded in as a starting point

### Get your API keys
1. Go to **Project Settings → API** (gear icon, bottom of left sidebar).
2. Copy the **Project URL** and the **anon / public** key.
   (These are safe to use in client-side code — see the note inside
   `supabase-config.js` for why.)

---

## PART 2 — Connect the website to Supabase

1. Open `supabase-config.js` in this folder.
2. Replace the two placeholder values with the Project URL and anon key
   you just copied:
   ```js
   window.SUPABASE_URL = "https://xxxxxxxx.supabase.co";
   window.SUPABASE_ANON_KEY = "eyJhbGciOi...";
   ```
3. Save the file.

---

## PART 3 — Create your first (and only) admin login

There is no public sign-up page anywhere in this project — that's
intentional, for security. You create your own login directly in Supabase:

1. In Supabase, go to **Authentication → Users**.
2. Click **Add user → Create new user**.
3. Enter your email and a password. Tick **Auto Confirm User** (so you don't
   need to click an email link).
4. Click **Create user**.

That email + password is what you'll use to log into `/admin`.

---

## PART 4 — Upload everything to GitHub

1. Go to your existing repo:
   `github.com/suttarkar1998-cmy/Shubh-Digital-Marketing`
2. Delete anything left over from the old setup: `shubh-website.zip`,
   the old `admin/config.yml` file (Decap CMS — no longer used).
3. Upload every file from this folder to the repo root, **preserving the
   folder structure** — `admin/` and `supabase/` must stay as folders, not
   get flattened. Easiest way: unzip this bundle locally, then drag the
   whole extracted folder onto GitHub's "Add file → Upload files" page in
   one go (see earlier guidance in this chat if you need the play-by-play).
4. Commit the changes.

---

## PART 5 — Deploy / redeploy on Netlify

If your Netlify site is already connected to this GitHub repo, it will
redeploy automatically within a minute of your GitHub commit — no extra
steps needed. `netlify.toml` (included here) is what fixes the
`/admin` → 404 problem you were seeing; Netlify picks it up automatically
on the next deploy.

If you want to double check: Netlify dashboard → **Deploys** tab → confirm
the latest deploy shows green/"Published".

---

## PART 6 — Log in and use your admin panel

1. Go to `https://your-site-name.netlify.app/admin`
2. Log in with the email/password you created in Part 3.
3. You'll land on **Overview** — a quick summary of your content.
4. **Content Management** → switch between Hero Stats / Result Stats /
   Pricing / Testimonials using the tabs. Click **+ Add New** to create,
   the pencil icon to edit, the eye icon to publish/unpublish, and the
   trash icon to delete. Changes save straight to the database.
5. **Image / File Management** → click **Upload Image**, pick a file, and
   it appears in the grid. Click **Copy** on any image to get its public
   URL (useful for pasting elsewhere), or the trash icon to delete it.
6. **Settings** → edit your business name, phone number, email, hero text,
   and social media links. Click **Save Settings**.
7. Any change you publish shows up on your live website within a few
   seconds — just refresh the site to see it.

---

## Good to know
- **Security model:** the `anon` key in `supabase-config.js` is public by
  design — real protection comes from the Row Level Security policies in
  `schema.sql`, which only let logged-in users (i.e. you) write data.
  Never create a second Supabase key called `service_role` and put it
  anywhere in this project — that one *is* secret and must never appear in
  client-side code.
- **Adding more admins later:** repeat Part 3 with a new email — every user
  you create in Supabase Authentication can log into `/admin`.
- **Forgot your password:** Supabase → Authentication → Users → click your
  user → **Send password recovery**, or just delete and recreate the user.
- Structural changes (new sections, layout, design, new SEO work like a
  blog) still go through me in this chat — the admin panel covers content,
  not code.
