import 'package:flutter/material.dart';

import '../my_profile_screen.dart';

class ProfileCompletionTipsWidget extends StatelessWidget {
  final MyProfileData profile;

  const ProfileCompletionTipsWidget({
    super.key,
    required this.profile,
  });

  List<_TipItem> get _tips {
    final tips = <_TipItem>[];

    if (profile.imageUrl.trim().isEmpty) {
      tips.add(const _TipItem(
        icon: Icons.add_photo_alternate_rounded,
        text: 'Add your photo',
      ));
    }
    if (profile.religion.trim().isEmpty) {
      tips.add(const _TipItem(
        icon: Icons.temple_hindu_rounded,
        text: 'Complete your religion details',
      ));
    }
    if (profile.caste.trim().isEmpty) {
      tips.add(const _TipItem(
        icon: Icons.people_alt_outlined,
        text: 'Add your community details',
      ));
    }
    if (profile.facebookLink.trim().isEmpty) {
      tips.add(const _TipItem(
        icon: Icons.link_rounded,
        text: 'Add your social profile link',
      ));
    }
    if (profile.partnerAgeRange.trim().isEmpty) {
      tips.add(const _TipItem(
        icon: Icons.favorite_border_rounded,
        text: 'Set your partner preferences',
      ));
    }
    if (profile.parentsName.trim().isEmpty) {
      tips.add(const _TipItem(
        icon: Icons.family_restroom_rounded,
        text: 'Add family details',
      ));
    }

    return tips.isNotEmpty ? tips : const [
      _TipItem(
        icon: Icons.verified_rounded,
        text: 'Your profile is complete — great job!',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tips = _tips;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1520),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Tips',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEEE0F0),
              ),
            ),
            const SizedBox(height: 12),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC8556A).withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        tip.icon,
                        size: 15,
                        color: const Color(0xFFC8556A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tip.text,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: Color(0xFFCCBDD0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipItem {
  final IconData icon;
  final String text;

  const _TipItem({required this.icon, required this.text});
}
