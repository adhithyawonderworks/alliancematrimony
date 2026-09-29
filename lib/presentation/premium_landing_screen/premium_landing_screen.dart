import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumLandingScreen extends StatefulWidget {
  const PremiumLandingScreen({super.key});

  @override
  State<PremiumLandingScreen> createState() => _PremiumLandingScreenState();
}

class _PremiumLandingScreenState extends State<PremiumLandingScreen> {
  Future<void> _openFeaturesPage() async {
    await launchUrl(
      Uri.parse('https://www.alliancematrimony.online/features.html'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1520),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFEEE0F0)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'View Plans',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFFEEE0F0),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC8556A), Color(0xFFE8A87C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Alliance Matrimony Premium',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEEE0F0),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'View our premium plans and unlock full access to all profiles, photos, and chat.',
                textAlign: TextAlign.center,
                style: TextStyle(
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
                  onPressed: _openFeaturesPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8556A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.open_in_new_rounded, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
