-- Migration: Reports, Purchases, and Notification Tokens
-- Timestamp: 20260717180000

-- ─── 1. User Reports Table ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reported_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  message TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_user_reports_reporter ON public.user_reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_user_reports_reported ON public.user_reports(reported_user_id);

ALTER TABLE public.user_reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users_can_create_reports" ON public.user_reports;
CREATE POLICY "users_can_create_reports"
ON public.user_reports
FOR INSERT
TO authenticated
WITH CHECK (reporter_id = auth.uid());

DROP POLICY IF EXISTS "users_can_view_own_reports" ON public.user_reports;
CREATE POLICY "users_can_view_own_reports"
ON public.user_reports
FOR SELECT
TO authenticated
USING (reporter_id = auth.uid());

-- ─── 2. Premium Purchases Table ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.premium_purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  purchase_type TEXT NOT NULL DEFAULT 'full_access',
  amount_inr INTEGER NOT NULL DEFAULT 500,
  payment_reference TEXT DEFAULT '',
  purchased_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  valid_until TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  invoice_number TEXT DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_premium_purchases_user ON public.premium_purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_premium_purchases_active ON public.premium_purchases(user_id, is_active);

ALTER TABLE public.premium_purchases ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users_manage_own_purchases" ON public.premium_purchases;
CREATE POLICY "users_manage_own_purchases"
ON public.premium_purchases
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- ─── 3. Push Notification Tokens Table ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.push_notification_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  platform TEXT DEFAULT 'android',
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_push_tokens_user_token ON public.push_notification_tokens(user_id, token);
CREATE INDEX IF NOT EXISTS idx_push_tokens_user ON public.push_notification_tokens(user_id);

ALTER TABLE public.push_notification_tokens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users_manage_own_tokens" ON public.push_notification_tokens;
CREATE POLICY "users_manage_own_tokens"
ON public.push_notification_tokens
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- ─── 4. Notifications Table ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON public.notifications(user_id, is_read);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users_manage_own_notifications" ON public.notifications;
CREATE POLICY "users_manage_own_notifications"
ON public.notifications
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- ─── 5. Function: Create notification on new match ───────────────────────────
CREATE OR REPLACE FUNCTION public.notify_on_match()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  sender_name TEXT;
  receiver_name TEXT;
BEGIN
  -- When an interest is accepted, check if it's a mutual match
  IF NEW.status = 'accepted' AND OLD.status != 'accepted' THEN
    -- Get sender profile name
    SELECT COALESCE(first_name || ' ' || last_name, 'Someone')
    INTO sender_name
    FROM public.matrimony_profiles
    WHERE user_id = NEW.sender_id
    LIMIT 1;

    -- Notify the sender that their interest was accepted
    INSERT INTO public.notifications (user_id, type, title, body, data)
    VALUES (
      NEW.sender_id,
      'interest_accepted',
      'Interest Accepted!',
      COALESCE(sender_name, 'Someone') || ' accepted your interest',
      jsonb_build_object('interest_id', NEW.id, 'other_user_id', NEW.receiver_id)
    );

    -- Check for mutual match
    IF EXISTS (
      SELECT 1 FROM public.interests
      WHERE sender_id = NEW.receiver_id
        AND receiver_id = NEW.sender_id
        AND status = 'accepted'
    ) THEN
      -- Get receiver profile name
      SELECT COALESCE(first_name || ' ' || last_name, 'Someone')
      INTO receiver_name
      FROM public.matrimony_profiles
      WHERE user_id = NEW.receiver_id
      LIMIT 1;

      -- Notify both users of the match
      INSERT INTO public.notifications (user_id, type, title, body, data)
      VALUES (
        NEW.sender_id,
        'new_match',
        'New Match!',
        'You and ' || COALESCE(receiver_name, 'someone') || ' are now matched!',
        jsonb_build_object('other_user_id', NEW.receiver_id)
      );

      INSERT INTO public.notifications (user_id, type, title, body, data)
      VALUES (
        NEW.receiver_id,
        'new_match',
        'New Match!',
        'You and ' || COALESCE(sender_name, 'someone') || ' are now matched!',
        jsonb_build_object('other_user_id', NEW.sender_id)
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_interest_status_change ON public.interests;
CREATE TRIGGER on_interest_status_change
  AFTER UPDATE ON public.interests
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_on_match();

-- ─── 6. Function: Notify on new interest received ────────────────────────────
CREATE OR REPLACE FUNCTION public.notify_on_new_interest()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  sender_name TEXT;
BEGIN
  SELECT COALESCE(first_name || ' ' || last_name, 'Someone')
  INTO sender_name
  FROM public.matrimony_profiles
  WHERE user_id = NEW.sender_id
  LIMIT 1;

  INSERT INTO public.notifications (user_id, type, title, body, data)
  VALUES (
    NEW.receiver_id,
    'new_interest',
    'New Interest Received!',
    COALESCE(sender_name, 'Someone') || ' sent you an interest',
    jsonb_build_object('interest_id', NEW.id, 'other_user_id', NEW.sender_id)
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_new_interest ON public.interests;
CREATE TRIGGER on_new_interest
  AFTER INSERT ON public.interests
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_on_new_interest();

-- ─── 7. Function: Notify on new chat message ─────────────────────────────────
CREATE OR REPLACE FUNCTION public.notify_on_new_message()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  sender_name TEXT;
  other_participant UUID;
BEGIN
  SELECT COALESCE(first_name || ' ' || last_name, 'Someone')
  INTO sender_name
  FROM public.matrimony_profiles
  WHERE user_id = NEW.sender_id
  LIMIT 1;

  -- Get the other participant in the conversation
  SELECT CASE
    WHEN participant_one = NEW.sender_id THEN participant_two
    ELSE participant_one
  END
  INTO other_participant
  FROM public.chat_conversations
  WHERE id = NEW.conversation_id
  LIMIT 1;

  IF other_participant IS NOT NULL THEN
    INSERT INTO public.notifications (user_id, type, title, body, data)
    VALUES (
      other_participant,
      'new_message',
      'New Message',
      COALESCE(sender_name, 'Someone') || ': ' || LEFT(NEW.content, 60),
      jsonb_build_object('conversation_id', NEW.conversation_id, 'sender_id', NEW.sender_id)
    );
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_new_chat_message ON public.chat_messages;
CREATE TRIGGER on_new_chat_message
  AFTER INSERT ON public.chat_messages
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_on_new_message();
