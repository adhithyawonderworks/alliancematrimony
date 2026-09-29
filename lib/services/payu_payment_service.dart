import 'payu_payment_service_stub.dart'
    if (dart.library.io) 'payu_payment_service_native.dart'
    if (dart.library.html) 'payu_payment_service_web.dart'
    as platform;

/// Starts a PayU hosted-checkout payment. PayU works by redirecting the
/// browser to its payment page, so there is no synchronous success callback;
/// the outcome is delivered later via the `payment-result-screen` route once
/// PayU redirects back through the `payu-callback` Supabase Edge Function.
class PayuPaymentService {
  static const int premiumAmountInr = 500;

  Future<void> pay({required void Function(String message) onFailure}) {
    return platform.startPayuPayment(
      amountInr: premiumAmountInr,
      onFailure: onFailure,
    );
  }
}
