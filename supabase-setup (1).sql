-- =============================================
-- NEW AGE AI — MARKETING HUB DATABASE SETUP
-- Run this entire script in your Supabase
-- SQL Editor: https://supabase.com/dashboard/project/xvucakstcmtfoanmgcql/sql
-- =============================================

-- 1. PROFILES TABLE (extends auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id         UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email      TEXT,
  full_name  TEXT,
  role       TEXT DEFAULT 'user',   -- 'user' | 'admin'
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_seen  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Admins view all profiles"
  ON public.profiles FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'
  ));

CREATE POLICY "Users update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Admins update any profile"
  ON public.profiles FOR UPDATE
  USING (EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'
  ));

-- 2. TEMPLATE USAGE TABLE
CREATE TABLE IF NOT EXISTS public.template_usage (
  id                 UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id            UUID REFERENCES auth.users(id),
  user_email         TEXT,
  template_id        TEXT,
  template_title     TEXT,
  template_category  TEXT,
  created_at         TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.template_usage ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users insert own usage"
  ON public.template_usage FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users view own usage"
  ON public.template_usage FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admins view all usage"
  ON public.template_usage FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'
  ));

-- 3. APP SETTINGS TABLE (for Anthropic API key etc.)
CREATE TABLE IF NOT EXISTS public.app_settings (
  key        TEXT PRIMARY KEY,
  value      TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users read settings"
  ON public.app_settings FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admins manage settings"
  ON public.app_settings FOR ALL
  USING (EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'
  ));

-- 4. TRIGGER — auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 5. MAKE YOURSELF ADMIN
-- Run this after signing up through the app:
UPDATE public.profiles SET role = 'admin' WHERE email = 'rawlanitanishka@gmail.com';

-- =============================================
-- DONE! Now open the webapp and sign up with
-- your email. Then run the UPDATE above to
-- grant yourself admin access.
-- =============================================
