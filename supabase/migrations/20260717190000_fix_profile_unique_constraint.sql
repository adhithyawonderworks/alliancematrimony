-- Add unique constraint on user_id so native upsert works correctly
ALTER TABLE public.matrimony_profiles
    DROP CONSTRAINT IF EXISTS matrimony_profiles_user_id_key;

ALTER TABLE public.matrimony_profiles
    ADD CONSTRAINT matrimony_profiles_user_id_key UNIQUE (user_id);
