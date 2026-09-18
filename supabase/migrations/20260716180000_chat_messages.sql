-- Chat messages table for real-time messaging between matched users
-- Migration: 20260716180000_chat_messages

-- 1. Create chat_conversations table
CREATE TABLE IF NOT EXISTS public.chat_conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  participant_one UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  participant_two UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  last_message TEXT DEFAULT '',
  last_message_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Create chat_messages table
CREATE TABLE IF NOT EXISTS public.chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES public.chat_conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Indexes
CREATE INDEX IF NOT EXISTS idx_chat_conversations_participant_one ON public.chat_conversations(participant_one);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_participant_two ON public.chat_conversations(participant_two);
CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation_id ON public.chat_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_sender_id ON public.chat_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON public.chat_messages(created_at);

-- Unique constraint: only one conversation per pair of users
CREATE UNIQUE INDEX IF NOT EXISTS idx_chat_conversations_unique_pair
  ON public.chat_conversations (
    LEAST(participant_one::text, participant_two::text),
    GREATEST(participant_one::text, participant_two::text)
  );

-- 4. Enable RLS
ALTER TABLE public.chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies for chat_conversations
DROP POLICY IF EXISTS "users_view_own_conversations" ON public.chat_conversations;
CREATE POLICY "users_view_own_conversations"
  ON public.chat_conversations
  FOR SELECT
  TO authenticated
  USING (participant_one = auth.uid() OR participant_two = auth.uid());

DROP POLICY IF EXISTS "users_create_conversations" ON public.chat_conversations;
CREATE POLICY "users_create_conversations"
  ON public.chat_conversations
  FOR INSERT
  TO authenticated
  WITH CHECK (participant_one = auth.uid() OR participant_two = auth.uid());

DROP POLICY IF EXISTS "users_update_own_conversations" ON public.chat_conversations;
CREATE POLICY "users_update_own_conversations"
  ON public.chat_conversations
  FOR UPDATE
  TO authenticated
  USING (participant_one = auth.uid() OR participant_two = auth.uid())
  WITH CHECK (participant_one = auth.uid() OR participant_two = auth.uid());

-- 6. RLS Policies for chat_messages
DROP POLICY IF EXISTS "users_view_conversation_messages" ON public.chat_messages;
CREATE POLICY "users_view_conversation_messages"
  ON public.chat_messages
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.chat_conversations cc
      WHERE cc.id = conversation_id
        AND (cc.participant_one = auth.uid() OR cc.participant_two = auth.uid())
    )
  );

DROP POLICY IF EXISTS "users_send_messages" ON public.chat_messages;
CREATE POLICY "users_send_messages"
  ON public.chat_messages
  FOR INSERT
  TO authenticated
  WITH CHECK (
    sender_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.chat_conversations cc
      WHERE cc.id = conversation_id
        AND (cc.participant_one = auth.uid() OR cc.participant_two = auth.uid())
    )
  );
