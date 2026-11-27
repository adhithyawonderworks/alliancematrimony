const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

function website() {
  const elements = {};
  for (const id of ['msg', 'pay', 'gateways', 'razorpay', 'payu', 'back', 'name', 'email',
    'phone', 'intro', 'payment-note', 'referral-code', 'referral-field', 'form']) {
    elements[id] = {
      value: '', hidden: false, disabled: false, textContent: '', listeners: {},
      addEventListener(event, fn) { this.listeners[event] = fn; },
    };
  }
  const calls = [];
  const window = {
    location: { href: 'https://example.test/membership.html?referral_code=REF1', search: '?referral_code=REF1' },
    openPayuCheckout(order) { window.payuOrder = order; },
  };
  const supabase = { createClient: () => ({ functions: {
    async invoke(name, { body }) {
      calls.push({ name, body });
      return { data: { action: 'https://payu.test' } };
    },
  } }) };
  const html = fs.readFileSync(path.join(__dirname, '..', 'web', 'membership.html'), 'utf8');
  const script = html.match(/<script>\s*([\s\S]*?)<\/script>/)[1];
  vm.runInNewContext(script, { document: { getElementById: (id) => elements[id] }, window, URLSearchParams, supabase });
  elements.name.value = 'Test Member';
  elements.email.value = 'member@example.test';
  elements.phone.value = '9876543210';
  return { elements, window, calls, html };
}

test('Join Now offers PayU and a clearly labelled Razorpay test', async () => {
  const page = website();
  page.elements.form.listeners.submit({ preventDefault() {} });
  assert.equal(page.elements.gateways.hidden, false);
  assert.match(page.html, /Test payments do not activate membership/);
  assert.equal(page.calls.length, 0);
  await page.elements.payu.listeners.click();
  assert.equal(page.calls[0].name, 'create-payu-order');
  assert.equal(page.calls[0].body.referralCode, 'REF1');
  assert.equal(page.window.payuOrder.action, 'https://payu.test');
});

test('Razorpay test link does not create or activate a membership order', () => {
  const page = website();
  page.elements.form.listeners.submit({ preventDefault() {} });
  page.elements.razorpay.listeners.click();
  assert.equal(page.window.location.href, 'https://rzp.io/rzp/Ahrh0ay');
  assert.equal(page.calls.length, 0);
});
