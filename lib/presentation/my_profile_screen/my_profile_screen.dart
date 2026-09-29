import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/india_location_data.dart';
import '../../core/profile_relationship_data.dart';
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
import './widgets/security_settings_widget.dart';

class MyProfileData {
  final String firstName;
  final String lastName;
  final String otherName;
  final String aadharName;
  final String aadharImageUrl;
  final String aadharVerificationStatus;
  final bool aadharVerified;
  final int age;
  final String gender;
  final String maritalStatus;
  final String profileManagedBy;
  final String dob;
  final String birthCity;
  final String birthDistrict;
  final String birthState;
  final String birthTime;
  final String job;
  final String education;
  final String schoolName;
  final String collegeName;
  final String universityName;
  final String place;
  final String stateName;
  final String city;
  final String currentCity;
  final bool currentCitySameAsPrimaryAddress;
  final String stayDuration;
  final String stayReason;
  final String primaryAddress;
  final String primaryAddressStayPeriod;
  final String heightCm;
  final String weightKg;
  final String religion;
  final String caste;
  final String motherTongue;
  final String facebookLink;
  final String parentsName;
  final String parentsJob;
  final String fatherName;
  final bool fatherIsDeceased;
  final String fatherJob;
  final String motherName;
  final bool motherIsDeceased;
  final String motherJob;
  final List<Map<String, dynamic>> siblings;
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
  final String partnerAgeMin;
  final String partnerAgeMax;
  final String partnerHeightRange;
  final String partnerHeightCm;
  final String partnerHeightFeet;
  final String partnerHeightInches;
  final String partnerReligion;
  final String partnerReligionMode;
  final String partnerCaste;
  final String partnerGender;
  final String partnerMaritalStatus;
  final String partnerPlace;
  final String partnerLocationMode;
  final String partnerState;
  final String partnerDistrict;
  final String partnerCountry;
  final String partnerLanguage;
  final String partnerLanguages;

  const MyProfileData({
    required this.firstName,
    required this.lastName,
    this.otherName = '',
    this.aadharName = '',
    this.aadharImageUrl = '',
    this.aadharVerificationStatus = 'not_submitted',
    this.aadharVerified = false,
    required this.age,
    required this.gender,
    this.maritalStatus = 'Single',
    this.profileManagedBy = 'self',
    required this.dob,
      this.birthCity = '',
      this.birthDistrict = '',
      this.birthState = '',
      this.birthTime = '',
    required this.job,
    required this.education,
    this.schoolName = '',
    this.collegeName = '',
    this.universityName = '',
    required this.place,
    this.stateName = '',
    this.city = '',
    this.currentCity = '',
    this.currentCitySameAsPrimaryAddress = false,
    this.stayDuration = '',
    this.stayReason = '',
    this.primaryAddress = '',
    this.primaryAddressStayPeriod = '',
    required this.heightCm,
    required this.weightKg,
    required this.religion,
    required this.caste,
    required this.motherTongue,
    required this.facebookLink,
    required this.parentsName,
    required this.parentsJob,
    this.fatherName = '',
    this.fatherIsDeceased = false,
    this.fatherJob = '',
    this.motherName = '',
    this.motherIsDeceased = false,
    this.motherJob = '',
    this.siblings = const [],
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
    this.partnerAgeMin = '',
    this.partnerAgeMax = '',
    required this.partnerHeightRange,
    this.partnerHeightCm = '',
    this.partnerHeightFeet = '',
    this.partnerHeightInches = '',
    required this.partnerReligion,
    this.partnerReligionMode = 'any_religion',
    this.partnerCaste = '',
    this.partnerGender = 'No preference',
    this.partnerMaritalStatus = 'No preference',
    required this.partnerPlace,
    this.partnerLocationMode = 'Anywhere in the world',
    this.partnerState = '',
    this.partnerDistrict = 'No district preference',
    this.partnerCountry = '',
    this.partnerLanguage = 'No preference',
    this.partnerLanguages = '',
  });

  factory MyProfileData.fromMap(Map<String, dynamic> map) {
    return MyProfileData(
      firstName: (map['firstName'] ?? map['first_name'] ?? '') as String,
      lastName: (map['lastName'] ?? map['last_name'] ?? '') as String,
      otherName: (map['otherName'] ?? map['other_name'] ?? '') as String,
      aadharName: (map['aadharName'] ?? map['aadhar_name'] ?? '') as String,
      aadharImageUrl:
          (map['aadharImageUrl'] ?? map['aadhar_image_url'] ?? '') as String,
      aadharVerificationStatus:
          (map['aadharVerificationStatus'] ??
                  map['aadhar_verification_status'] ??
                  'not_submitted')
              as String,
      aadharVerified:
          (map['aadharVerified'] ?? map['aadhar_verified'] ?? false) as bool,
      age: (map['age'] ?? 0) as int,
      gender: (map['gender'] ?? '') as String,
      maritalStatus:
          (map['maritalStatus'] ?? map['marital_status'] ?? 'Single') as String,
      profileManagedBy:
          (map['profileManagedBy'] ?? map['profile_managed_by'] ?? 'self')
              as String,
      dob: (map['dob'] ?? '') as String,
        birthCity: (map['birth_city'] ?? map['birthCity'] ?? '') as String,
        birthDistrict:
          (map['birth_district'] ?? map['birthDistrict'] ?? '') as String,
        birthState: (map['birth_state'] ?? map['birthState'] ?? '') as String,
        birthTime:
          (map['horoscope_birth_time'] ?? map['birthTime'] ?? '') as String,
      job: (map['job'] ?? '') as String,
      education: (map['education'] ?? '') as String,
      schoolName: (map['school_name'] ?? map['schoolName'] ?? '') as String,
      collegeName: (map['college_name'] ?? map['collegeName'] ?? '') as String,
      universityName:
          (map['university_name'] ?? map['universityName'] ?? '') as String,
      place: (map['place'] ?? '') as String,
      stateName: (map['stateName'] ?? map['state_name'] ?? '') as String,
      city: (map['city'] ?? '') as String,
      currentCity: (map['currentCity'] ?? map['current_city'] ?? '') as String,
      currentCitySameAsPrimaryAddress:
          (map['current_city_same_as_primary_address'] ?? false) as bool,
      stayDuration:
          (map['stayDuration'] ?? map['stay_duration'] ?? '') as String,
      stayReason: (map['stayReason'] ?? map['stay_reason'] ?? '') as String,
      primaryAddress:
          (map['primary_address'] ?? map['primaryAddress'] ?? '') as String,
      primaryAddressStayPeriod:
          (map['primary_address_stay_period'] ??
                  map['primaryAddressStayPeriod'] ??
                  '')
              as String,
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
      fatherName: (map['fatherName'] ?? map['father_name'] ?? '') as String,
      fatherIsDeceased:
          (map['fatherIsDeceased'] ?? map['father_is_deceased'] ?? false)
              as bool,
      fatherJob: (map['fatherJob'] ?? map['father_job'] ?? '') as String,
      motherName: (map['motherName'] ?? map['mother_name'] ?? '') as String,
      motherIsDeceased:
          (map['motherIsDeceased'] ?? map['mother_is_deceased'] ?? false)
              as bool,
      motherJob: (map['motherJob'] ?? map['mother_job'] ?? '') as String,
      siblings: ((map['siblings'] as List?) ?? const [])
          .whereType<Map>()
          .map((sibling) => Map<String, dynamic>.from(sibling))
          .toList(),
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
      partnerAgeMin: (map['partner_age_min'] ?? '') as String,
      partnerAgeMax: (map['partner_age_max'] ?? '') as String,
      partnerHeightRange:
          (map['partnerHeightRange'] ?? map['partner_height_range'] ?? '')
              as String,
      partnerHeightCm: (map['partner_height_cm'] ?? '') as String,
      partnerHeightFeet: (map['partner_height_feet'] ?? '') as String,
      partnerHeightInches: (map['partner_height_inches'] ?? '') as String,
      partnerReligion:
          (map['partnerReligion'] ?? map['partner_religion'] ?? '') as String,
      partnerReligionMode:
          (map['partner_religion_mode'] ?? 'any_religion') as String,
      partnerCaste: (map['partner_caste'] ?? '') as String,
      partnerGender:
          (map['partnerGender'] ?? map['partner_gender'] ?? 'No preference')
              as String,
      partnerMaritalStatus:
          (map['partnerMaritalStatus'] ??
                  map['partner_marital_status'] ??
                  'No preference')
              as String,
      partnerPlace:
          (map['partnerPlace'] ?? map['partner_place'] ?? '') as String,
      partnerLocationMode:
          (map['partner_location_mode'] ?? 'Anywhere in the world') as String,
      partnerState: (map['partner_state'] ?? '') as String,
      partnerDistrict:
          (map['partner_district'] ?? 'No district preference') as String,
      partnerCountry: (map['partner_country'] ?? '') as String,
      partnerLanguage: (map['partner_language'] ?? 'No preference') as String,
      partnerLanguages: (map['partner_languages'] ?? '') as String,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'other_name': otherName,
      // aadhar_name/aadhar_image_url are written via submitAadharVerification();
      // aadhar_verified is admin-only (see trg_prevent_self_aadhar_verification) and
      // must never be sent by the client.
      'age': age,
      'gender': gender,
      'marital_status': maritalStatus,
      'profile_managed_by': profileManagedBy,
      'dob': dob,
      'birth_city': birthCity,
      'birth_district': birthDistrict,
      'birth_state': birthState,
      'horoscope_birth_time': birthTime,
      'job': job,
      'education': education,
      'school_name': schoolName,
      'college_name': collegeName,
      'university_name': universityName,
      'place': place,
      'state_name': stateName,
      'city': city,
      'current_city': currentCity,
      'current_city_same_as_primary_address': currentCitySameAsPrimaryAddress,
      'stay_duration': stayDuration,
      'stay_reason': stayReason,
      'primary_address': primaryAddress,
      'primary_address_stay_period': primaryAddressStayPeriod,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'religion': religion,
      'caste': caste,
      'mother_tongue': motherTongue,
      'facebook_link': facebookLink,
      'parents_name': parentsName,
      'parents_job': parentsJob,
      'father_name': fatherName,
      'father_is_deceased': fatherIsDeceased,
      'father_job': fatherJob,
      'mother_name': motherName,
      'mother_is_deceased': motherIsDeceased,
      'mother_job': motherJob,
      'siblings': siblings,
      'phone': phone,
      'image_url': imageUrl,
      'is_paid': isPaid,
      // is_verified is intentionally omitted: it's admin-only (see DB trigger
      // trg_prevent_self_verification) and must never be sent by the client.
      'referral_code': referralCode,
      'referral_count': referralCount,
      'referral_credits': referralCredits,
      'partner_age_range': partnerAgeRange,
      'partner_age_min': partnerAgeMin,
      'partner_age_max': partnerAgeMax,
      'partner_height_range': partnerHeightRange,
      'partner_height_cm': partnerHeightCm,
      'partner_height_feet': partnerHeightFeet,
      'partner_height_inches': partnerHeightInches,
      'partner_religion': partnerReligion,
      'partner_religion_mode': partnerReligionMode,
      'partner_caste': partnerCaste,
      'partner_gender': partnerGender,
      'partner_marital_status': partnerMaritalStatus,
      'partner_place': partnerPlace,
      'partner_location_mode': partnerLocationMode,
      'partner_state': partnerState,
      'partner_district': partnerDistrict,
      'partner_country': partnerCountry,
      'partner_language': partnerLanguage,
      'partner_languages': partnerLanguages,
    };
  }

  MyProfileData copyWithEdits({
    String? firstName,
    String? lastName,
    String? otherName,
    String? gender,
    String? maritalStatus,
    String? profileManagedBy,
    String? dob,
    String? birthCity,
    String? birthDistrict,
    String? birthState,
    String? birthTime,
    String? motherTongue,
    String? religion,
    String? caste,
    String? job,
    String? education,
    String? schoolName,
    String? collegeName,
    String? universityName,
    String? place,
    String? stateName,
    String? city,
    String? currentCity,
    bool? currentCitySameAsPrimaryAddress,
    String? stayDuration,
    String? stayReason,
    String? primaryAddress,
    String? primaryAddressStayPeriod,
    String? heightCm,
    String? weightKg,
    String? imageUrl,
    String? facebookLink,
    String? parentsName,
    String? parentsJob,
    String? fatherName,
    bool? fatherIsDeceased,
    String? fatherJob,
    String? motherName,
    bool? motherIsDeceased,
    String? motherJob,
    List<Map<String, dynamic>>? siblings,
    String? partnerAgeRange,
    String? partnerAgeMin,
    String? partnerAgeMax,
    String? partnerHeightRange,
    String? partnerHeightCm,
    String? partnerHeightFeet,
    String? partnerHeightInches,
    String? partnerReligion,
    String? partnerReligionMode,
    String? partnerCaste,
    String? partnerGender,
    String? partnerMaritalStatus,
    String? partnerPlace,
    String? partnerLocationMode,
    String? partnerState,
    String? partnerDistrict,
    String? partnerCountry,
    String? partnerLanguage,
    String? partnerLanguages,
  }) {
    return MyProfileData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      otherName: otherName ?? this.otherName,
      aadharName: aadharName,
      aadharImageUrl: aadharImageUrl,
      aadharVerificationStatus: aadharVerificationStatus,
      aadharVerified: aadharVerified,
      age: age,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      profileManagedBy: profileManagedBy ?? this.profileManagedBy,
      dob: dob ?? this.dob,
      birthCity: birthCity ?? this.birthCity,
      birthDistrict: birthDistrict ?? this.birthDistrict,
      birthState: birthState ?? this.birthState,
      birthTime: birthTime ?? this.birthTime,
      job: job ?? this.job,
      education: education ?? this.education,
      schoolName: schoolName ?? this.schoolName,
      collegeName: collegeName ?? this.collegeName,
      universityName: universityName ?? this.universityName,
      place: place ?? this.place,
      stateName: stateName ?? this.stateName,
      city: city ?? this.city,
      currentCity: currentCity ?? this.currentCity,
      currentCitySameAsPrimaryAddress:
          currentCitySameAsPrimaryAddress ??
          this.currentCitySameAsPrimaryAddress,
      stayDuration: stayDuration ?? this.stayDuration,
      stayReason: stayReason ?? this.stayReason,
      primaryAddress: primaryAddress ?? this.primaryAddress,
      primaryAddressStayPeriod:
          primaryAddressStayPeriod ?? this.primaryAddressStayPeriod,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
      motherTongue: motherTongue ?? this.motherTongue,
      facebookLink: facebookLink ?? this.facebookLink,
      parentsName: parentsName ?? this.parentsName,
      parentsJob: parentsJob ?? this.parentsJob,
      fatherName: fatherName ?? this.fatherName,
      fatherIsDeceased: fatherIsDeceased ?? this.fatherIsDeceased,
      fatherJob: fatherJob ?? this.fatherJob,
      motherName: motherName ?? this.motherName,
      motherIsDeceased: motherIsDeceased ?? this.motherIsDeceased,
      motherJob: motherJob ?? this.motherJob,
      siblings: siblings ?? this.siblings,
      email: email,
      phone: phone,
      imageUrl: imageUrl ?? this.imageUrl,
      semanticLabel: semanticLabel,
      isPaid: isPaid,
      isVerified: isVerified,
      referralCode: referralCode,
      referralCount: referralCount,
      referralCredits: referralCredits,
      partnerAgeRange: partnerAgeRange ?? this.partnerAgeRange,
      partnerAgeMin: partnerAgeMin ?? this.partnerAgeMin,
      partnerAgeMax: partnerAgeMax ?? this.partnerAgeMax,
      partnerHeightRange: partnerHeightRange ?? this.partnerHeightRange,
      partnerHeightCm: partnerHeightCm ?? this.partnerHeightCm,
      partnerHeightFeet: partnerHeightFeet ?? this.partnerHeightFeet,
      partnerHeightInches: partnerHeightInches ?? this.partnerHeightInches,
      partnerReligion: partnerReligion ?? this.partnerReligion,
      partnerReligionMode: partnerReligionMode ?? this.partnerReligionMode,
      partnerCaste: partnerCaste ?? this.partnerCaste,
      partnerGender: partnerGender ?? this.partnerGender,
      partnerMaritalStatus: partnerMaritalStatus ?? this.partnerMaritalStatus,
      partnerPlace: partnerPlace ?? this.partnerPlace,
      partnerLocationMode: partnerLocationMode ?? this.partnerLocationMode,
      partnerState: partnerState ?? this.partnerState,
      partnerDistrict: partnerDistrict ?? this.partnerDistrict,
      partnerCountry: partnerCountry ?? this.partnerCountry,
      partnerLanguage: partnerLanguage ?? this.partnerLanguage,
      partnerLanguages: partnerLanguages ?? this.partnerLanguages,
    );
  }
}

class MyProfileScreen extends StatefulWidget {
  static Future<bool> Function()? _savePendingEdits;

  const MyProfileScreen({super.key});

  static Future<bool> savePendingEdits() async =>
      await _savePendingEdits?.call() ?? true;

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
  String? _selectedProfileImageUrl;
  final AppLocalizations _localizations = AppLocalizations();

  // Edit buffers — updated live by child widgets
  Map<String, String> _personalEdits = {};
  Map<String, String> _familyEdits = {};
  Map<String, String> _preferencesEdits = {};
  bool _profileVisible = true;
  String _photoVisibility = 'public';
  String _profileManagedBy = 'self';
  String? _photoVerificationStatus;
  String _addressVerificationStatus = 'not_submitted';
  final TextEditingController _horoscopeStarController =
      TextEditingController();
  final TextEditingController _horoscopeRasiController =
      TextEditingController();
  final TextEditingController _horoscopeBirthTimeController =
      TextEditingController();

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
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
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
        'body':
            'Please delete my profile and account data using this link:\n$link',
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
    'fatherName': 'Ramesh Sharma',
    'fatherJob': 'Retired IAS Officer',
    'motherName': 'Lakshmi Sharma',
    'motherJob': 'School Principal',
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
    MyProfileScreen._savePendingEdits = _savePendingChanges;
    _profile = MyProfileData.fromMap(_fallbackProfileMap);
    _loadProfile();
    _localizations.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _localizations.removeListener(_onLanguageChanged);
    MyProfileScreen._savePendingEdits = null;
    _horoscopeStarController.dispose();
    _horoscopeRasiController.dispose();
    _horoscopeBirthTimeController.dispose();
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  /// Shows a lightweight banner pinned to the TOP of the screen that
  /// dismisses itself after 1 second (used for the "Profile saved" message).
  void _showTopBanner(String message) {
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1520),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC8556A), width: 1),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 12),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Color(0xFFEEE0F0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(entry);
    Future.delayed(const Duration(seconds: 1), () {
      entry.remove();
    });
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService.instance.fetchProfile();
      if (data != null && mounted) {
        setState(() {
          _profile = MyProfileData.fromMap(data);
          _isPaid = _profile.isPaid;
          _profileVisible = data['profile_visible'] != false;
          _photoVisibility = (data['photo_visibility'] ?? 'public').toString();
          _profileManagedBy = (data['profile_managed_by'] ?? 'self').toString();
          _addressVerificationStatus =
              (data['address_verification_status'] ?? 'not_submitted')
                  .toString();
          _horoscopeStarController.text = (data['horoscope_star'] ?? '')
              .toString();
          _horoscopeRasiController.text = (data['horoscope_rasi'] ?? '')
              .toString();
          _horoscopeBirthTimeController.text =
              (data['horoscope_birth_time'] ?? '').toString();
        });
      }
      _photoVerificationStatus = await SupabaseService.instance
          .fetchPhotoVerificationStatus();
      _addressVerificationStatus = await SupabaseService.instance
          .fetchAddressVerificationStatus();
    } catch (_) {
      // Keep fallback profile
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveTrustSettings() async {
    final saved = await SupabaseService.instance.updateProfileFields({
      'profile_visible': _profileVisible,
      'horoscope_star': _horoscopeStarController.text.trim(),
      'horoscope_rasi': _horoscopeRasiController.text.trim(),
      'horoscope_birth_time': _horoscopeBirthTimeController.text.trim(),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved ? 'Profile settings saved' : 'Unable to save profile settings',
        ),
      ),
    );
  }

  Future<void> _requestPhotoReview() async {
    final submitted = await SupabaseService.instance.requestPhotoVerification(
      _profile.imageUrl,
    );
    if (!mounted) return;
    if (submitted) {
      setState(() => _photoVerificationStatus = 'pending');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          submitted
              ? 'Photo submitted for review'
              : 'Add a profile photo before requesting review',
        ),
      ),
    );
  }

  Future<void> _showAadharVerificationDialog() async {
    final picker = ImagePicker();
    final nameController = TextEditingController(
      text: '${_profile.firstName} ${_profile.lastName}'.trim(),
    );
    XFile? aadharImage;
    var isSubmitting = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1520),
          title: const Text(
            'Verify name with Aadhar',
            style: TextStyle(color: Color(0xFFEEE0F0)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload a photo of your Aadhar card and confirm the name exactly as printed on it. '
                  'Our team reviews this manually — once approved, your first and last name are locked '
                  'and your Aadhar name is shown in brackets on your profile.',
                  style: TextStyle(color: Color(0xFFCCBDD0), height: 1.5),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  enabled: !isSubmitting,
                  style: const TextStyle(color: Color(0xFFEEE0F0)),
                  decoration: const InputDecoration(
                    labelText: 'Name as per Aadhar',
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final image = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                            maxWidth: 1600,
                          );
                          if (image != null) {
                            setDialogState(() => aadharImage = image);
                          }
                        },
                  icon: Icon(
                    aadharImage == null
                        ? Icons.add_a_photo_outlined
                        : Icons.check_circle_outline,
                  ),
                  label: Text(
                    aadharImage == null
                        ? 'Add Aadhar card photo'
                        : 'Aadhar photo added',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty || aadharImage == null) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Add the Aadhar name and photo to continue.',
                            ),
                          ),
                        );
                        return;
                      }
                      setDialogState(() => isSubmitting = true);
                      final submitted = await SupabaseService.instance
                          .submitAadharVerification(
                            image: aadharImage!,
                            aadharName: name,
                          );
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      if (submitted && mounted) {
                        await _loadProfile();
                      }
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            submitted
                                ? 'Aadhar details submitted for review.'
                                : 'Unable to submit Aadhar verification. Try again.',
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8556A),
                foregroundColor: Colors.white,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Submit for review'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
  }

  Future<void> _showAddressVerificationDialog() async {
    final picker = ImagePicker();
    var documentType = 'aadhaar';
    XFile? frontImage;
    XFile? backImage;
    var isSubmitting = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1520),
          title: const Text(
            'Address verification',
            style: TextStyle(color: Color(0xFFEEE0F0)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your document is used only for mandatory KYC verification. It is stored privately and is never shown to other users.',
                  style: TextStyle(color: Color(0xFFCCBDD0), height: 1.5),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: documentType,
                  dropdownColor: const Color(0xFF2A1E2E),
                  decoration: const InputDecoration(labelText: 'Document'),
                  items: const [
                    DropdownMenuItem(value: 'aadhaar', child: Text('Aadhaar')),
                    DropdownMenuItem(
                      value: 'driving_license',
                      child: Text("Driving licence"),
                    ),
                  ],
                  onChanged: isSubmitting
                      ? null
                      : (value) => setDialogState(
                          () => documentType = value ?? 'aadhaar',
                        ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final image = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                            maxWidth: 1600,
                          );
                          if (image != null) {
                            setDialogState(() => frontImage = image);
                          }
                        },
                  icon: Icon(
                    frontImage == null
                        ? Icons.add_a_photo_outlined
                        : Icons.check_circle_outline,
                  ),
                  label: Text(
                    frontImage == null ? 'Add front view' : 'Front view added',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final image = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                            maxWidth: 1600,
                          );
                          if (image != null) {
                            setDialogState(() => backImage = image);
                          }
                        },
                  icon: Icon(
                    backImage == null
                        ? Icons.add_a_photo_outlined
                        : Icons.check_circle_outline,
                  ),
                  label: Text(
                    backImage == null ? 'Add back view' : 'Back view added',
                  ),
                ),
                if (_addressVerificationStatus == 'approved')
                  const Text(
                    'Address verified',
                    style: TextStyle(color: Color(0xFF4ADE80)),
                  )
                else if (_addressVerificationStatus == 'pending')
                  const Text(
                    'Verification pending',
                    style: TextStyle(color: Color(0xFFE8A87C)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isSubmitting || frontImage == null || backImage == null
                  ? null
                  : () async {
                      setDialogState(() => isSubmitting = true);
                      final submitted = await SupabaseService.instance
                          .submitAddressVerification(
                            documentType: documentType,
                            frontImage: frontImage!,
                            backImage: backImage!,
                          );
                      if (!dialogContext.mounted) return;
                      if (submitted) {
                        Navigator.pop(dialogContext);
                        if (mounted) {
                          setState(
                            () => _addressVerificationStatus = 'pending',
                          );
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Address document submitted for KYC review',
                              ),
                            ),
                          );
                        }
                      } else {
                        setDialogState(() => isSubmitting = false);
                      }
                    },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  int _computeCompleteness(MyProfileData p) {
    int filled = 0;
    const total = 10;
    if (p.firstName.isNotEmpty) filled++;
    if (p.job.isNotEmpty) filled++;
    if (p.place.isNotEmpty) filled++;
    if (p.education.isNotEmpty) filled++;
    if (p.religion.isNotEmpty) filled++;
    if (p.parentsName.isNotEmpty ||
        p.fatherName.isNotEmpty ||
        p.motherName.isNotEmpty) {
      filled++;
    }
    if (p.facebookLink.isNotEmpty) filled++;
    if (p.partnerAgeRange.isNotEmpty) filled++;
    if (p.imageUrl.isNotEmpty) filled++;
    if (p.isPaid) filled++;
    return ((filled / total) * 100).round();
  }

  List<ProfileField> _familyProfileFields(MyProfileData profile) {
    final fields = <ProfileField>[];
    final hasStructuredParentDetails =
        profile.fatherName.isNotEmpty ||
        profile.motherName.isNotEmpty ||
        profile.fatherJob.isNotEmpty ||
        profile.motherJob.isNotEmpty ||
        profile.fatherIsDeceased ||
        profile.motherIsDeceased;

    if (hasStructuredParentDetails) {
      if (profile.fatherName.isNotEmpty ||
          profile.fatherJob.isNotEmpty ||
          profile.fatherIsDeceased) {
        final details = <String>[
          if (profile.fatherName.isNotEmpty) profile.fatherName,
          if (profile.fatherIsDeceased) 'Passed away',
          if (profile.fatherJob.isNotEmpty)
            '${profile.fatherIsDeceased ? 'Former occupation' : 'Occupation'}: ${profile.fatherJob}',
        ];
        fields.add(ProfileField("Father's Details", details.join(' · ')));
      }
      if (profile.motherName.isNotEmpty ||
          profile.motherJob.isNotEmpty ||
          profile.motherIsDeceased) {
        final details = <String>[
          if (profile.motherName.isNotEmpty) profile.motherName,
          if (profile.motherIsDeceased) 'Passed away',
          if (profile.motherJob.isNotEmpty)
            '${profile.motherIsDeceased ? 'Former occupation' : 'Occupation'}: ${profile.motherJob}',
        ];
        fields.add(ProfileField("Mother's Details", details.join(' · ')));
      }
    } else if (profile.parentsName.isNotEmpty ||
        profile.parentsJob.isNotEmpty) {
      fields.add(ProfileField("Parents' Name", profile.parentsName));
      if (profile.parentsJob.isNotEmpty) {
        fields.add(ProfileField("Parents' Occupation", profile.parentsJob));
      }
    }

    for (var index = 0; index < profile.siblings.length; index++) {
      final sibling = profile.siblings[index];
      final details = <String>[
        if ((sibling['name'] ?? '').toString().isNotEmpty)
          sibling['name'].toString(),
        sibling['isMarried'] == true ? 'Married' : 'Not married',
        if ((sibling['job'] ?? '').toString().isNotEmpty)
          'Occupation: ${sibling['job']}',
        sibling['hasChildren'] == true ? 'Has children' : 'No children',
      ];
      final relation = (sibling['relationship'] ?? 'Sibling').toString();
      fields.add(ProfileField('$relation ${index + 1}', details.join(' · ')));
    }
    if (fields.isEmpty) {
      fields.add(const ProfileField('Siblings', 'None added'));
    }
    return fields;
  }

  List<ProfileField> _locationProfileFields(MyProfileData profile) {
    final parsedPlace = parseIndianPlace(profile.place);
    final city = profile.city.isNotEmpty ? profile.city : parsedPlace.city;
    final state = profile.stateName.isNotEmpty
        ? profile.stateName
        : parsedPlace.state;
    return [
      if (city.isNotEmpty) ProfileField('City', city),
      if (state.isNotEmpty) ProfileField('State / UT', state),
      if (profile.currentCity.isNotEmpty)
        ProfileField(
          'Current City',
          profile.currentCitySameAsPrimaryAddress
              ? '${profile.currentCity} (same as primary address)'
              : profile.currentCity,
        ),
      if (profile.stayDuration.isNotEmpty)
        ProfileField('Duration of Stay', profile.stayDuration),
      if (profile.stayReason.isNotEmpty)
        ProfileField('Reason for Stay', profile.stayReason),
      if (profile.primaryAddressStayPeriod.isNotEmpty)
        ProfileField(
          'Primary Address Stay Period',
          profile.primaryAddressStayPeriod,
        ),
    ];
  }

  /// Build a live preview profile from current edit buffers
  MyProfileData get _liveProfile {
    if (!_isEditMode) {
      return _profile.copyWithEdits(imageUrl: _selectedProfileImageUrl);
    }
    return _profile.copyWithEdits(
      firstName: _personalEdits['firstName'],
      lastName: _personalEdits['lastName'],
      otherName: _personalEdits['otherName'],
      gender: _personalEdits['gender'],
      maritalStatus: _personalEdits['maritalStatus'],
      profileManagedBy: _profileManagedBy,
      dob: _personalEdits['dob'],
      birthCity: _personalEdits['birthCity'],
      birthDistrict: _personalEdits['birthDistrict'],
      birthState: _personalEdits['birthState'],
      birthTime: _personalEdits['birthTime'],
      motherTongue: _personalEdits['motherTongue'],
      religion: _personalEdits['religion'],
      caste: _personalEdits['caste'],
      job: _personalEdits['job'],
      education: _personalEdits['education'],
      schoolName: _personalEdits['schoolName'],
      collegeName: _personalEdits['collegeName'],
      universityName: _personalEdits['universityName'],
      place: _personalEdits['place'],
      stateName: _personalEdits['stateName'],
      city: _personalEdits['city'],
      currentCity: _personalEdits['currentCity'],
      currentCitySameAsPrimaryAddress:
          _personalEdits['currentCitySameAsPrimaryAddress'] == null
          ? null
          : _personalEdits['currentCitySameAsPrimaryAddress'] == 'true',
      stayDuration: _personalEdits['stayDuration'],
      stayReason: _personalEdits['stayReason'],
      primaryAddressStayPeriod: _personalEdits['primaryAddressStayPeriod'],
      heightCm: _personalEdits['heightCm'],
      weightKg: _personalEdits['weightKg'],
      facebookLink: _personalEdits['facebookLink'],
      fatherName: _familyEdits['fatherName'],
      fatherIsDeceased: _familyEdits['fatherIsDeceased'] == null
          ? null
          : _familyEdits['fatherIsDeceased'] == 'true',
      fatherJob: _familyEdits['fatherJob'],
      motherName: _familyEdits['motherName'],
      motherIsDeceased: _familyEdits['motherIsDeceased'] == null
          ? null
          : _familyEdits['motherIsDeceased'] == 'true',
      motherJob: _familyEdits['motherJob'],
      siblings: _familyEdits['siblings'] == null
          ? null
          : ((jsonDecode(_familyEdits['siblings']!) as List)
                .whereType<Map>()
                .map((sibling) => Map<String, dynamic>.from(sibling))
                .toList()),
      partnerAgeRange: _preferencesEdits['partnerAgeRange'],
      partnerAgeMin: _preferencesEdits['partnerAgeMin'],
      partnerAgeMax: _preferencesEdits['partnerAgeMax'],
      partnerHeightRange: _preferencesEdits['partnerHeightRange'],
      partnerHeightCm: _preferencesEdits['partnerHeightCm'],
      partnerHeightFeet: _preferencesEdits['partnerHeightFeet'],
      partnerHeightInches: _preferencesEdits['partnerHeightInches'],
      partnerReligion: _preferencesEdits['partnerReligion'],
      partnerReligionMode: _preferencesEdits['partnerReligionMode'],
      partnerCaste: _preferencesEdits['partnerCaste'],
      partnerGender: _preferencesEdits['partnerGender'],
      partnerMaritalStatus: _preferencesEdits['partnerMaritalStatus'],
      partnerPlace: _preferencesEdits['partnerPlace'],
      partnerLocationMode: _preferencesEdits['partnerLocationMode'],
      partnerState: _preferencesEdits['partnerState'],
      partnerDistrict: _preferencesEdits['partnerDistrict'],
      partnerCountry: _preferencesEdits['partnerCountry'],
      partnerLanguage: _preferencesEdits['partnerLanguage'],
      partnerLanguages: _preferencesEdits['partnerLanguages'],
      imageUrl: _selectedProfileImageUrl,
    );
  }

  void _scheduleProfileAutosave() {}

  void _enterEditMode() {
    setState(() {
      _isEditMode = true;
      _personalEdits = {
        'firstName': _profile.firstName,
        'lastName': _profile.lastName,
        'otherName': _profile.otherName,
        'gender': _profile.gender,
        'maritalStatus': _profile.maritalStatus,
        'dob': _profile.dob,
          'birthCity': _profile.birthCity,
          'birthDistrict': _profile.birthDistrict,
          'birthState': _profile.birthState,
          'birthTime': _profile.birthTime,
        'motherTongue': _profile.motherTongue,
        'religion': _profile.religion,
        'caste': _profile.caste,
        'job': _profile.job,
        'education': _profile.education,
        'schoolName': _profile.schoolName,
        'collegeName': _profile.collegeName,
        'universityName': _profile.universityName,
        'place': _profile.place,
        'stateName': _profile.stateName,
        'city': _profile.city,
        'currentCity': _profile.currentCity,
        'currentCitySameAsPrimaryAddress': _profile
            .currentCitySameAsPrimaryAddress
            .toString(),
        'stayDuration': _profile.stayDuration,
        'stayReason': _profile.stayReason,
        'primaryAddressStayPeriod': _profile.primaryAddressStayPeriod,
        'heightCm': _profile.heightCm,
        'weightKg': _profile.weightKg,
        'facebookLink': _profile.facebookLink,
      };
      _familyEdits = {
        'fatherName': _profile.fatherName,
        'fatherIsDeceased': _profile.fatherIsDeceased.toString(),
        'fatherJob': _profile.fatherJob,
        'motherName': _profile.motherName,
        'motherIsDeceased': _profile.motherIsDeceased.toString(),
        'motherJob': _profile.motherJob,
        'siblings': jsonEncode(_profile.siblings),
      };
      _preferencesEdits = {
        'partnerAgeRange': _profile.partnerAgeRange,
        'partnerHeightRange': _profile.partnerHeightRange,
        'partnerReligion': _profile.partnerReligion,
        'partnerGender': _profile.partnerGender,
        'partnerMaritalStatus': _profile.partnerMaritalStatus,
        'partnerPlace': _profile.partnerPlace,
        'partnerLocationMode': _profile.partnerLocationMode,
        'partnerState': _profile.partnerState,
        'partnerDistrict': _profile.partnerDistrict,
        'partnerCountry': _profile.partnerCountry,
        'partnerLanguage': _profile.partnerLanguage,
        'partnerLanguages': _profile.partnerLanguages,
        'partnerReligionMode': _profile.partnerReligionMode,
        'partnerCaste': _profile.partnerCaste,
        'partnerAgeMin': _profile.partnerAgeMin,
        'partnerAgeMax': _profile.partnerAgeMax,
        'partnerHeightCm': _profile.partnerHeightCm,
        'partnerHeightFeet': _profile.partnerHeightFeet,
        'partnerHeightInches': _profile.partnerHeightInches,
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
    final updated = _liveProfile;
    if (updated.firstName.trim().isEmpty || updated.lastName.trim().isEmpty) {
      _showTopBanner('First name and last name are required.');
      return;
    }
    setState(() => _isSaving = true);
    try {
      final success = await SupabaseService.instance.upsertProfile(
        updated.toSupabaseMap(),
      );
      if (!mounted) return;
      if (success) {
        _horoscopeBirthTimeController.text = updated.birthTime;
        setState(() {
          _profile = updated;
          _isEditMode = false;
          _personalEdits = {};
          _familyEdits = {};
          _preferencesEdits = {};
          _isSaving = false;
        });
        _showTopBanner(_localizations.get('profile_saved'));
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

  Future<bool> _savePendingChanges() async {
    if (!_isEditMode) return true;
    await _saveProfile();
    return !_isEditMode;
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

  Future<void> _openProfileSettingsSheet() async {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    var revealPasswordWithConsent = false;
    var isUpdatingPassword = false;
    var pushNotifications = true;
    try {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF1E1520),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
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
                    const Text(
                      'Account access',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEEE0F0),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      readOnly: true,
                      initialValue:
                          SupabaseService.instance.currentUserEmail ?? '',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFFEEE0F0),
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your existing password cannot be viewed. Set a new password below; it is sent securely to your account provider and is not saved in your profile.',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        height: 1.4,
                        color: Color(0xFF9A8A9E),
                      ),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: revealPasswordWithConsent,
                      activeColor: const Color(0xFFC8556A),
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text(
                        'I consent to show the new password while I type',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: Color(0xFFEEE0F0),
                        ),
                      ),
                      onChanged: (value) => setSheetState(
                        () => revealPasswordWithConsent = value ?? false,
                      ),
                    ),
                    TextField(
                      controller: newPasswordController,
                      obscureText: !revealPasswordWithConsent,
                      autocorrect: false,
                      enableSuggestions: false,
                      style: const TextStyle(color: Color(0xFFEEE0F0)),
                      decoration: const InputDecoration(
                        labelText: 'New password',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: !revealPasswordWithConsent,
                      autocorrect: false,
                      enableSuggestions: false,
                      style: const TextStyle(color: Color(0xFFEEE0F0)),
                      decoration: const InputDecoration(
                        labelText: 'Confirm new password',
                        prefixIcon: Icon(Icons.lock_reset_rounded),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: isUpdatingPassword
                            ? null
                            : () async {
                                final password = newPasswordController.text;
                                if (password.length < 8) {
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Use at least 8 characters for your new password.'),
                                    ),
                                  );
                                  return;
                                }
                                if (password != confirmPasswordController.text) {
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    const SnackBar(
                                      content: Text('The password entries do not match.'),
                                    ),
                                  );
                                  return;
                                }
                                setSheetState(() => isUpdatingPassword = true);
                                final error = await SupabaseService.instance
                                    .updateAccountPassword(password);
                                if (!sheetContext.mounted) return;
                                setSheetState(() => isUpdatingPassword = false);
                                if (error == null) {
                                  newPasswordController.clear();
                                  confirmPasswordController.clear();
                                  setSheetState(
                                    () => revealPasswordWithConsent = false,
                                  );
                                }
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      error == null
                                          ? 'Password updated successfully.'
                                          : 'Unable to update password: $error',
                                    ),
                                  ),
                                );
                              },
                        icon: isUpdatingPassword
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.password_rounded),
                        label: Text(
                          isUpdatingPassword
                              ? 'Updating password'
                              : 'Update password',
                        ),
                      ),
                    ),
                    const Divider(color: Color(0x1AFFFFFF), height: 28),
                    SwitchListTile.adaptive(
                      value: _profileVisible,
                      onChanged: (value) =>
                          setSheetState(() => _profileVisible = value),
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
                    TextField(
                      controller: _horoscopeStarController,
                      style: const TextStyle(color: Color(0xFFEEE0F0)),
                      decoration: const InputDecoration(
                        labelText: 'Nakshatra / Star',
                      ),
                    ),
                    TextField(
                      controller: _horoscopeRasiController,
                      style: const TextStyle(color: Color(0xFFEEE0F0)),
                      decoration: const InputDecoration(
                        labelText: 'Rasi',
                      ),
                    ),
                    TextField(
                      controller: _horoscopeBirthTimeController,
                      style: const TextStyle(color: Color(0xFFEEE0F0)),
                      decoration: const InputDecoration(
                        labelText: 'Birth time',
                      ),
                    ),
                    SwitchListTile.adaptive(
                      value: pushNotifications,
                      onChanged: (value) => setSheetState(
                        () => pushNotifications = value,
                      ),
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
                    const Divider(color: Color(0x1AFFFFFF), height: 28),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.security_rounded,
                        color: Color(0xFFC8556A),
                      ),
                      title: const Text(
                        'Security Settings',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEEE0F0),
                        ),
                      ),
                      subtitle: const Text(
                        'Set a passcode or fingerprint login',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF9A8A9E),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF6B5870),
                      ),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        showSecuritySettingsSheet(this.context);
                      },
                    ),
                    const Divider(color: Color(0x1AFFFFFF)),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.gpp_maybe_outlined,
                        color: Color(0xFFE57373),
                      ),
                      title: const Text(
                        'High Security',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE57373),
                        ),
                      ),
                      subtitle: const Text(
                        'Account deletion & data removal (passcode/fingerprint protected)',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF9A8A9E),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF6B5870),
                      ),
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        final unlocked = await requestHighSecurityUnlock(
                          this.context,
                        );
                        if (!unlocked || !this.context.mounted) return;
                        _showHighSecuritySheet();
                      },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _saveTrustSettings();
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC8556A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
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
              ),
            );
          },
        ),
      );
    } finally {
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    }
  }

  /// Gated content shown only after [requestHighSecurityUnlock] succeeds.
  void _showHighSecuritySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1520),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.gpp_maybe_outlined, color: Color(0xFFC8556A)),
                  SizedBox(width: 10),
                  Text(
                    'High Security',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEEE0F0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDataDeletionCard(_profile),
              const SizedBox(height: 12),
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
            ],
          ),
        ),
      ),
    );
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
            onSettingsTap: _openProfileSettingsSheet,
          ),
        ),
        SliverToBoxAdapter(
          child: ProfileCompletenessWidget(percent: completeness),
        ),
        SliverToBoxAdapter(child: ProfileCompletionTipsWidget(profile: live)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _isEditMode
                    ? EditPersonalSectionWidget(
                        initialValues: _personalEdits,
                        namesLocked: _profile.aadharVerified,
                        onChanged: (vals) {
                          setState(() => _personalEdits = vals);
                          _scheduleProfileAutosave();
                        },
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
                          ProfileField('Marital Status', live.maritalStatus),
                          ProfileField(_localizations.get('dob'), live.dob),
                          if (live.birthTime.isNotEmpty)
                            ProfileField('Time of Birth', live.birthTime),
                          if (live.birthCity.isNotEmpty)
                            ProfileField('City of Birth', live.birthCity),
                          if (live.birthDistrict.isNotEmpty)
                            ProfileField(
                              'District of Birth',
                              live.birthDistrict,
                            ),
                          if (live.birthState.isNotEmpty)
                            ProfileField('State of Birth', live.birthState),
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
                          if (live.schoolName.isNotEmpty)
                            ProfileField('School', live.schoolName),
                          if (live.collegeName.isNotEmpty)
                            ProfileField('College', live.collegeName),
                          if (live.universityName.isNotEmpty)
                            ProfileField('University', live.universityName),
                          ..._locationProfileFields(live),
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
                        onChanged: (vals) {
                          setState(() => _familyEdits = vals);
                          _scheduleProfileAutosave();
                        },
                      )
                    : ProfileInfoSectionWidget(
                        title: _localizations.get('family_info'),
                        icon: Icons.family_restroom_rounded,
                        fields: _familyProfileFields(live),
                      ),
                const SizedBox(height: 14),
                _isEditMode
                    ? EditPreferencesSectionWidget(
                        initialValues: _preferencesEdits,
                        onChanged: (vals) {
                          setState(() => _preferencesEdits = vals);
                          _scheduleProfileAutosave();
                        },
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
                            live.partnerReligionMode == 'any_religion'
                                ? 'No preference'
                                : live.partnerReligion,
                          ),
                          if (live.partnerReligionMode == 'religion_caste' &&
                              live.partnerCaste.isNotEmpty)
                            ProfileField('Partner Caste', live.partnerCaste),
                          ProfileField(
                            'Looking for gender',
                            live.partnerGender,
                          ),
                          ProfileField(
                            'Looking for marital status',
                            live.partnerMaritalStatus,
                          ),
                          ProfileField(
                            _localizations.get('partner_location'),
                            live.partnerPlace,
                          ),
                          ProfileField('Mother tongue', live.partnerLanguage),
                          if (live.partnerLanguages.isNotEmpty)
                            ProfileField(
                              'Other languages',
                              live.partnerLanguages,
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
                LanguageSettingsWidget(onSettingsTap: _openProfileSettingsSheet),
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
      {
        'label': _addressVerificationStatus == 'approved'
            ? 'Address verified'
            : _addressVerificationStatus == 'pending'
            ? 'Address verification pending'
            : 'Address not verified',
        'isDone': _addressVerificationStatus == 'approved',
      },
      {
        'label': 'Photo review: ${_photoVerificationStatus ?? 'not requested'}',
        'isDone': _photoVerificationStatus == 'approved',
      },
      {
        'label': live.aadharVerified
            ? 'Aadhar name verified'
            : 'Aadhar name verification: ${live.aadharVerificationStatus}',
        'isDone': live.aadharVerified,
      },
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
                      live.isVerified
                          ? 'Verified profile'
                          : 'Verification in progress',
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
                    isDone
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 14,
                    color: isDone
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFF6B5870),
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
          if (live.imageUrl.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    live.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Profile photo submitted for verification review',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      color: Color(0xFFCCBDD0),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed:
                _photoVerificationStatus == 'pending' ||
                    _photoVerificationStatus == 'approved'
                ? null
                : _requestPhotoReview,
            icon: const Icon(Icons.fact_check_outlined, size: 16),
            label: Text(
              _photoVerificationStatus == 'pending'
                  ? 'Photo review pending'
                  : _photoVerificationStatus == 'approved'
                  ? 'Photo reviewed'
                  : 'Request photo review',
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed:
                !_isPaid ||
                    _addressVerificationStatus == 'pending' ||
                    _addressVerificationStatus == 'approved'
                ? null
                : _showAddressVerificationDialog,
            icon: const Icon(Icons.home_work_outlined, size: 16),
            label: Text(
              !_isPaid
                  ? 'Available after premium purchase'
                  : _addressVerificationStatus == 'approved'
                  ? 'Address verified'
                  : _addressVerificationStatus == 'pending'
                  ? 'Address verification pending'
                  : 'Verify address',
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed:
                live.aadharVerified ||
                    live.aadharVerificationStatus == 'pending'
                ? null
                : _showAadharVerificationDialog,
            icon: const Icon(Icons.badge_outlined, size: 16),
            label: Text(
              live.aadharVerified
                  ? 'Aadhar name verified'
                  : live.aadharVerificationStatus == 'pending'
                  ? 'Aadhar review pending'
                  : 'Verify name with Aadhar',
            ),
          ),
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
              Icon(
                Icons.delete_forever_outlined,
                color: Color(0xFFE57373),
                size: 20,
              ),
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
                    onSettingsTap: _openProfileSettingsSheet,
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
                          namesLocked: _profile.aadharVerified,
                          onChanged: (vals) {
                            setState(() => _personalEdits = vals);
                            _scheduleProfileAutosave();
                          },
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
                            ProfileField('Marital Status', live.maritalStatus),
                            ProfileField('Date of Birth', live.dob),
                            if (live.birthTime.isNotEmpty)
                              ProfileField('Time of Birth', live.birthTime),
                            if (live.birthCity.isNotEmpty)
                              ProfileField('City of Birth', live.birthCity),
                            if (live.birthDistrict.isNotEmpty)
                              ProfileField(
                                'District of Birth',
                                live.birthDistrict,
                              ),
                            if (live.birthState.isNotEmpty)
                              ProfileField('State of Birth', live.birthState),
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
                        if (live.schoolName.isNotEmpty)
                          ProfileField('School', live.schoolName),
                        if (live.collegeName.isNotEmpty)
                          ProfileField('College', live.collegeName),
                        if (live.universityName.isNotEmpty)
                          ProfileField('University', live.universityName),
                        ..._locationProfileFields(live),
                        ProfileField('Height', live.heightCm),
                        ProfileField('Weight', live.weightKg),
                      ],
                    ),
                  if (!_isEditMode) const SizedBox(height: 14),
                  _isEditMode
                      ? EditFamilySectionWidget(
                          initialValues: _familyEdits,
                          onChanged: (vals) {
                            setState(() => _familyEdits = vals);
                            _scheduleProfileAutosave();
                          },
                        )
                      : ProfileInfoSectionWidget(
                          title: 'Family Details',
                          icon: Icons.family_restroom_rounded,
                          fields: _familyProfileFields(live),
                        ),
                  const SizedBox(height: 14),
                  _isEditMode
                      ? EditPreferencesSectionWidget(
                          initialValues: _preferencesEdits,
                          onChanged: (vals) {
                            setState(() => _preferencesEdits = vals);
                            _scheduleProfileAutosave();
                          },
                        )
                      : ProfileInfoSectionWidget(
                          title: 'Partner Preferences',
                          icon: Icons.favorite_border_rounded,
                          fields: [
                            ProfileField('Age Range', live.partnerAgeRange),
                            ProfileField('Height', live.partnerHeightRange),
                            ProfileField(
                              'Religion',
                              live.partnerReligionMode == 'any_religion'
                                  ? 'No preference'
                                  : live.partnerReligion,
                            ),
                            if (live.partnerReligionMode == 'religion_caste' &&
                                live.partnerCaste.isNotEmpty)
                              ProfileField('Caste', live.partnerCaste),
                            ProfileField(
                              'Looking for gender',
                              live.partnerGender,
                            ),
                            ProfileField(
                              'Looking for marital status',
                              live.partnerMaritalStatus,
                            ),
                            ProfileField('Location', live.partnerPlace),
                            ProfileField('Mother tongue', live.partnerLanguage),
                            if (live.partnerLanguages.isNotEmpty)
                              ProfileField(
                                'Other languages',
                                live.partnerLanguages,
                              ),
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
                  if (!_isEditMode) _enterEditMode();
                  await _uploadAndSaveProfilePhoto(pickedFile);
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: Color(0xFFC8556A),
              ),
              title: const Text(
                'Take a Selfie',
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
                  preferredCameraDevice: CameraDevice.front,
                );
                if (pickedFile != null && mounted) {
                  setState(() => _selectedProfileImage = pickedFile);
                  if (!_isEditMode) _enterEditMode();
                  await _uploadAndSaveProfilePhoto(pickedFile);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadAndSaveProfilePhoto(XFile photo) async {
    try {
      final publicUrl = await SupabaseService.instance.uploadProfilePhoto(
        photo,
      );
      if (!mounted) return;
      setState(() => _selectedProfileImageUrl = publicUrl);
      _scheduleProfileAutosave();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo upload failed: ${error.toString()}'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _uploadAndSaveProfilePhoto(photo),
          ),
        ),
      );
    }
  }
}
