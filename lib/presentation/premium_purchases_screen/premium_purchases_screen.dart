import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/supabase_service.dart';

class PremiumPurchasesScreen extends StatefulWidget {
  const PremiumPurchasesScreen({super.key});

  @override
  State<PremiumPurchasesScreen> createState() => _PremiumPurchasesScreenState();
}

class _PremiumPurchasesScreenState extends State<PremiumPurchasesScreen> {
  final SupabaseService _supabase = SupabaseService.instance;

  List<Map<String, dynamic>> _purchases = [];
  Map<String, dynamic>? _activePurchase;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _supabase.fetchPurchases(),
      _supabase.fetchActivePurchase(),
    ]);
    if (mounted) {
      setState(() {
        _purchases = results[0] as List<Map<String, dynamic>>;
        _activePurchase = results[1] as Map<String, dynamic>?;
        _isLoading = false;
      });
    }
  }

  Future<void> _openExternalPage() async {
    await launchUrl(
      Uri.parse('https://www.alliancematrimony.online/features.html'),
      mode: LaunchMode.externalApplication,
    );
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '—';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return '—';
    }
  }

  bool _isExpiringSoon(String? isoString) {
    if (isoString == null) return false;
    try {
      final dt = DateTime.parse(isoString);
      return dt.difference(DateTime.now()).inDays <= 90;
    } catch (_) {
      return false;
    }
  }

  bool _isExpired(String? isoString) {
    if (isoString == null) return false;
    try {
      return DateTime.parse(isoString).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D16),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: const Color(0xFFC8556A),
                      backgroundColor: const Color(0xFF1E1520),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                        children: [
                          _buildSubscriptionStatusCard(),
                          const SizedBox(height: 24),
                          _buildPurchaseHistorySection(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1520),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x1AFFFFFF)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFFCCBDD0),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Premium & Purchases',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEEE0F0),
                ),
              ),
              Text(
                'Subscription status & billing history',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: Color(0xFF9A8A9E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionStatusCard() {
    final isActive =
        _activePurchase != null &&
        !_isExpired(_activePurchase?['valid_until'] as String?);
    final validUntil = _activePurchase?['valid_until'] as String?;
    final purchasedAt = _activePurchase?['purchased_at'] as String?;
    final expiringSoon = _isExpiringSoon(validUntil);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isActive
                  ? [
                      const Color(0xFF0D3D22).withAlpha(200),
                      const Color(0xFF1A2A1A).withAlpha(180),
                    ]
                  : [
                      const Color(0xFF2A1E2E).withAlpha(200),
                      const Color(0xFF1E1520).withAlpha(180),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? (expiringSoon
                        ? const Color(0xFFE8A87C).withAlpha(120)
                        : const Color(0xFF2D7A4F))
                  : const Color(0xFF3A2A40),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF2D7A4F).withAlpha(60)
                          : const Color(0xFF3A2A40),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isActive
                          ? Icons.verified_rounded
                          : Icons.lock_outline_rounded,
                      size: 22,
                      color: isActive
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFF6B5870),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isActive
                              ? 'Premium Active'
                              : 'No Active Subscription',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? const Color(0xFF4ADE80)
                                : const Color(0xFFCCBDD0),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isActive
                              ? 'Full access to all profiles & chat'
                              : 'Upgrade to unlock all features',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            color: Color(0xFF9A8A9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: expiringSoon
                            ? const Color(0xFFE8A87C).withAlpha(30)
                            : const Color(0xFF2D7A4F).withAlpha(60),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: expiringSoon
                              ? const Color(0xFFE8A87C).withAlpha(100)
                              : const Color(0xFF2D7A4F),
                        ),
                      ),
                      child: Text(
                        expiringSoon ? 'Expiring Soon' : 'Active',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: expiringSoon
                              ? const Color(0xFFE8A87C)
                              : const Color(0xFF4ADE80),
                        ),
                      ),
                    ),
                ],
              ),
              if (isActive) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1A0A).withAlpha(120),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2D7A4F).withAlpha(80),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.calendar_today_rounded,
                        'Purchase Date',
                        _formatDate(purchasedAt),
                        const Color(0xFF4ADE80),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        Icons.event_rounded,
                        'Renewal / Expiry Date',
                        _formatDate(validUntil),
                        expiringSoon
                            ? const Color(0xFFE8A87C)
                            : const Color(0xFF4ADE80),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        Icons.access_time_rounded,
                        'Validity',
                        '2 Years',
                        const Color(0xFF4ADE80),
                      ),
                    ],
                  ),
                ),
                if (expiringSoon) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8A87C).withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFE8A87C).withAlpha(80),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: Color(0xFFE8A87C),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your subscription expires soon. Renew to keep full access.',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: Color(0xFFE8A87C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              if (!isActive) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _openExternalPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC8556A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _openExternalPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A1E2E),
                            foregroundColor: const Color(0xFFCCBDD0),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'View Plans',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            color: Color(0xFF9A8A9E),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFFCCBDD0),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Purchase History',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEEE0F0),
              ),
            ),
            const Spacer(),
            if (_purchases.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1E2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_purchases.length} ${_purchases.length == 1 ? 'record' : 'records'}',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    color: Color(0xFF9A8A9E),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_purchases.isEmpty)
          _buildEmptyPurchases()
        else
          ...List.generate(_purchases.length, (i) {
            return _buildPurchaseCard(_purchases[i]);
          }),
      ],
    );
  }

  Widget _buildPurchaseCard(Map<String, dynamic> purchase) {
    final purchasedAt = purchase['purchased_at'] as String?;
    final validUntil = purchase['valid_until'] as String?;
    final amount = purchase['amount_inr'] as int? ?? 500;
    final invoiceNumber = purchase['invoice_number'] as String? ?? '';
    final isActive = purchase['is_active'] as bool? ?? false;
    final expired = _isExpired(validUntil);
    final statusColor = isActive && !expired
        ? const Color(0xFF4ADE80)
        : const Color(0xFF9A8A9E);
    final statusLabel = isActive && !expired ? 'Active' : 'Expired';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1520),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive && !expired
              ? const Color(0xFF2D7A4F).withAlpha(80)
              : const Color(0xFF2A1E2E),
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC8556A), Color(0xFFE8A87C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Full Access — 2 Years',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEEE0F0),
                        ),
                      ),
                      Text(
                        _formatDate(purchasedAt),
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: Color(0xFF9A8A9E),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withAlpha(80)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1E2E).withAlpha(120),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Amount Paid', '₹$amount'),
                  const SizedBox(height: 6),
                  _buildDetailRow('Valid Until', _formatDate(validUntil)),
                  if (invoiceNumber.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildDetailRow('Invoice No.', invoiceNumber),
                  ],
                ],
              ),
            ),
            if (invoiceNumber.isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _downloadInvoice(purchase),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8556A).withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFC8556A).withAlpha(80),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.download_rounded,
                        size: 14,
                        color: Color(0xFFC8556A),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Download Invoice',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC8556A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            color: Color(0xFF9A8A9E),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFFCCBDD0),
          ),
        ),
      ],
    );
  }

  void _downloadInvoice(Map<String, dynamic> purchase) {
    final invoiceNumber = purchase['invoice_number'] as String? ?? '';
    final purchasedAt = purchase['purchased_at'] as String?;
    final validUntil = purchase['valid_until'] as String?;
    final amount = purchase['amount_inr'] as int? ?? 500;

    final content =
        '''
ALLIANCE MATRIMONY — INVOICE
============================
Invoice No : $invoiceNumber
Purchase Date : ${_formatDate(purchasedAt)}
Valid Until : ${_formatDate(validUntil)}
Plan : Full Access (2 Years)
Amount Paid : ₹$amount
============================
Thank you for your purchase!
''';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Invoice $invoiceNumber ready. Download feature available on device.',
          style: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
        ),
        backgroundColor: const Color(0xFF2D7A4F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
    // content variable available for actual file download implementation
    debugPrint(content);
  }

  Widget _buildEmptyPurchases() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1520),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A1E2E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 32,
              color: Color(0xFF6B5870),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No purchases yet',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFFCCBDD0),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your purchase history will appear here after upgrading to premium.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              color: Color(0xFF6B5870),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      children: [
        _buildSkeletonBox(height: 200),
        const SizedBox(height: 24),
        _buildSkeletonBox(height: 20, width: 140),
        const SizedBox(height: 12),
        _buildSkeletonBox(height: 140),
        const SizedBox(height: 12),
        _buildSkeletonBox(height: 140),
      ],
    );
  }

  Widget _buildSkeletonBox({double height = 80, double? width}) {
    return Container(
      height: height,
      width: width,
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2030),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
