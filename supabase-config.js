// ============================================================
// Supabase connection settings
// ============================================================
// These two values come from: Supabase Dashboard → Project Settings → API
//   - Project URL           → paste into SUPABASE_URL
//   - anon / public API key → paste into SUPABASE_ANON_KEY
//
// NOTE: the "anon" key is NOT a secret. It is a public, restricted key
// designed to be shipped in client-side code — Supabase's own docs use it
// this way. All real protection comes from the Row Level Security (RLS)
// policies defined in supabase/schema.sql, which only let logged-in admin
// users write data, and only let everyone else read published content.
// Never put your "service_role" key here or anywhere in this project.
// ============================================================

window.SUPABASE_URL = "https://alvdqdajobdidiwpcxum.supabase.co";
window.SUPABASE_ANON_KEY = "sb_publishable_YHeQIujjd4hg3gkBWVO6Yg_fzMtdQDV";
