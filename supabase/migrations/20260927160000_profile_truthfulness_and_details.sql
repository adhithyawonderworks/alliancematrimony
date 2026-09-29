ALTER TABLE public.matrimony_profiles
  ADD COLUMN IF NOT EXISTS pincode TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS complexion TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS parents_contact TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS truthfulness_confirmed BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS truthfulness_confirmed_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS address_verified BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS address_verification_status TEXT NOT NULL DEFAULT 'not_submitted'
    CHECK (address_verification_status IN ('not_submitted', 'pending', 'approved', 'rejected'));

CREATE TABLE IF NOT EXISTS public.address_verification_documents (
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL CHECK (document_type IN ('aadhaar', 'driving_license')),
  front_object_path TEXT NOT NULL,
  back_object_path TEXT NOT NULL,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id)
);

CREATE TABLE IF NOT EXISTS public.profile_truthfulness_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  accepted_at TIMESTAMPTZ NOT NULL,
  agreement_version TEXT NOT NULL,
  profile_snapshot JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.profile_truthfulness_submissions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "users_submit_truthfulness_acceptance"
  ON public.profile_truthfulness_submissions;
CREATE POLICY "users_submit_truthfulness_acceptance"
  ON public.profile_truthfulness_submissions FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());
DROP POLICY IF EXISTS "users_view_truthfulness_acceptance"
  ON public.profile_truthfulness_submissions;
CREATE POLICY "users_view_truthfulness_acceptance"
  ON public.profile_truthfulness_submissions FOR SELECT TO authenticated
  USING (user_id = auth.uid());

ALTER TABLE public.address_verification_documents ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "users_manage_own_address_verification_documents"
  ON public.address_verification_documents;
CREATE POLICY "users_manage_own_address_verification_documents"
  ON public.address_verification_documents FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE OR REPLACE FUNCTION public.prevent_self_address_verification()
RETURNS TRIGGER
LANGUAGE PLPGSQL
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF COALESCE(auth.role(), '') <> 'service_role' THEN
    IF TG_OP = 'INSERT' AND (
      NEW.address_verified IS TRUE
      OR NEW.address_verification_status <> 'not_submitted'
    ) THEN
      RAISE EXCEPTION 'Address verification can only be approved by an administrator';
    END IF;
    IF TG_OP = 'UPDATE' AND (
      NEW.address_verified IS DISTINCT FROM OLD.address_verified
      OR (NEW.address_verification_status IS DISTINCT FROM OLD.address_verification_status
          AND (NEW.address_verification_status <> 'pending'
               OR NOT EXISTS (
                 SELECT 1 FROM public.address_verification_documents d
                 WHERE d.user_id = NEW.user_id
               )))
    ) THEN
      RAISE EXCEPTION 'Address verification can only be approved by an administrator';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_prevent_self_address_verification
  ON public.matrimony_profiles;
CREATE TRIGGER trg_prevent_self_address_verification
  BEFORE INSERT OR UPDATE OF address_verified, address_verification_status
  ON public.matrimony_profiles
  FOR EACH ROW EXECUTE FUNCTION public.prevent_self_address_verification();

INSERT INTO storage.buckets (id, name, public)
VALUES ('address-verification', 'address-verification', false)
ON CONFLICT (id) DO UPDATE SET public = false;

DROP POLICY IF EXISTS "users_manage_own_address_verification_files"
  ON storage.objects;
CREATE POLICY "users_manage_own_address_verification_files"
  ON storage.objects FOR ALL TO authenticated
  USING (
    bucket_id = 'address-verification'
    AND (storage.foldername(name))[1] = auth.uid()::text
  )
  WITH CHECK (
    bucket_id = 'address-verification'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

UPDATE public.matrimony_profiles
SET photo_visibility = 'matches'
WHERE photo_visibility = 'verified';

CREATE OR REPLACE FUNCTION public.get_connected_matrimony_profile(
  target_user_id UUID
)
RETURNS JSONB
LANGUAGE SQL
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT jsonb_build_object(
    'first_name', p.first_name,
    'last_name', CASE WHEN COALESCE(p.last_name, '') = '' THEN ''
      ELSE LEFT(p.last_name, 1) || '***' END,
    'age', p.age,
    'gender', p.gender,
    'job', p.job,
    'education', p.education,
    'place', p.place,
    'height_cm', p.height_cm,
    'image_url', CASE WHEN p.photo_visibility = 'private' THEN ''
      ELSE COALESCE(p.image_url, '') END,
    'is_verified', p.is_verified,
    'horoscope_star', p.horoscope_star,
    'horoscope_rasi', p.horoscope_rasi,
    'complexion', p.complexion,
    'address_verified', p.address_verified
  )
  FROM public.matrimony_profiles p
  WHERE p.user_id = target_user_id
    AND auth.uid() IS NOT NULL
    AND (
      EXISTS (
        SELECT 1 FROM public.interests i
        WHERE (i.sender_id = auth.uid() AND i.receiver_id = target_user_id)
           OR (i.sender_id = target_user_id AND i.receiver_id = auth.uid())
      )
      OR EXISTS (
        SELECT 1 FROM public.chat_conversations c
        WHERE (c.participant_one = auth.uid() AND c.participant_two = target_user_id)
           OR (c.participant_one = target_user_id AND c.participant_two = auth.uid())
      )
    );
$$;

REVOKE ALL ON FUNCTION public.get_connected_matrimony_profile(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_connected_matrimony_profile(UUID)
  TO authenticated;