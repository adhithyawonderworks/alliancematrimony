ALTER TABLE public.matrimony_profiles
  ADD COLUMN IF NOT EXISTS marital_status TEXT NOT NULL DEFAULT 'Single',
  ADD COLUMN IF NOT EXISTS partner_gender TEXT NOT NULL DEFAULT 'No preference',
  ADD COLUMN IF NOT EXISTS partner_marital_status TEXT NOT NULL DEFAULT 'No preference';

ALTER TABLE public.matrimony_profiles
  DROP CONSTRAINT IF EXISTS matrimony_profiles_profile_managed_by_check;

UPDATE public.matrimony_profiles
SET profile_managed_by = CASE profile_managed_by
  WHEN 'parent' THEN 'father'
  WHEN 'guardian' THEN 'mother'
  WHEN 'relative' THEN 'sibling'
  ELSE profile_managed_by
END
WHERE profile_managed_by IN ('parent', 'guardian', 'relative');

ALTER TABLE public.matrimony_profiles
  ADD CONSTRAINT matrimony_profiles_profile_managed_by_check
    CHECK (profile_managed_by IN ('self', 'father', 'mother', 'sibling')),
  ADD CONSTRAINT matrimony_profiles_marital_status_check
    CHECK (marital_status IN ('Single', 'Widowed', 'Divorced')),
  ADD CONSTRAINT matrimony_profiles_partner_gender_check
    CHECK (partner_gender IN ('Male', 'Female', 'No preference')),
  ADD CONSTRAINT matrimony_profiles_partner_marital_status_check
    CHECK (partner_marital_status IN ('Single', 'Widowed', 'Divorced', 'No preference'));