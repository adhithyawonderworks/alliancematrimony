-- Migration: interests table for matrimony app
-- Timestamp: 20260716181000

CREATE TABLE IF NOT EXISTS public.interests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'pending',
    message TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT interests_status_check CHECK (status IN ('pending', 'accepted', 'declined'))
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_interests_sender_receiver
    ON public.interests (sender_id, receiver_id);

CREATE INDEX IF NOT EXISTS idx_interests_receiver_id ON public.interests (receiver_id);
CREATE INDEX IF NOT EXISTS idx_interests_sender_id ON public.interests (sender_id);
CREATE INDEX IF NOT EXISTS idx_interests_status ON public.interests (status);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION public.update_interests_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS interests_updated_at_trigger ON public.interests;
CREATE TRIGGER interests_updated_at_trigger
    BEFORE UPDATE ON public.interests
    FOR EACH ROW EXECUTE FUNCTION public.update_interests_updated_at();

ALTER TABLE public.interests ENABLE ROW LEVEL SECURITY;

-- Sender can insert and view their sent interests
DROP POLICY IF EXISTS "interests_sender_insert" ON public.interests;
CREATE POLICY "interests_sender_insert"
    ON public.interests
    FOR INSERT
    TO authenticated
    WITH CHECK (sender_id = auth.uid());

DROP POLICY IF EXISTS "interests_sender_select" ON public.interests;
CREATE POLICY "interests_sender_select"
    ON public.interests
    FOR SELECT
    TO authenticated
    USING (sender_id = auth.uid() OR receiver_id = auth.uid());

-- Receiver can update status (accept/decline)
DROP POLICY IF EXISTS "interests_receiver_update" ON public.interests;
CREATE POLICY "interests_receiver_update"
    ON public.interests
    FOR UPDATE
    TO authenticated
    USING (receiver_id = auth.uid())
    WITH CHECK (receiver_id = auth.uid());

-- Sender can delete their own sent interests
DROP POLICY IF EXISTS "interests_sender_delete" ON public.interests;
CREATE POLICY "interests_sender_delete"
    ON public.interests
    FOR DELETE
    TO authenticated
    USING (sender_id = auth.uid());
