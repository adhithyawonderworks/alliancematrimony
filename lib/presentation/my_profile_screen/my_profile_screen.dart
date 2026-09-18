import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/supabase_service.dart';
import '../../services/app_localizations.dart';
import '../../routes/app_routes.dart';
import './widgets/edit_family_section_widget.dart';
import './widgets/edit_personal_section_widget.dart';
import './widgets/edit_preferences_section_widget.dart';
import './widgets/language_settings_widget.dart';
import './widgets/payment_status_widget.dart';
import './widgets/profile_completeness_widget.dart';
import './widgets/profile_completion_tips_widget.dart';
import './widgets/profile_hero_widget.dart';
import './widgets/profile_info_section_widget.dart';
import './widgets/referral_section_widget.dart';

class MyProfileData {
  final String firstName;
  final String lastName;
  final int age;
  final String gender;
  final String dob;
  final String job;
  final String education;
  final String place;
  final String heightCm;
  final String weightKg;
  final String religion;
  final String caste;
  final String motherTongue;
  final String facebookLink;
  final String parentsName;
  final String parentsJob;
  final String email;
  final String phone;
  final String imageUrl;
  final String semanticLabel;
  final bool isPaid;
  final bool isVerified;
  final String referralCode;
  final int referralCount;
  final int referralCredits;
  final String partnerAgeRange;
  final String partnerHeightRange;
  final String partnerReligion;
  final String partnerPlace;

  const MyProfileData({
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.gender,
    required this.dob,
    required this.job,
    required this.education,
    required this.place,
    required this.heightCm,
    required this.weightKg,
    required this.religion,
    required this.caste,
    required this.motherTongue,
    required this.facebookLink,
    required this.parentsName,
    required this.parentsJob,
    required this.email,
    required this.phone,
    required this.imageUrl,
    required this.semanticLabel,
    required this.isPaid,
    required this.isVerified,
    required this.referralCode,
    required this.referralCount,
    required this.referralCredits,
    required this.partnerAgeRange,
    required this.partnerHeightRange,
    required this.partnerReligion,
    required this.partnerPlace,
  });

  factory MyProfileData.fromMap(Map<String, dynamic> map) {
    return MyProfileData(
      firstName: (map['firstName'] ?? map['first_name'] ?? '') as String,
      lastName: (map['lastName'] ?? map['last_name'] ?? '') as String,
      age: (map['age'] ?? 0) as int,
      gender: (map['gender'] ?? '') as String,
      dob: (map['dob'] ?? '') as String,
      job: (map['job'] ?? '') as String,
      education: (map['education'] ?? '') as String,
      place: (map['place'] ?? '') as String,
      heightCm: (map['heightCm'] ?? map['height_cm'] ?? '') as String,
      weightKg: (map['weightKg'] ?? map['weight_kg'] ?? '') as String,
      religion: (map['religion'] ?? '') as String,
      caste: (map['caste'] ?? '') as String,
      motherTongue:
          (map['motherTongue'] ?? map['mother_tongue'] ?? '') as String,
      facebookLink:
          (map['facebookLink'] ?? map['facebook_link'] ?? '') as String,
      parentsName: (map['parentsName'] ?? map['parents_name'] ?? '') as String,
      parentsJob: (map['parentsJob'] ?? map['parents_job'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      imageUrl: (map['imageUrl'] ?? map['image_url'] ?? '') as String,
      semanticLabel:
          (map['semanticLabel'] ?? map['semantic_label'] ?? '') as String,
      isPaid: (map['isPaid'] ?? map['is_paid'] ?? false) as bool,
      isVerified: (map['isVerified'] ?? map['is_verified'] ?? false) as bool,
      referralCode:
          (map['referralCode'] ?? map['referral_code'] ?? '') as String,
      referralCount:
          (map['referralCount'] ?? map['referral_count'] ?? 0) as int,
      referralCredits:
          (map['referralCredits'] ?? map['referral_credits'] ?? 0) as int,
      partnerAgeRange:
          (map['partnerAgeRange'] ?? map['partner_age_range'] ?? '') as String,
      partnerHeightRange:
          (map['partnerHeightRange'] ?? map['partner_height_range'] ?? '')
              as String,
      partnerReligion:
          (map['partnerReligion'] ?? map['partner_religion'] ?? '') as String,
      partnerPlace:
          (map['partnerPlace'] ?? map['partner_place'] ?? '') as String,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'age': age,
      'gender': gender,
      'dob': dob,
      'job': job,
      'education': education,
      'place': place,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'religion': religion,
      'caste': caste,
      'mother_tongue': motherTongue,
      'facebook_link': facebookLink,
      'parents_name': parentsName,
      'parents_job': parentsJob,
      'phone': phone,
      'image_url': imageUrl,
      'is_paid': isPaid,
      'is_verified': isVerified,
      'referral_code': referralCode,
      'referral_count': referralCount,
      'referral_credits': referralCredits,
      'partner_age_range': partnerAgeRange,
      'partner_height_range': partnerHeightRange,
      'partner_religion': partnerReligion,
      'partner_place': partnerPlace,
    };
  }

  MyProfileData copyWithEdits({
    String? firstName,
    String? lastName,
    String? dob,
    String? motherTongue,
    String? religion,
    String? caste,
    String? job,
    String? education,
    String? place,
    String? heightCm,
    String? weightKg,
    String? facebookLink,
    String? parentsName,
    String? parentsJob,
    String? partnerAgeRange,
    String? partnerHeightRange,
    String? partnerReligion,
    String? partnerPlace,
  }) {
    return MyProfileData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age,
      gender: gender,
      dob: dob ?? this.dob,
      job: job ?? this.job,
      education: education ?? this.education,
      place: place ?? this.place,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
      motherTongue: motherTongue ?? this.motherTongue,
      facebookLink: facebookLink ?? this.facebookLink,
      parentsName: parentsName ?? this.parentsName,
      parentsJob: parentsJob ?? this.parentsJob,
      email: email,
      phone: phone,
      imageUrl: imageUrl,
      semanticLabel: semanticLabel,
      isPaid: isPaid,
      isVerified: isVerified,
      referralCode: referralCode,
      referralCount: referralCount,
      referralCredits: referralCredits,
      partnerAgeRange: partnerAgeRange ?? this.partnerAgeRange,
      partnerHeightRange: partnerHeightRange ?? this.partnerHeightRange,
      partnerReligion: partnerReligion ?? this.partnerReligion,
      partnerPlace: partnerPlace ?? this.partnerPlace,
    );
  }
}

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  static const _accountDeletionUrl = String.fromEnvironment(
    'ACCOUNT_DELETION_URL',
    defaultValue: 'https://www.alliancematrimony.online/delete-account.html',
  );

  late MyProfileData _profile;
  bool _isPaid = false;
  bool _isEditMode = false;
  bool _isSaving = false;
  bool _isLoading = true;
  XFile? _selectedProfileImage;
  final AppLocalizations _localizations = AppLocalizations();

  // Edit buffers — updated live by child widgets
  Map<String, String> _personalEdits = {};
  Map<String, String> _familyEdits = {};
  Map<String, String> _preferencesEdits = {};

  String _buildDeletionLink() {
    return Uri.parse(_accountDeletionUrl).toString();
  }

  Future<void> _copyDeletionLink(String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data deletion link copied'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openAccountDeletionPage() async {
    final uri = Uri.parse(_accountDeletionUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open the account deletion page'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDeletionEmail(MyProfileData profile) async {
    final link = _buildDeletionLink();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1520),
        title: const Text(
          'Request data deletion?',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: Color(0xFFEEE0F0),
          ),
        ),
        content: const Text(
          'This opens your email app with a prepared request to delete your profile and account data.',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: Color(0xFFCCBDD0),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC8556A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm & Email Link'),
          ),
        ],
      ),
    );
    if (confirmed != true || profile.email.trim().isEmpty) {
      if (confirmed == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No email address is saved in this profile'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final emailUri = Uri(
      scheme: 'mailto',
      path: profile.email.trim(),
      queryParameters: {
        'subject': 'Request to delete my Alliance Matrimony data',
        'body': 'Please delete my profile and account data using this link:\n$link',
      },
    );
    if (!await launchUrl(emailUri) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No email app is available on this device'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmCompleteDeletion() async {
    final confirmationController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1520),
        title: const Text(
          'Delete all account data?',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: Color(0xFFEEE0F0),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This permanently deletes your profile, interests, chats, reports, purchases, notifications, and account. This cannot be undone.',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: Color(0xFFCCBDD0),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmationController,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Type DELETE to continue',
                labelStyle: TextStyle(color: Color(0xFF9A8A9E)),
              ),
              style: const TextStyle(color: Color(0xFFEEE0F0)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              confirmationController.text.trim().toUpperCase() == 'DELETE',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );
    confirmationController.dispose();

    if (confirmed != true || !mounted) return;
    setState(() => _isLoading = true);
    try {
      await SupabaseService.instance.deleteCurrentUserData();
      if (!mounted) return;
      context.go(AppRoutes.initial);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deletion failed: $error'),
          backgroundColor: const Color(0xFFB91C1C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static const Map<String, dynamic> _fallbackProfileMap = {
    'firstName': 'Priya',
    'lastName': 'Sharma',
    'age': 27,
    'gender': 'Female',
    'dob': '14 March 1998',
    'job': 'Software Engineer',
    'education': 'B.Tech Computer Science, IIT Madras',
    'place': 'Chennai, Tamil Nadu',
    'heightCm': '163 cm',
    'weightKg': '55 kg',
    'religion': 'Hindu',
    'caste': 'Brahmin',
    'motherTongue': 'Tamil',
    'facebookLink': 'https://facebook.com/priya.sharma.matrimony',
    'parentsName': 'Ramesh Sharma & Lakshmi Sharma',
    'parentsJob': 'Retired IAS Officer & School Principal',
    'email': 'priya.sharma@alliancematrimony.in',
    'phone': '+91 98765 43210',
    'imageUrl':
        'https://img.rocket.new/generatedImages/rocket_gen_img_19205d2aa-1763296356182.png',
    'semanticLabel':
        'Young Indian woman with long dark hair smiling warmly in professional attire',
    'isPaid': false,
    'isVerified': true,
    'referralCode': 'PRIYA2026',
    'referralCount': 2,
    'referralCredits': 200,
    'partnerAgeRange': '28 – 34 years',
    'partnerHeightRange': '170 cm and above',
    'partnerReligion': 'Hindu',
    'partnerPlace': 'Tamil Nadu / Karnataka',
  };

  @override
  void initState() {
    super.initState();
    _profile = MyProfileData.fromMap(_fallbackProfileMap);
    _loadProfile();
    _localizations.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _localizations.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService.instance.fetchProfile();
      if (data != null && mounted) {
        setState(() {
          _profile = MyProfileData.fromMap(data);
          _isPaid = _profile.isPaid;
        });
      }
    } catch (_) {
      // Keep fallback profile
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _computeCompleteness(MyProfileData p) {
    int filled = 0;
    const total = 10;
    if (p.firstName.isNotEmpty) filled++;
    if (p.job.isNotEmpty) filled++;
    if (p.place.isNotEmpty) filled++;
    if (p.education.isNotEmpty) filled++;
    if (p.religion.isNotEmpty) filled++;
    if (p.parentsName.isNotEmpty) filled++;
    if (p.facebookLink.isNotEmpty) filled++;
    if (p.partnerAgeRange.isNotEmpty) filled++;
    if (p.imageUrl.isNotEmpty) filled++;
    if (p.isPaid) filled++;
    return ((filled / total) * 100).round();
  }

  /// Build a live preview profile from current edit buffers
  MyProfileData get _liveProfile {
    if (!_isEditMode) return _profile;
    return _profile.copyWithEdits(
      firstName: _personalEdits['firstName'],
      lastName: _personalEdits['lastName'],
      dob: _personalEdits['dob'],
      motherTongue: _personalEdits['motherTongue'],
      religion: _personalEdits['religion'],
      caste: _personalEdits['caste'],
      job: _personalEdits['job'],
      education: _personalEdits['education'],
      place: _personalEdits['place'],
      heightCm: _personalEdits['heightCm'],
      weightKg: _personalEdits['weightKg'],
      facebookLink: _personalEdits['facebookLink'],
      parentsName: _familyEdits['parentsName'],
      parentsJob: _familyEdits['parentsJob'],
      partnerAgeRange: _preferencesEdits['partnerAgeRange'],
      partnerHeightRange: _preferencesEdits['partnerHeightRange'],
      partnerReligion: _preferencesEdits['partnerReligion'],
      partnerPlace: _preferencesEdits['partnerPlace'],
    );
  }

  void _enterEditMode() {
    setState(() {
      _isEditMode = true;
      _personalEdits = {
        'firstName': _profile.firstName,
        'lastName': _profile.lastName,
        'dob': _profile.dob,
        'motherTongue': _profile.motherTongue,
        'religion': _profile.religion,
        'caste': _profile.caste,
        'job': _profile.job,
        'education': _profile.education,
        'place': _profile.place,
        'heightCm': _profile.heightCm,
        'weightKg': _profile.weightKg,
        'facebookLink': _profile.facebookLink,
      };
      _familyEdits = {
        'parentsName': _profile.parentsName,
        'parentsJob': _profile.parentsJob,
      };
      _preferencesEdits = {
        'partnerAgeRange': _profile.partnerAgeRange,
        'partnerHeightRange': _profile.partnerHeightRange,
        'partnerReligion': _profile.partnerReligion,
        'partnerPlace': _profile.partnerPlace,
      };
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      _personalEdits = {};
      _familyEdits = {};
      _preferencesEdits = {};
    });
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final updated = _liveProfile;
    try {
      final success = await SupabaseService.instance.upsertProfile(
        updated.toSupabaseMap(),
      );
      if (!mounted) return;
      if (success) {
        setState(() {
          _profile = updated;
          _isEditMode = false;
          _personalEdits = {};
          _familyEdits = {};
          _preferencesEdits = {};
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _localizations.get('profile_saved'),
              style: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
            ),
            backgroundColor: const Color(0xFF1E1520),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _localizations.get('profile_save_error'),
              style: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
            ),
            backgroundColor: const Color(0xFFC8556A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
            ),
          ),
          backgroundColor: const Color(0xFFC8556A),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final live = _liveProfile;
    final completeness = _computeCompleteness(live);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFF120D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF120D16),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _localizations.get('my_profile'),
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: _buildAppBarActions(),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFC8556A)),
            )
          : isTablet
          ? _buildTabletLayout(live, completeness)
          : _buildPhoneLayout(live, completeness),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isEditMode) {
      return [
        TextButton.icon(
          onPressed: _cancelEdit,
          icon: const Icon(
            Icons.close_rounded,
            size: 16,
            color: Color(0xFF9A8A9E),
          ),
          label: Text(
            _localizations.get('cancel'),
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9A8A9E),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton.icon(
            onPressed: _isSaving ? null : _saveProfile,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFC8556A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: _isSaving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 16),
            label: Text(
              _isSaving
                  ? _localizations.get('saving')
                  : _localizations.get('save_changes'),
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ];
    }
    return [
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: TextButton.icon(
          onPressed: _enterEditMode,
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFC8556A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          icon: const Icon(Icons.edit_rounded, size: 16),
          label: Text(
            _localizations.get('edit_profile'),
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: IconButton(
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            if (context.mounted) {
              context.go(AppRoutes.signUpLoginScreen);
            }
          },
          icon: const Icon(
            Icons.logout_rounded,
            color: Color(0xFF9A8A9E),
            size: 22,
          ),
          tooltip: 'Logout',
        ),
      ),
    ];
  }

  Widget _buildFAB() {
    return const SizedBox.shrink();
  }

  Widget _buildPhoneLayout(MyProfileData live, int completeness) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ProfileHeroWidget(
            profile: live,
            completenessPercent: completeness,
            selectedImageFile: _selectedProfileImage,
            onPhotoChange: _handlePhotoChange,
            onSettingsTap: () {
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
                              _openAccountDeletionPage();
                            },
                          ),
                          const Divider(color: Color(0x1AFFFFFF)),
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
                            subtitle: const Text(
                              'Permanently delete your account and profile',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                color: Color(0xFF9A8A9E),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              _confirmCompleteDeletion();
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
          ),
        ),
        SliverToBoxAdapter(
          child: ProfileCompletenessWidget(percent: completeness),
        ),
        SliverToBoxAdapter(
          child: ProfileCompletionTipsWidget(profile: live),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _isEditMode
                    ? EditPersonalSectionWidget(
                        initialValues: _personalEdits,
                        onChanged: (vals) =>
                            setState(() => _personalEdits = vals),
                      )
                    : ProfileInfoSectionWidget(
                        title: _localizations.get('personal_info'),
                        icon: Icons.person_outline_rounded,
                        fields: [
                          ProfileField(
                            _localizations.get('name'),
                            '${live.firstName} ${live.lastName.isNotEmpty ? '${live.lastName[0]}***' : ''}',
                          ),
                          ProfileField(
                            _localizations.get('age'),
                            '${live.age} ${_localizations.get('years')}',
                          ),
                          ProfileField(
                            _localizations.get('gender'),
                            live.gender,
                          ),
                          ProfileField(_localizations.get('dob'), live.dob),
                          ProfileField(
                            _localizations.get('mother_tongue'),
                            live.motherTongue,
                          ),
                          ProfileField(
                            _localizations.get('religion'),
                            live.religion,
                          ),
                          ProfileField(_localizations.get('caste'), live.caste),
                        ],
                      ),
                const SizedBox(height: 14),
                _isEditMode
                    ? const SizedBox.shrink()
                    : ProfileInfoSectionWidget(
                        title: 'Professional Details',
                        icon: Icons.work_outline_rounded,
                        fields: [
                          ProfileField(
                            _localizations.get('occupation'),
                            live.job,
                          ),
                          ProfileField(
                            _localizations.get('education'),
                            live.education,
                          ),
                          ProfileField(
                            _localizations.get('location'),
                            live.place,
                          ),
                          ProfileField(
                            _localizations.get('height'),
                            live.heightCm,
                          ),
                          ProfileField(
                            _localizations.get('weight'),
                            live.weightKg,
                          ),
                        ],
                      ),
                if (!_isEditMode) const SizedBox(height: 14),
                _isEditMode
                    ? EditFamilySectionWidget(
                        initialValues: _familyEdits,
                        onChanged: (vals) =>
                            setState(() => _familyEdits = vals),
                      )
                    : ProfileInfoSectionWidget(
                        title: _localizations.get('family_info'),
                        icon: Icons.family_restroom_rounded,
                        fields: [
                          ProfileField(
                            _localizations.get('parents_name'),
                            live.parentsName,
                          ),
                          ProfileField(
                            _localizations.get('parents_occupation'),
                            live.parentsJob,
                          ),
                        ],
                      ),
                const SizedBox(height: 14),
                _isEditMode
                    ? EditPreferencesSectionWidget(
                        initialValues: _preferencesEdits,
                        onChanged: (vals) =>
                            setState(() => _preferencesEdits = vals),
                      )
                    : ProfileInfoSectionWidget(
                        title: _localizations.get('partner_preferences'),
                        icon: Icons.favorite_border_rounded,
                        fields: [
                          ProfileField(
                            _localizations.get('partner_age'),
                            live.partnerAgeRange,
                          ),
                          ProfileField(
                            _localizations.get('partner_height'),
                            live.partnerHeightRange,
                          ),
                          ProfileField(
                            _localizations.get('partner_religion'),
                            live.partnerReligion,
                          ),
                          ProfileField(
                            _localizations.get('partner_location'),
                            live.partnerPlace,
                          ),
                        ],
                      ),
                const SizedBox(height: 14),
                PaymentStatusWidget(
                  isPaid: _isPaid,
                  onPay: () => setState(() => _isPaid = true),
                ),
                const SizedBox(height: 10),
                _buildTrustSafetyCard(live),
                const SizedBox(height: 10),
                _buildDataDeletionCard(live),
                const SizedBox(height: 10),
                // View purchases button
                GestureDetector(
                  onTap: () => context.push(AppRoutes.premiumPurchasesScreen),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1520),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2A1E2E)),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 16,
                          color: Color(0xFFE8A87C),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'View Purchases & Subscription',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFCCBDD0),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: Color(0xFF6B5870),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ReferralSectionWidget(
                  referralCode: live.referralCode,
                  referralCount: live.referralCount,
                  referralCredits: live.referralCredits,
                ),
                const SizedBox(height: 14),
                const LanguageSettingsWidget(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrustSafetyCard(MyProfileData live) {
    final verificationSteps = [
      {'label': 'Phone verified', 'isDone': live.phone.isNotEmpty},
      {'label': 'Profile photo reviewed', 'isDone': live.imageUrl.isNotEmpty},
      {'label': 'Identity checked', 'isDone': live.isVerified},
      {'label': 'Safe messaging enabled', 'isDone': true},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1520),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A1E2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: live.isVerified
                      ? const Color(0xFF2D7A4F).withAlpha(50)
                      : const Color(0xFF3A2A40),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  live.isVerified
                      ? Icons.verified_rounded
                      : Icons.shield_outlined,
                  size: 16,
                  color: live.isVerified
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFFCCBDD0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trust & Safety',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEEE0F0),
                      ),
                    ),
                    Text(
                      live.isVerified ? 'Verified profile' : 'Verification in progress',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: Color(0xFF9A8A9E),
                      ),
                    ),
                  ],
                ),
              ),
              if (live.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D3D22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Verified',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4ADE80),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...verificationSteps.map((step) {
            final isDone = step['isDone'] as bool;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    size: 14,
                    color: isDone ? const Color(0xFF4ADE80) : const Color(0xFF6B5870),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step['label'] as String,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: Color(0xFFCCBDD0),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          const Text(
            'Report suspicious activity anytime from a profile card or chat screen.',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              color: Color(0xFF9A8A9E),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataDeletionCard(MyProfileData live) {
    final deletionLink = _buildDeletionLink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1520),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5A2835)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.delete_forever_outlined, color: Color(0xFFE57373), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Delete profile and data',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEEE0F0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Use this link to request deletion of your profile, account, and associated data.',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              color: Color(0xFF9A8A9E),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF120D16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    deletionLink,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      color: Color(0xFFCCBDD0),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy deletion link',
                  onPressed: () => _copyDeletionLink(deletionLink),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  color: const Color(0xFFE8A87C),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmDeletionEmail(live),
              icon: const Icon(Icons.email_outlined, size: 17),
              label: const Text('Confirm & email me this link'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE57373),
                side: const BorderSide(color: Color(0xFF8E3E4D)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(MyProfileData live, int completeness) {
    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.38,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ProfileHeroWidget(
                    profile: live,
                    completenessPercent: completeness,
                    selectedImageFile: _selectedProfileImage,
                    onPhotoChange: _handlePhotoChange,
                    onDeleteAccount: _confirmCompleteDeletion,
                    onOpenDeletionPage: _openAccountDeletionPage,
                  ),
                  const SizedBox(height: 14),
                  ProfileCompletenessWidget(percent: completeness),
                  const SizedBox(height: 14),
                  PaymentStatusWidget(
                    isPaid: _isPaid,
                    onPay: () => setState(() => _isPaid = true),
                  ),
                  const SizedBox(height: 10),
                  _buildTrustSafetyCard(live),
                  const SizedBox(height: 10),
                  _buildDataDeletionCard(live),
                  const SizedBox(height: 10),
                  // View purchases button
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.premiumPurchasesScreen),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1520),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2A1E2E)),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 16,
                            color: Color(0xFFE8A87C),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'View Purchases & Subscription',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFCCBDD0),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: Color(0xFF6B5870),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ReferralSectionWidget(
                    referralCode: live.referralCode,
                    referralCount: live.referralCount,
                    referralCredits: live.referralCredits,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
              child: Column(
                children: [
                  _isEditMode
                      ? EditPersonalSectionWidget(
                          initialValues: _personalEdits,
                          onChanged: (vals) =>
                              setState(() => _personalEdits = vals),
                        )
                      : ProfileInfoSectionWidget(
                          title: 'Personal Information',
                          icon: Icons.person_outline_rounded,
                          fields: [
                            ProfileField(
                              'Full Name',
                              '${live.firstName} ${live.lastName.isNotEmpty ? '${live.lastName[0]}***' : ''}',
                            ),
                            ProfileField('Age', '${live.age} years'),
                            ProfileField('Gender', live.gender),
                            ProfileField('Date of Birth', live.dob),
                            ProfileField('Mother Tongue', live.motherTongue),
                            ProfileField('Religion', live.religion),
                            ProfileField('Caste', live.caste),
                          ],
                        ),
                  const SizedBox(height: 14),
                  if (!_isEditMode)
                    ProfileInfoSectionWidget(
                      title: 'Professional Details',
                      icon: Icons.work_outline_rounded,
                      fields: [
                        ProfileField('Occupation', live.job),
                        ProfileField('Education', live.education),
                        ProfileField('City', live.place),
                        ProfileField('Height', live.heightCm),
                        ProfileField('Weight', live.weightKg),
                      ],
                    ),
                  if (!_isEditMode) const SizedBox(height: 14),
                  _isEditMode
                      ? EditFamilySectionWidget(
                          initialValues: _familyEdits,
                          onChanged: (vals) =>
                              setState(() => _familyEdits = vals),
                        )
                      : ProfileInfoSectionWidget(
                          title: 'Family Details',
                          icon: Icons.family_restroom_rounded,
                          fields: [
                            ProfileField("Parents' Name", live.parentsName),
                            ProfileField(
                              "Parents' Occupation",
                              live.parentsJob,
                            ),
                          ],
                        ),
                  const SizedBox(height: 14),
                  _isEditMode
                      ? EditPreferencesSectionWidget(
                          initialValues: _preferencesEdits,
                          onChanged: (vals) =>
                              setState(() => _preferencesEdits = vals),
                        )
                      : ProfileInfoSectionWidget(
                          title: 'Partner Preferences',
                          icon: Icons.favorite_border_rounded,
                          fields: [
                            ProfileField('Age Range', live.partnerAgeRange),
                            ProfileField('Height', live.partnerHeightRange),
                            ProfileField('Religion', live.partnerReligion),
                            ProfileField('Location', live.partnerPlace),
                          ],
                        ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePhotoChange() async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1520),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Profile Photo',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEEE0F0),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: Color(0xFFC8556A),
              ),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFFEEE0F0),
                ),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 92,
                );
                if (pickedFile != null && mounted) {
                  setState(() => _selectedProfileImage = pickedFile);
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: Color(0xFFC8556A),
              ),
              title: const Text(
                'Take a Photo',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFFEEE0F0),
                ),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final pickedFile = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 92,
                );
                if (pickedFile != null && mounted) {
                  setState(() => _selectedProfileImage = pickedFile);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
