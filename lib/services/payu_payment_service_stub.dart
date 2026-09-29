Future<void> startPayuPayment({
  required int amountInr,
  required void Function(String message) onFailure,
}) async {
  onFailure('PayU Checkout is not supported on this platform.');
}
