Future<void> startPayuPayment({
  required int amountInr,
  required void Function(String message) onFailure,
}) async {
  onFailure('PayU Checkout is only available on the website.');
}
