ALTER TABLE public.matrimony_profiles
  ADD COLUMN IF NOT EXISTS school_name TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS college_name TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS university_name TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS current_city_same_as_primary_address BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS primary_address TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS primary_address_stay_period TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS partner_age_min TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS partner_age_max TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS partner_height_cm TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS partner_height_feet TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS partner_height_inches TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS partner_religion_mode TEXT NOT NULL DEFAULT 'any_religion',
  ADD COLUMN IF NOT EXISTS partner_caste TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS partner_location_mode TEXT NOT NULL DEFAULT 'Anywhere in the world',
  ADD COLUMN IF NOT EXISTS partner_state TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS partner_district TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS partner_country TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS partner_language TEXT NOT NULL DEFAULT 'No preference',
  ADD COLUMN IF NOT EXISTS partner_languages TEXT NOT NULL DEFAULT '';

INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-photos', 'profile-photos', true)
ON CONFLICT (id) DO UPDATE SET public = true;

DROP POLICY IF EXISTS "public_can_view_profile_photos" ON storage.objects;
CREATE POLICY "public_can_view_profile_photos"
ON storage.objects FOR SELECT
USING (bucket_id = 'profile-photos');

DROP POLICY IF EXISTS "users_upload_own_profile_photos" ON storage.objects;
CREATE POLICY "users_upload_own_profile_photos"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'profile-photos'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

DROP POLICY IF EXISTS "users_update_own_profile_photos" ON storage.objects;
CREATE POLICY "users_update_own_profile_photos"
ON storage.objects FOR UPDATE TO authenticated
USING (
  bucket_id = 'profile-photos'
  AND (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
  bucket_id = 'profile-photos'
  AND (storage.foldername(name))[1] = auth.uid()::text
);