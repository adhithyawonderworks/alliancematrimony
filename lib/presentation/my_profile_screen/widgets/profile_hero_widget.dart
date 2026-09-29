import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../routes/app_routes.dart';
import '../my_profile_screen.dart';

class ProfileHeroWidget extends StatelessWidget {
  final MyProfileData profile;
  final int completenessPercent;
  final XFile? selectedImageFile;
  final VoidCallback? onPhotoChange;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onDeleteAccount;
  final VoidCallback? onOpenDeletionPage;

  const ProfileHeroWidget({
    super.key,
    required this.profile,
    required this.completenessPercent,
    this.selectedImageFile,
    this.onPhotoChange,
    this.onSettingsTap,
    this.onDeleteAccount,
    this.onOpenDeletionPage,
  });

  ImageProvider<Object> _buildImageProvider() {
    if (selectedImageFile != null) {
      return FileImage(File(selectedImageFile!.path));
    }

    final source = profile.imageUrl.trim();
    if (source.isEmpty) {
      return const AssetImage('assets/images/placeholder_profile.png');
    }

    final file = File(source);
    if (file.existsSync()) {
      return FileImage(file);
    }

    return CachedNetworkImageProvider(source);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background blurred image
        SizedBox(
          height: 280,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _buildImageProvider(),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // Gradient overlay
        Container(
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF120D16).withAlpha(77),
                const Color(0xFF120D16).withAlpha(230),
              ],
            ),
          ),
        ),
        // SafeArea top padding + back space
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x1AFFFFFF),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(0x33FFFFFF),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite_rounded,
                                size: 12,
                                color: Color(0xFFC8556A),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'My Profile',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFEEE0F0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.notificationsScreen),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0x1AFFFFFF),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: const Color(0x33FFFFFF),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              size: 20,
                              color: Color(0xFFEEE0F0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onSettingsTap ?? () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: const Color(0xFF1E1520),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (sheetContext) => StatefulBuilder(
                            builder: (context, setSheetState) {
                              bool profileVisible = true;
                              bool privateMode = false;
                              bool pushNotifications = true;
                              bool emailAlerts = true;

                              return Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Profile Settings',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFEEE0F0),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    SwitchListTile.adaptive(
                                      value: profileVisible,
                                      onChanged: (value) => setSheetState(() => profileVisible = value),
                                      activeColor: const Color(0xFFC8556A),
                                      title: const Text(
                                        'Visible to matches',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          color: Color(0xFFEEE0F0),
                                        ),
                                      ),
                                      subtitle: const Text(
                                        'Let eligible profiles view your profile',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          color: Color(0xFF9A8A9E),
                                        ),
                                      ),
                                    ),
                                    SwitchListTile.adaptive(
                                      value: privateMode,
                                      onChanged: (value) => setSheetState(() => privateMode = value),
                                      activeColor: const Color(0xFFC8556A),
                                      title: const Text(
                                        'Private mode',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          color: Color(0xFFEEE0F0),
                                        ),
                                      ),
                                      subtitle: const Text(
                                        'Hide activity while keeping contact safe',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          color: Color(0xFF9A8A9E),
                                        ),
                                      ),
                                    ),
                                    SwitchListTile.adaptive(
                                      value: pushNotifications,
                                      onChanged: (value) => setSheetState(() => pushNotifications = value),
                                      activeColor: const Color(0xFFC8556A),
                                      title: const Text(
                                        'Push notifications',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          color: Color(0xFFEEE0F0),
                                        ),
                                      ),
                                      subtitle: const Text(
                                        'Get alerts for interests and messages',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          color: Color(0xFF9A8A9E),
                                        ),
                                      ),
                                    ),
                                    SwitchListTile.adaptive(
                                      value: emailAlerts,
                                      onChanged: (value) => setSheetState(() => emailAlerts = value),
                                      activeColor: const Color(0xFFC8556A),
                                      title: const Text(
                                        'Email alerts',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          color: Color(0xFFEEE0F0),
                                        ),
                                      ),
                                      subtitle: const Text(
                                        'Receive occasional account updates',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          color: Color(0xFF9A8A9E),
                                        ),
                                      ),
                                    ),
                                    if (onDeleteAccount != null)
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(
                                          Icons.delete_forever_outlined,
                                          color: Color(0xFFE57373),
                                        ),
                                        title: const Text(
                                          'Delete all user data',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFE57373),
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.pop(sheetContext);
                                          onDeleteAccount!();
                                        },
                                      ),
                                    if (onOpenDeletionPage != null)
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(
                                          Icons.open_in_new_rounded,
                                          color: Color(0xFFE57373),
                                        ),
                                        title: const Text(
                                          'Open account deletion page',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFE57373),
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.pop(sheetContext);
                                          onOpenDeletionPage!();
                                        },
                                      ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(sheetContext),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFC8556A),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Save Preferences',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0x1AFFFFFF),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: const Color(0x33FFFFFF),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.settings_outlined,
                              size: 20,
                              color: Color(0xFFEEE0F0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
                // Profile identity at bottom of hero
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Avatar circle with tappable camera button
                    GestureDetector(
                      onTap: onPhotoChange,
                      child: Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFC8556A),
                                width: 2.5,
                              ),
                            ),
                            child: ClipOval(
                              child: Image(
                                image: _buildImageProvider(),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFF2A1E2E),
                                  child: const Icon(
                                    Icons.person_outline_rounded,
                                    color: Color(0xFFCCBDD0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFFC8556A),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF120D16),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  profile.aadharVerified && profile.aadharName.isNotEmpty
                                      ? '${profile.firstName} ${profile.lastName.isNotEmpty ? '${profile.lastName[0]}***' : ''} (${profile.aadharName})'
                                      : '${profile.firstName} ${profile.lastName.isNotEmpty ? '${profile.lastName[0]}***' : ''}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFEEE0F0),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (profile.isVerified)
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 16,
                                  color: Color(0xFF4ADE80),
                                ),
                            ],
                          ),
                          Text(
                            '${profile.age} yrs • ${profile.place}',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              color: Color(0xFFCCBDD0),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.job,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: Color(0xFF9A8A9E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
