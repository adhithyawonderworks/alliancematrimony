import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_routes.dart';

class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({super.key, required this.success});

  final bool success;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D16),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                success ? Icons.check_circle_rounded : Icons.error_rounded,
                size: 64,
                color: success
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE57373),
              ),
              const SizedBox(height: 24),
              Text(
                success ? 'Payment Successful' : 'Payment Failed',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEEE0F0),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                success
                    ? 'Your premium access has been activated via PayU.'
                    : 'The PayU payment could not be completed. Please try again.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  color: Color(0xFF9A8A9E),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      context.go(AppRoutes.browseProfilesScreen),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8556A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
