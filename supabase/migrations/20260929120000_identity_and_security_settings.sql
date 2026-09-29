ALTER TABLE public.matrimony_profiles
  ADD COLUMN IF NOT EXISTS other_name TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS aadhar_name TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS aadhar_image_url TEXT NOT NULL DEFAULT '',
  -- Aadhar review lifecycle: not_submitted -> pending -> verified | rejected.
  ADD COLUMN IF NOT EXISTS aadhar_verification_status TEXT NOT NULL DEFAULT 'not_submitted',
  -- Set true only by admin/back-office review (see trg_prevent_self_verification pattern for is_verified).
  ADD COLUMN IF NOT EXISTS aadhar_verified BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS passcode_hash TEXT,
  ADD COLUMN IF NOT EXISTS biometric_enabled BOOLEAN NOT NULL DEFAULT false;

-- Mirror the existing prevent_self_verification protection: clients may submit an
-- Aadhar name/image and move status to 'pending', but must never set aadhar_verified
-- themselves — only an admin using the service_role key can do that.
CREATE OR REPLACE FUNCTION public.prevent_self_aadhar_verification()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
  IF COALESCE(auth.role(), '') <> 'service_role' AND TG_OP = 'INSERT'
     AND NEW.aadhar_verified IS TRUE THEN
    RAISE EXCEPTION 'Aadhar verification can only be changed by an administrator';
  ELSIF COALESCE(auth.role(), '') <> 'service_role' AND TG_OP = 'UPDATE'
     AND NEW.aadhar_verified IS DISTINCT FROM OLD.aadhar_verified THEN
    RAISE EXCEPTION 'Aadhar verification can only be changed by an administrator';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_prevent_self_aadhar_verification
  ON public.matrimony_profiles;
CREATE TRIGGER trg_prevent_self_aadhar_verification
  BEFORE INSERT OR UPDATE OF aadhar_verified ON public.matrimony_profiles
  FOR EACH ROW EXECUTE FUNCTION public.prevent_self_aadhar_verification();

-- Aadhar images are sensitive identity documents: private bucket, owner-only access.
INSERT INTO storage.buckets (id, name, public)
VALUES ('identity-documents', 'identity-documents', false)
ON CONFLICT (id) DO UPDATE SET public = false;

DROP POLICY IF EXISTS "users_manage_own_identity_documents" ON storage.objects;
CREATE POLICY "users_manage_own_identity_documents"
ON storage.objects FOR ALL TO authenticated
USING (
  bucket_id = 'identity-documents'
  AND (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
  bucket_id = 'identity-documents'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

