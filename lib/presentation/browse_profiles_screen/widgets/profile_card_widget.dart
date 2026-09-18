import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../browse_profiles_screen.dart';
import '../../../routes/app_routes.dart';
import '../../../services/app_localizations.dart';
import '../../../widgets/report_user_bottom_sheet.dart';

class ProfileCardWidget extends StatelessWidget {
  final MatrimonyProfile profile;
  final bool isPaid;
  final bool hasInterest;
  final VoidCallback onInterest;
  final VoidCallback? onChat;

  const ProfileCardWidget({
    super.key,
    required this.profile,
    required this.isPaid,
    required this.hasInterest,
    required this.onInterest,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1520),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: _buildPhotoSection(context)),
              Expanded(flex: 4, child: _buildInfoSection(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    final loc = AppLocalizations();
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: profile.imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: const Color(0xFF2A1E2E)),
          errorWidget: (_, __, ___) => Container(
            color: const Color(0xFF2A1E2E),
            child: const Icon(
              Icons.person_rounded,
              size: 48,
              color: Color(0xFF6B5870),
            ),
          ),
        ),
        if (!isPaid)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              color: const Color(0xFF120D16).withAlpha(180),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_rounded,
                      size: 28,
                      color: Color(0xFFC8556A),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.premiumLandingScreen),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC8556A), Color(0xFFE8A87C)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'View Now',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Positioned(
          top: 8,
          left: 8,
          child: Row(
            children: [
              if (profile.isNew)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    loc.get('new_label').toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (profile.isNew && profile.isVerified) const SizedBox(width: 4),
              if (profile.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D3D22),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 9,
                        color: Color(0xFF4ADE80),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        loc.get('verified'),
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4ADE80),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => ReportUserBottomSheet.show(
              context,
              reportedUserId: profile.id,
              reportedUserName: profile.displayName,
            ),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFF120D16).withAlpha(160),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withAlpha(30), width: 1),
              ),
              child: const Icon(
                Icons.flag_outlined,
                size: 13,
                color: Color(0xFFCCBDD0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final loc = AppLocalizations();
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.displayName,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFEEE0F0),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${profile.age} ${loc.get('years')} • ${profile.heightCm}',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              color: Color(0xFF9A8A9E),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(
                Icons.work_outline_rounded,
                size: 10,
                color: Color(0xFF9A8A9E),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  profile.job,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    color: Color(0xFF9A8A9E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 10,
                color: Color(0xFF9A8A9E),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  profile.place,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    color: Color(0xFF9A8A9E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 28,
                  child: ElevatedButton(
                    onPressed: onInterest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasInterest
                          ? const Color(0xFF2A1E2E)
                          : const Color(0xFFC8556A),
                      foregroundColor: hasInterest
                          ? const Color(0xFFC8556A)
                          : Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: hasInterest
                            ? const BorderSide(
                                color: Color(0xFFC8556A),
                                width: 1,
                              )
                            : BorderSide.none,
                      ),
                    ),
                    child: Text(
                      hasInterest
                          ? '${loc.get('interest_sent')} ✓'
                          : loc.get('send_interest'),
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                height: 28,
                width: 28,
                child: isPaid
                    ? ElevatedButton(
                        onPressed: onChat,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A1E2E),
                          foregroundColor: const Color(0xFFE8A87C),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                              color: Color(0xFFE8A87C),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 13,
                        ),
                      )
                    : GestureDetector(
                        onTap: () => context.push(AppRoutes.premiumLandingScreen),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A1E2E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF6B5870),
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.lock_rounded,
                              size: 13,
                              color: Color(0xFF6B5870),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
