import 'dart:js_util' as js_util;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> startPayuPayment({
  required int amountInr,
  required void Function(String message) onFailure,
}) async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    final response = await Supabase.instance.client.functions.invoke(
      'create-payu-order',
      body: {
        'amount': amountInr,
        'firstname': user?.userMetadata?['full_name'] ?? 'Alliance Member',
        'email': user?.email ?? '',
      },
    );
    if (response.data is! Map) {
      onFailure('Unable to start payment. Please try again.');
      return;
    }
    final order = Map<String, dynamic>.from(response.data as Map);
    if (order['error'] != null) {
      onFailure(order['error'].toString());
      return;
    }
    // Redirects the browser to PayU's hosted checkout page.
    js_util.callMethod(js_util.globalThis, 'openPayuCheckout', [
      js_util.jsify(order),
    ]);
  } catch (_) {
    onFailure('Unable to start payment. Please try again.');
  }
}
