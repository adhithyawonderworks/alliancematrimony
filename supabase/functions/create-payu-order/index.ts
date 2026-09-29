import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Content-Type': 'application/json',
};

const json = (body: Record<string, unknown>, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: corsHeaders });

async function sha512Hex(input: string) {
  const bytes = await crypto.subtle.digest('SHA-512', new TextEncoder().encode(input));
  return Array.from(new Uint8Array(bytes))
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join('');
}

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (request.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  const merchantKey = Deno.env.get('PAYU_MERCHANT_KEY');
  const merchantSalt = Deno.env.get('PAYU_MERCHANT_SALT');
  if (!merchantKey || !merchantSalt) return json({ error: 'PayU is not configured' }, 500);

  const authorization = request.headers.get('Authorization');
  if (!authorization?.startsWith('Bearer ')) return json({ error: 'Authentication required' }, 401);

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authorization } },
    });
    const {
      data: { user },
      error: userError,
    } = await userClient.auth.getUser();
    if (userError || !user) return json({ error: 'Authentication required' }, 401);

    const body = await request.json();
    const amount = Number(body.amount);
    if (!Number.isFinite(amount) || amount < 1) {
      return json({ error: 'Invalid amount' }, 400);
    }

    const productinfo = 'Alliance Matrimony Premium';
    const firstname = String(body.firstname ?? 'Alliance Member').slice(0, 60);
    const email = String(body.email ?? user.email ?? '').slice(0, 60);
    const phone = String(body.phone ?? '').slice(0, 20);
    const amountStr = amount.toFixed(2);
    const txnid = `AM${Date.now()}${crypto.randomUUID().slice(0, 8)}`;
    const udf1 = user.id; // carries the user id through PayU's redirect flow

    const hashSequence = [
      merchantKey,
      txnid,
      amountStr,
      productinfo,
      firstname,
      email,
      udf1,
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      merchantSalt,
    ].join('|');
    const hash = await sha512Hex(hashSequence);

    const appBaseUrl = Deno.env.get('APP_BASE_URL') ?? '';
    const callbackUrl = `${supabaseUrl}/functions/v1/payu-callback?app_base_url=${encodeURIComponent(appBaseUrl)}`;
    const payuEnv = Deno.env.get('PAYU_ENV') ?? 'test';
    const action =
      payuEnv === 'production' ? 'https://secure.payu.in/_payment' : 'https://test.payu.in/_payment';

    return json({
      action,
      key: merchantKey,
      txnid,
      amount: amountStr,
      productinfo,
      firstname,
      email,
      phone,
      surl: callbackUrl,
      furl: callbackUrl,
      udf1,
      hash,
    });
  } catch (error) {
    console.error('Create PayU order error', error);
    return json({ error: 'Unable to create payment order' }, 500);
  }
});
