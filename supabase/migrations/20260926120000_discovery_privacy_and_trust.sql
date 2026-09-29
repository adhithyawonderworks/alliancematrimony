ALTER TABLE public.matrimony_profiles
  ADD COLUMN IF NOT EXISTS profile_visible BOOLEAN NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS photo_visibility TEXT NOT NULL DEFAULT 'public'
    CHECK (photo_visibility IN ('public', 'verified', 'matches', 'private')),
  ADD COLUMN IF NOT EXISTS horoscope_star TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS horoscope_rasi TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS horoscope_birth_time TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS profile_managed_by TEXT NOT NULL DEFAULT 'self'
    CHECK (profile_managed_by IN ('self', 'parent', 'guardian', 'relative'));

CREATE TABLE IF NOT EXISTS public.saved_profiles (
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  saved_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, saved_user_id),
  CHECK (user_id <> saved_user_id)
);

ALTER TABLE public.saved_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "users_manage_own_saved_profiles" ON public.saved_profiles;
CREATE POLICY "users_manage_own_saved_profiles"
  ON public.saved_profiles FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE TABLE IF NOT EXISTS public.blocked_users (
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  blocked_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, blocked_user_id),
  CHECK (user_id <> blocked_user_id)
);

ALTER TABLE public.blocked_users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "users_manage_own_blocked_users" ON public.blocked_users;
CREATE POLICY "users_manage_own_blocked_users"
  ON public.blocked_users FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE TABLE IF NOT EXISTS public.photo_verification_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  photo_url TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'approved', 'rejected')),
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reviewed_at TIMESTAMPTZ,
  reviewer_note TEXT NOT NULL DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_photo_verification_user_status
  ON public.photo_verification_requests(user_id, status);
ALTER TABLE public.photo_verification_requests ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "users_create_photo_verification_requests"
  ON public.photo_verification_requests;
CREATE POLICY "users_create_photo_verification_requests"
  ON public.photo_verification_requests FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid() AND status = 'pending');
DROP POLICY IF EXISTS "users_view_own_photo_verification_requests"
  ON public.photo_verification_requests;
CREATE POLICY "users_view_own_photo_verification_requests"
  ON public.photo_verification_requests FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE OR REPLACE FUNCTION public.discover_matrimony_profiles()
RETURNS TABLE (
  user_id UUID,
  first_name TEXT,
  last_name TEXT,
  age INTEGER,
  gender TEXT,
  job TEXT,
  education TEXT,
  place TEXT,
  height_cm TEXT,
  religion TEXT,
  caste TEXT,
  mother_tongue TEXT,
  image_url TEXT,
  is_verified BOOLEAN,
  created_at TIMESTAMPTZ,
  horoscope_star TEXT,
  horoscope_rasi TEXT
)
LANGUAGE SQL
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    p.user_id,
    p.first_name,
    CASE WHEN COALESCE(p.last_name, '') = '' THEN ''
      ELSE LEFT(p.last_name, 1) || '***' END,
    p.age,
    p.gender,
    p.job,
    p.education,
    p.place,
    p.height_cm,
    p.religion,
    p.caste,
    p.mother_tongue,
    CASE
      WHEN p.photo_visibility = 'private' THEN ''
      WHEN p.photo_visibility = 'verified'
        AND auth.jwt() ->> 'phone_confirmed_at' IS NULL THEN ''
      WHEN p.photo_visibility = 'matches' AND NOT EXISTS (
        SELECT 1 FROM public.interests i
        WHERE i.sender_id = auth.uid()
          AND i.receiver_id = p.user_id
          AND i.status = 'accepted'
          AND EXISTS (
            SELECT 1 FROM public.interests reciprocal
            WHERE reciprocal.sender_id = p.user_id
              AND reciprocal.receiver_id = auth.uid()
              AND reciprocal.status = 'accepted'
          )
      ) THEN ''
      ELSE COALESCE(p.image_url, '')
    END,
    p.is_verified,
    p.created_at,
    p.horoscope_star,
    p.horoscope_rasi
  FROM public.matrimony_profiles p
  WHERE auth.uid() IS NOT NULL
    AND p.user_id <> auth.uid()
    AND p.profile_visible = true
    AND (p.gender = '' OR NOT EXISTS (
      SELECT 1 FROM public.matrimony_profiles own
      WHERE own.user_id = auth.uid()
        AND own.gender <> ''
        AND own.gender = p.gender
    ))
    AND NOT EXISTS (
      SELECT 1 FROM public.blocked_users b
      WHERE (b.user_id = auth.uid() AND b.blocked_user_id = p.user_id)
         OR (b.user_id = p.user_id AND b.blocked_user_id = auth.uid())
    )
  ORDER BY p.updated_at DESC NULLS LAST;
$$;

REVOKE ALL ON FUNCTION public.discover_matrimony_profiles() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.discover_matrimony_profiles() TO authenticated;

CREATE OR REPLACE FUNCTION public.prevent_self_verification()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
  IF COALESCE(auth.role(), '') <> 'service_role' AND TG_OP = 'INSERT'
     AND NEW.is_verified IS TRUE THEN
    RAISE EXCEPTION 'Profile verification can only be changed by an administrator';
  ELSIF COALESCE(auth.role(), '') <> 'service_role' AND TG_OP = 'UPDATE'
     AND NEW.is_verified IS DISTINCT FROM OLD.is_verified THEN
    RAISE EXCEPTION 'Profile verification can only be changed by an administrator';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_prevent_self_verification
  ON public.matrimony_profiles;
CREATE TRIGGER trg_prevent_self_verification
  BEFORE INSERT OR UPDATE OF is_verified ON public.matrimony_profiles
  FOR EACH ROW EXECUTE FUNCTION public.prevent_self_verification();

ALTER TABLE public.chat_messages
  ADD COLUMN IF NOT EXISTS is_read BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS read_at TIMESTAMPTZ;

DROP POLICY IF EXISTS "users_mark_received_messages_read"
  ON public.chat_messages;
CREATE POLICY "users_mark_received_messages_read"
  ON public.chat_messages FOR UPDATE TO authenticated
  USING (
    sender_id <> auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.chat_conversations cc
      WHERE cc.id = conversation_id
        AND (cc.participant_one = auth.uid() OR cc.participant_two = auth.uid())
    )
  )
  WITH CHECK (
    sender_id <> auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.chat_conversations cc
      WHERE cc.id = conversation_id
        AND (cc.participant_one = auth.uid() OR cc.participant_two = auth.uid())
    )
  );