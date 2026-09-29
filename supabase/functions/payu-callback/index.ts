import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

async function sha512Hex(input: string) {
  const bytes = await crypto.subtle.digest('SHA-512', new TextEncoder().encode(input));
  return Array.from(new Uint8Array(bytes))
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join('');
}

function redirectTo(appBaseUrl: string, status: 'success' | 'failure', txnid: string) {
  const url = new URL(appBaseUrl || 'https://example.com/payment-result-screen');
  url.searchParams.set('status', status);
  url.searchParams.set('txnid', txnid);
  return new Response(null, { status: 302, headers: { ...corsHeaders, Location: url.toString() } });
}

// PayU posts its surl/furl callbacks here (form-urlencoded, not JSON).
Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  const requestUrl = new URL(request.url);
  const appBaseUrl = requestUrl.searchParams.get('app_base_url') ?? Deno.env.get('APP_BASE_URL') ?? '';
  const merchantSalt = Deno.env.get('PAYU_MERCHANT_SALT');
  if (!merchantSalt) return redirectTo(appBaseUrl, 'failure', '');

  let txnid = '';
  try {
    const form = await request.formData();
    const get = (name: string) => String(form.get(name) ?? '');

    const key = get('key');
    const amount = get('amount');
    const productinfo = get('productinfo');
    const firstname = get('firstname');
    const email = get('email');
    const status = get('status');
    const udf1 = get('udf1');
    const providedHash = get('hash');
    const mihpayid = get('mihpayid');
    txnid = get('txnid');

    const reverseSequence = [
      merchantSalt,
      status,
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      udf1,
      email,
      firstname,
      productinfo,
      amount,
      txnid,
      key,
    ].join('|');
    const expectedHash = await sha512Hex(reverseSequence);

    if (expectedHash !== providedHash || status !== 'success' || !udf1) {
      return redirectTo(appBaseUrl, 'failure', txnid);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const admin = createClient(supabaseUrl, serviceRoleKey);
    const now = new Date();
    const { error: insertError } = await admin.from('premium_purchases').insert({
      user_id: udf1,
      purchase_type: 'full_access',
      amount_inr: Math.round(Number(amount)),
      payment_reference: mihpayid || txnid,
      purchased_at: now.toISOString(),
      valid_until: new Date(now.getTime() + 730 * 24 * 60 * 60 * 1000).toISOString(),
      is_active: true,
      invoice_number: `INV-${now.getTime()}`,
    });
    if (insertError) throw insertError;

    return redirectTo(appBaseUrl, 'success', txnid);
  } catch (error) {
    console.error('PayU callback error', error);
    return redirectTo(appBaseUrl, 'failure', txnid);
  }
});
