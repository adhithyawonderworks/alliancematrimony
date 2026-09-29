DROP FUNCTION IF EXISTS public.discover_matrimony_profiles();
CREATE FUNCTION public.discover_matrimony_profiles()
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
  horoscope_rasi TEXT,
  address_verified BOOLEAN
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
    p.horoscope_rasi,
    p.address_verified
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

DROP POLICY IF EXISTS "interests_sender_resend_declined" ON public.interests;
CREATE POLICY "interests_sender_resend_declined"
  ON public.interests FOR UPDATE TO authenticated
  USING (sender_id = auth.uid() AND status = 'declined')
  WITH CHECK (sender_id = auth.uid() AND status = 'pending');