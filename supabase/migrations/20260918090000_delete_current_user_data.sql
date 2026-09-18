-- Delete the authenticated user's complete application and Auth data.
-- The function is intentionally security definer so RLS cannot leave orphaned rows.
CREATE OR REPLACE FUNCTION public.delete_my_account_data()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  deleting_user_id UUID := auth.uid();
BEGIN
  IF deleting_user_id IS NULL THEN
    RAISE EXCEPTION 'You must be signed in to delete your account';
  END IF;

  DELETE FROM public.chat_messages
  WHERE sender_id = deleting_user_id
     OR conversation_id IN (
       SELECT id
       FROM public.chat_conversations
       WHERE participant_one = deleting_user_id
          OR participant_two = deleting_user_id
     );

  DELETE FROM public.chat_conversations
  WHERE participant_one = deleting_user_id
     OR participant_two = deleting_user_id;

  DELETE FROM public.interests
  WHERE sender_id = deleting_user_id
     OR receiver_id = deleting_user_id;

  DELETE FROM public.user_reports
  WHERE reporter_id = deleting_user_id
     OR reported_user_id = deleting_user_id;

  DELETE FROM public.premium_purchases WHERE user_id = deleting_user_id;
  DELETE FROM public.push_notification_tokens WHERE user_id = deleting_user_id;
  DELETE FROM public.notifications WHERE user_id = deleting_user_id;
  DELETE FROM public.matrimony_profiles WHERE user_id = deleting_user_id;

  DELETE FROM auth.users WHERE id = deleting_user_id;
END;
$$;

REVOKE ALL ON FUNCTION public.delete_my_account_data() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.delete_my_account_data() TO authenticated;
