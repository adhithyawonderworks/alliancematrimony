CREATE OR REPLACE FUNCTION public.enforce_daily_message_profile_limit()
RETURNS TRIGGER
LANGUAGE PLPGSQL
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  other_user_id UUID;
  messaged_profile_count INTEGER;
  day_start TIMESTAMPTZ := date_trunc('day', CURRENT_TIMESTAMP);
BEGIN
  IF auth.uid() IS NULL OR NEW.sender_id <> auth.uid() THEN
    RAISE EXCEPTION 'Messages can only be sent by the authenticated user';
  END IF;

  PERFORM pg_advisory_xact_lock(hashtextextended(NEW.sender_id::text, 0));

  SELECT CASE
      WHEN participant_one = NEW.sender_id THEN participant_two
      ELSE participant_one
    END
    INTO other_user_id
  FROM public.chat_conversations
  WHERE id = NEW.conversation_id
    AND (participant_one = NEW.sender_id OR participant_two = NEW.sender_id);

  IF other_user_id IS NULL THEN
    RAISE EXCEPTION 'Conversation participant not found';
  END IF;

  SELECT COUNT(DISTINCT CASE
      WHEN c.participant_one = NEW.sender_id THEN c.participant_two
      ELSE c.participant_one
    END)
    INTO messaged_profile_count
  FROM public.chat_messages m
  JOIN public.chat_conversations c ON c.id = m.conversation_id
  WHERE m.sender_id = NEW.sender_id
    AND m.created_at >= day_start
    AND m.created_at < day_start + INTERVAL '1 day';

  IF messaged_profile_count >= 2 AND NOT EXISTS (
    SELECT 1
    FROM public.chat_messages m
    JOIN public.chat_conversations c ON c.id = m.conversation_id
    WHERE m.sender_id = NEW.sender_id
      AND m.created_at >= day_start
      AND m.created_at < day_start + INTERVAL '1 day'
      AND (
        (c.participant_one = NEW.sender_id AND c.participant_two = other_user_id)
        OR (c.participant_two = NEW.sender_id AND c.participant_one = other_user_id)
      )
  ) THEN
    RAISE EXCEPTION 'Daily messaging limit reached: you can message at most two profiles per day';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_enforce_daily_message_profile_limit
  ON public.chat_messages;
CREATE TRIGGER trg_enforce_daily_message_profile_limit
  BEFORE INSERT ON public.chat_messages
  FOR EACH ROW EXECUTE FUNCTION public.enforce_daily_message_profile_limit();