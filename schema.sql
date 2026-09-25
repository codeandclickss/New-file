-- ============================================================
-- Shubh Digital Marketing — Supabase Schema
-- Run this whole file once in: Supabase Dashboard → SQL Editor → New query
-- ============================================================

-- ------------------------------------------------------------
-- 1. SITE SETTINGS (singleton row — business info + hero text)
-- ------------------------------------------------------------
create table if not exists public.site_settings (
  id int primary key default 1,
  business_name text not null default 'SHUBH',
  business_tagline text not null default 'DIGITAL MARKETING',
  phone_display text not null default '88068 84931',
  phone_tel text not null default '+918806884931',
  email text not null default 'hello@shubhdigital.in',
  hero_eyebrow text default 'Full-service SEO & Paid Media Agency, based in India',
  hero_headline1 text default 'Rocket your ranking.',
  hero_headline2 text default 'Own page one.',
  hero_subtext text default 'Shubh Digital Marketing builds the SEO foundation and runs the paid campaigns that bring the right customers to your door.',
  services_intro text default 'From ranking on Google to running the ads that sell — SEO, Google Ads, Meta Ads, local & maps visibility, content, websites and reporting, all handled under one roof.',
  social_instagram text,
  social_facebook text,
  social_linkedin text,
  social_youtube text,
  updated_at timestamptz not null default now(),
  constraint single_row check (id = 1)
);

insert into public.site_settings (id) values (1)
  on conflict (id) do nothing;

-- ------------------------------------------------------------
-- 2. CONTENT ITEMS (hero stats, result stats, pricing, testimonials)
-- ------------------------------------------------------------
create table if not exists public.content_items (
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in ('hero_stat', 'result_stat', 'pricing', 'testimonial')),

  -- generic fields, reused differently depending on "type":
  title text,            -- stats: the number (e.g. "20+") · pricing: package name · testimonial: client name
  subtitle text,         -- stats: the label · pricing: billing cycle · testimonial: tag line
  body text,             -- pricing: description · testimonial: quote
  price text,            -- pricing only, e.g. "₹15,000"
  features jsonb,        -- pricing only, array of strings e.g. ["Feature 1","Feature 2"]
  featured boolean not null default false,   -- pricing: highlight this package
  avatar_initial text,   -- testimonial only, single letter
  avatar_color text,     -- testimonial only, hex color e.g. "#4A3899"

  sort_order int not null default 0,
  status text not null default 'draft' check (status in ('draft', 'published')),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists content_items_type_status_idx
  on public.content_items (type, status, sort_order);

-- ------------------------------------------------------------
-- 3. Keep updated_at fresh automatically
-- ------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_site_settings_updated on public.site_settings;
create trigger trg_site_settings_updated
  before update on public.site_settings
  for each row execute function public.set_updated_at();

drop trigger if exists trg_content_items_updated on public.content_items;
create trigger trg_content_items_updated
  before update on public.content_items
  for each row execute function public.set_updated_at();

-- ------------------------------------------------------------
-- 4. ROW LEVEL SECURITY
--    Public visitors (anon) can only READ published content.
--    Logged-in users (authenticated) = admins, full access.
--    There is no public sign-up anywhere in this project, so any
--    authenticated user is, by design, an admin you invited yourself.
-- ------------------------------------------------------------
alter table public.site_settings enable row level security;
alter table public.content_items enable row level security;

create policy "Public can read site settings"
  on public.site_settings for select
  to anon
  using (true);

create policy "Admins can read site settings"
  on public.site_settings for select
  to authenticated
  using (true);

create policy "Admins can update site settings"
  on public.site_settings for update
  to authenticated
  using (true) with check (true);

create policy "Public can read published content"
  on public.content_items for select
  to anon
  using (status = 'published');

create policy "Admins can read all content"
  on public.content_items for select
  to authenticated
  using (true);

create policy "Admins can insert content"
  on public.content_items for insert
  to authenticated
  with check (true);

create policy "Admins can update content"
  on public.content_items for update
  to authenticated
  using (true) with check (true);

create policy "Admins can delete content"
  on public.content_items for delete
  to authenticated
  using (true);

-- ------------------------------------------------------------
-- 5. STORAGE BUCKET for uploaded images/files
-- ------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('site-media', 'site-media', true)
on conflict (id) do nothing;

create policy "Public can view site media"
  on storage.objects for select
  to public
  using (bucket_id = 'site-media');

create policy "Admins can upload site media"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'site-media');

create policy "Admins can update site media"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'site-media');

create policy "Admins can delete site media"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'site-media');

-- ------------------------------------------------------------
-- 6. SEED DATA — your current content, migrated in
--    (safe to re-run: uses a guard so it won't duplicate)
-- ------------------------------------------------------------
do $$
begin
  if not exists (select 1 from public.content_items where type = 'hero_stat') then
    insert into public.content_items (type, title, subtitle, sort_order, status) values
      ('hero_stat', '20+', 'brands grown', 1, 'published'),
      ('hero_stat', '4.9/5', 'average client rating', 2, 'published'),
      ('hero_stat', '3.2x', 'average lead growth', 3, 'published');
  end if;

  if not exists (select 1 from public.content_items where type = 'result_stat') then
    insert into public.content_items (type, title, subtitle, sort_order, status) values
      ('result_stat', '20+', 'businesses served', 1, 'published'),
      ('result_stat', '3.2x', 'avg. increase in leads', 2, 'published'),
      ('result_stat', '4.8x', 'avg. return on ad spend', 3, 'published'),
      ('result_stat', '92%', 'clients renew past month 3', 4, 'published');
  end if;

  if not exists (select 1 from public.content_items where type = 'pricing') then
    insert into public.content_items (type, title, subtitle, body, price, features, featured, sort_order, status) values
      ('pricing', 'Basic Package', 'per month',
        'For local businesses that want to show up when nearby customers search.',
        '₹10,000',
        '["Local & Google Maps SEO","On-page SEO for up to 10 pages","Monthly ranking report"]'::jsonb,
        false, 1, 'published'),
      ('pricing', 'Growth', 'per month',
        'SEO plus a managed Google & Meta Ads engine — our most popular plan.',
        '₹15,000',
        '["Everything in Basic Package","Google Ads & Meta Ads management","Landing page build & testing","Bi-weekly strategy call"]'::jsonb,
        true, 2, 'published'),
      ('pricing', 'Scale', 'per month',
        'For businesses ready to expand across cities, categories or platforms.',
        '₹20,000',
        '["Everything in Growth","Multi-city / multi-location SEO","Dedicated account manager","Weekly reporting"]'::jsonb,
        false, 3, 'published');
  end if;

  if not exists (select 1 from public.content_items where type = 'testimonial') then
    insert into public.content_items (type, title, subtitle, body, avatar_initial, avatar_color, sort_order, status) values
      ('testimonial', 'Sandeep Phadatare', 'Shoe Racks — Meta Ads campaign',
        'One single Meta Ads campaign for our shoe racks brought in a minimum of 400 leads and took our sales up 8x. We did not expect numbers like this.',
        'S', '#4A3899', 1, 'published'),
      ('testimonial', 'Suraj PV Solar', 'Solar Panels — Google Ads campaign',
        'Solar panels are a high-consideration purchase, so we needed serious search intent, not just clicks. The Google Ads campaigns brought in genuine, ready-to-buy enquiries every week.',
        'S', '#FF5A52', 2, 'published'),
      ('testimonial', 'Excellent Display Racks', 'Medical & Retail Store Racks — Meta Ads campaign',
        'We sell display racks for medical and retail stores — a niche market. The Meta Ads campaigns put us in front of the right shop owners and enquiries have been steady ever since.',
        'E', '#FFC93C', 3, 'published');
  end if;
end $$;
