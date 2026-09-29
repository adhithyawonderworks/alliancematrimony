import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'browse_profiles_screen.dart';

class ProfileDetailsScreen extends StatelessWidget {
  final MatrimonyProfile profile;
  final bool isPaid;
  final bool hasInterest;
  final Future<void> Function() onInterest;

  const ProfileDetailsScreen({
    super.key,
    required this.profile,
    required this.isPaid,
    required this.hasInterest,
    required this.onInterest,
  });

  @override
  Widget build(BuildContext context) {
    final details = <(String, String)>[
      ('Age', '${profile.age}'),
      ('Height', profile.heightCm),
      ('Occupation', profile.job),
      ('Education', profile.education),
      ('Location', profile.place),
      ('Mother tongue', profile.motherTongue),
      ('Birth star', profile.horoscopeStar),
      if (profile.addressVerified) ('Address verification', 'Verified'),
      ('Religion', profile.religion),
      ('Community', profile.caste),
    ].where((detail) => detail.$2.trim().isNotEmpty);

    return Scaffold(
      backgroundColor: const Color(0xFF120D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1520),
        title: const Text('Profile details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                SizedBox(
                  height: 340,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      profile.imageUrl.isEmpty
                          ? const ColoredBox(
                              color: Color(0xFF2A1E2E),
                              child: Icon(
                                Icons.person_rounded,
                                size: 80,
                                color: Color(0xFF8A7A90),
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: profile.imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => const ColoredBox(
                                color: Color(0xFF2A1E2E),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 80,
                                  color: Color(0xFF8A7A90),
                                ),
                              ),
                            ),
                      if (!isPaid)
                        ColoredBox(
                          color: const Color(0xCC120D16),
                          child: const Center(
                            child: Text(
                              'Premium required to view photos',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Text(
                    profile.displayName,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEEE0F0),
                    ),
                  ),
                ),
                ...details.map(
                  (detail) => ListTile(
                    dense: true,
                    title: Text(
                      detail.$1,
                      style: const TextStyle(color: Color(0xFF9A8A9E)),
                    ),
                    trailing: Text(
                      detail.$2,
                      style: const TextStyle(color: Color(0xFFEEE0F0)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: hasInterest
                      ? null
                      : () async {
                          await onInterest();
                          if (context.mounted) Navigator.of(context).pop();
                        },
                  icon: const Icon(Icons.favorite_outline_rounded),
                  label: Text(hasInterest ? 'Interest sent' : 'Send interest'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
