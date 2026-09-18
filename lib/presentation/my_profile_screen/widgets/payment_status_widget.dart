import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routes/app_routes.dart';

class PaymentStatusWidget extends StatelessWidget {
  final bool isPaid;
  final VoidCallback onPay;

  const PaymentStatusWidget({
    super.key,
    required this.isPaid,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPaid
                  ? [
                      const Color(0xFF0D3D22).withAlpha(204),
                      const Color(0xFF0D2A18).withAlpha(153),
                    ]
                  : [
                      const Color(0xFFC8556A).withAlpha(31),
                      const Color(0xFFE8A87C).withAlpha(20),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPaid
                  ? const Color(0xFF2D7A4F)
                  : const Color(0xFFC8556A).withAlpha(102),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? const Color(0xFF2D7A4F).withAlpha(51)
                            : const Color(0xFFC8556A).withAlpha(38),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isPaid
                            ? Icons.verified_rounded
                            : Icons.lock_outline_rounded,
                        size: 20,
                        color: isPaid
                            ? const Color(0xFF4ADE80)
                            : const Color(0xFFE8A87C),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPaid
                                ? 'Full Access Unlocked'
                                : 'Unlock Full Access',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isPaid
                                  ? const Color(0xFF4ADE80)
                                  : const Color(0xFFEEE0F0),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isPaid
                                ? 'View all photos & chat unlocked • Valid for 2 years'
                                : 'View our plans to unlock all photos & chat',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              color: Color(0xFF9A8A9E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!isPaid) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildFeaturePill(
                        Icons.photo_library_rounded,
                        'View all photos',
                      ),
                      const SizedBox(width: 8),
                      _buildFeaturePill(Icons.chat_rounded, 'Chat unlocked'),
                      const SizedBox(width: 8),
                      _buildFeaturePill(
                        Icons.calendar_month_rounded,
                        '2 years',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => context.push(AppRoutes.premiumLandingScreen),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC8556A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.open_in_new_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'View Now',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (isPaid) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D3D22),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: Color(0xFF4ADE80),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Access valid until: July 2028',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4ADE80),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D3D22),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_rounded,
                              size: 12,
                              color: Color(0xFF4ADE80),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Chat enabled',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4ADE80),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0x33FFFFFF), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFE8A87C)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10,
              color: Color(0xFF9A8A9E),
            ),
          ),
        ],
      ),
    );
  }
}
