import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': 'https://www.alliancematrimony.online',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Content-Type': 'application/json',
};

const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const deletionPageUrl = Deno.env.get('PUBLIC_DELETION_URL') ?? 'https://www.alliancematrimony.online/delete-account.html';
const resendApiKey = Deno.env.get('RESEND_API_KEY');
const fromEmail = Deno.env.get('DELETION_FROM_EMAIL') ?? 'Alliance Matrimony <no-reply@alliancematrimony.online>';
const admin = createClient(supabaseUrl, serviceRoleKey, { auth: { autoRefreshToken: false, persistSession: false } });

function json(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: corsHeaders });
}

function token() {
  const bytes = crypto.getRandomValues(new Uint8Array(32));
  return btoa(String.fromCharCode(...bytes)).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
}

async function hash(value: string) {
  const bytes = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(value));
  return Array.from(new Uint8Array(bytes)).map((byte) => byte.toString(16).padStart(2, '0')).join('');
}

async function findUserId(email: string) {
  for (let page = 1; page <= 20; page++) {
    const { data, error } = await admin.auth.admin.listUsers({ page, perPage: 1000 });
    if (error) throw error;
    const match = data.users.find((user) => user.email?.toLowerCase() === email);
    if (match) return match.id;
    if (data.users.length < 1000) break;
  }
  return null;
}

async function deleteUserData(userId: string) {
  const { data: conversations, error: conversationError } = await admin
    .from('chat_conversations')
    .select('id')
    .or(`participant_one.eq.${userId},participant_two.eq.${userId}`);
  if (conversationError) throw conversationError;

  const conversationIds = (conversations ?? []).map((row) => row.id as string);
  if (conversationIds.length > 0) {
    const { error } = await admin.from('chat_messages').delete().in('conversation_id', conversationIds);
    if (error) throw error;
  }

  const deletes = [
    admin.from('chat_conversations').delete().or(`participant_one.eq.${userId},participant_two.eq.${userId}`),
    admin.from('interests').delete().or(`sender_id.eq.${userId},receiver_id.eq.${userId}`),
    admin.from('user_reports').delete().or(`reporter_id.eq.${userId},reported_user_id.eq.${userId}`),
    admin.from('premium_purchases').delete().eq('user_id', userId),
    admin.from('push_notification_tokens').delete().eq('user_id', userId),
    admin.from('notifications').delete().eq('user_id', userId),
    admin.from('matrimony_profiles').delete().eq('user_id', userId),
  ];
  const results = await Promise.all(deletes);
  const failed = results.find((result) => result.error);
  if (failed?.error) throw failed.error;

  const { error: authError } = await admin.auth.admin.deleteUser(userId);
  if (authError) throw authError;
}

async function sendVerificationEmail(email: string, confirmationUrl: string) {
  if (!resendApiKey) throw new Error('RESEND_API_KEY is not configured');
  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: { Authorization: `Bearer ${resendApiKey}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      from: fromEmail,
      to: [email],
      subject: 'Confirm Alliance Matrimony account deletion',
      html: `<p>We received a request to delete your Alliance Matrimony account.</p><p><a href="${confirmationUrl}">Confirm permanent deletion</a></p><p>This link expires in 30 minutes. If you did not make this request, ignore this email.</p>`,
    }),
  });
  if (!response.ok) throw new Error(`Email delivery failed: ${await response.text()}`);
}

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (request.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  try {
    const body = await request.json();
    const action = body.action as string;

    if (action === 'request') {
      const email = String(body.email ?? '').trim().toLowerCase();
      if (!/^\S+@\S+\.\S+$/.test(email)) return json({ error: 'Enter a valid email address' }, 400);

      const since = new Date(Date.now() - 60 * 60 * 1000).toISOString();
      const { count } = await admin.from('account_deletion_requests').select('id', { count: 'exact', head: true }).eq('email', email).gte('created_at', since);
      if ((count ?? 0) >= 3) return json({ error: 'Too many requests. Please try again later.' }, 429);

      const rawToken = token();
      const tokenHash = await hash(rawToken);
      const { error } = await admin.from('account_deletion_requests').insert({
        email,
        token_hash: tokenHash,
        expires_at: new Date(Date.now() + 30 * 60 * 1000).toISOString(),
      });
      if (error) throw error;

      const confirmationUrl = `${deletionPageUrl}?token=${encodeURIComponent(rawToken)}`;
      await sendVerificationEmail(email, confirmationUrl);
      return json({ message: 'Check your email for the confirmation link.' });
    }

    if (action === 'confirm') {
      const rawToken = String(body.token ?? '');
      if (!rawToken) return json({ error: 'Missing confirmation token' }, 400);
      const tokenHash = await hash(rawToken);
            await admin.from('account_deletion_requests').delete().eq('id', requestRow.id);
            return json({ message: 'Your account and associated data have been permanently deleted.' });
      if (error) throw error;
      if (!requestRow || requestRow.confirmed_at || requestRow.completed_at || new Date(requestRow.expires_at) < new Date()) return json({ error: 'This deletion link is invalid or expired.' }, 400);

      const userId = await findUserId(requestRow.email);
      await admin.from('account_deletion_requests').update({ confirmed_at: new Date().toISOString() }).eq('id', requestRow.id);
      if (userId) await deleteUserData(userId);
      await admin.from('account_deletion_requests').update({ completed_at: new Date().toISOString() }).eq('id', requestRow.id);
      return json({ message: 'Your account and associated data have been permanently deleted.' });
    }

    return json({ error: 'Unknown action' }, 400);
  } catch (error) {
    console.error(error);
    return json({ error: 'Unable to process the deletion request right now.' }, 500);
  }
});
