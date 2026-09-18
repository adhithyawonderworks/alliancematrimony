-- Matrimony Profiles Table Migration
-- Stores personal, family, and partner preference data for matrimony profiles

CREATE TABLE IF NOT EXISTS public.matrimony_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    first_name TEXT DEFAULT '',
    last_name TEXT DEFAULT '',
    age INTEGER DEFAULT 0,
    gender TEXT DEFAULT '',
    dob TEXT DEFAULT '',
    job TEXT DEFAULT '',
    education TEXT DEFAULT '',
    place TEXT DEFAULT '',
    height_cm TEXT DEFAULT '',
    weight_kg TEXT DEFAULT '',
    religion TEXT DEFAULT '',
    caste TEXT DEFAULT '',
    mother_tongue TEXT DEFAULT '',
    facebook_link TEXT DEFAULT '',
    parents_name TEXT DEFAULT '',
    parents_job TEXT DEFAULT '',
    phone TEXT DEFAULT '',
    image_url TEXT DEFAULT '',
    is_paid BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    referral_code TEXT DEFAULT '',
    referral_count INTEGER DEFAULT 0,
    referral_credits INTEGER DEFAULT 0,
    partner_age_range TEXT DEFAULT '',
    partner_height_range TEXT DEFAULT '',
    partner_religion TEXT DEFAULT '',
    partner_place TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_matrimony_profiles_user_id ON public.matrimony_profiles(user_id);

-- Function to auto-update updated_at
CREATE OR REPLACE FUNCTION public.update_matrimony_profile_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_matrimony_profiles_updated_at ON public.matrimony_profiles;
CREATE TRIGGER trg_matrimony_profiles_updated_at
    BEFORE UPDATE ON public.matrimony_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.update_matrimony_profile_updated_at();

ALTER TABLE public.matrimony_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users_manage_own_matrimony_profiles" ON public.matrimony_profiles;
CREATE POLICY "users_manage_own_matrimony_profiles"
ON public.matrimony_profiles
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());
