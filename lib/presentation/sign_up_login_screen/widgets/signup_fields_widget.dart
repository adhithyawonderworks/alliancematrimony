import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/india_location_data.dart';
import '../../../core/professional_education_data.dart';
import '../../../core/profile_relationship_data.dart';
import '../../../services/supabase_service.dart';

class SignupFieldsWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final ValueChanged<Map<String, dynamic>>? onDataChanged;
  final XFile? selectedImageFile;
  final ValueChanged<XFile?>? onImageChanged;

  const SignupFieldsWidget({
    super.key,
    required this.formKey,
    this.onDataChanged,
    this.selectedImageFile,
    this.onImageChanged,
  });

  @override
  State<SignupFieldsWidget> createState() => _SignupFieldsWidgetState();
}

class _SignupFieldsWidgetState extends State<SignupFieldsWidget> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _otherNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _jobController = TextEditingController();
  final _jobOtherController = TextEditingController();
  final _educationController = TextEditingController();
  final _educationOtherController = TextEditingController();
  final _schoolController = TextEditingController();
  final _collegeController = TextEditingController();
  final _universityController = TextEditingController();
  final _motherTongueOtherController = TextEditingController();
  final _cityOtherController = TextEditingController();
  final _currentCityController = TextEditingController();
  final _stayReasonOtherController = TextEditingController();
  final _primaryAddressStayPeriodController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _parentsContactController = TextEditingController();
  final _fbLinkController = TextEditingController();
  final _parentsNameController = TextEditingController();
  final _parentsJobController = TextEditingController();
  final _referralController = TextEditingController();
  final _horoscopeBirthTimeController = TextEditingController();
  final _birthCityController = TextEditingController();
  final _birthDistrictController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImageFile;
  String? _uploadedProfileImageUrl;
  String _selectedGender = 'Male';
  String _selectedMaritalStatus = 'Single';
  String _profileManagedBy = 'self';
  String _partnerGender = 'No preference';
  String _partnerMaritalStatus = 'No preference';
  String? _selectedState;
  String? _selectedCity;
  String? _stayDuration;
  String? _stayReasonSelection;
  String? _jobSelection;
  String? _educationSelection;
  String? _motherTongueSelection;
  String? _complexionSelection;
  String? _birthStateSelection;
  String? _horoscopeStarSelection;
  bool _currentCitySameAsPrimaryAddress = false;
  bool _truthfulnessConfirmed = true;
  bool _fbNameMatch = false;

  @override
  void initState() {
    super.initState();
    _selectedImageFile = widget.selectedImageFile;
    for (final controller in [
      _firstNameController,
      _lastNameController,
      _otherNameController,
      _phoneController,
      _dobController,
      _jobController,
      _educationController,
      _schoolController,
      _collegeController,
      _universityController,
      _currentCityController,
      _primaryAddressStayPeriodController,
      _heightController,
      _weightController,
      _pinCodeController,
      _parentsContactController,
      _fbLinkController,
      _parentsNameController,
      _parentsJobController,
      _referralController,
      _horoscopeBirthTimeController,
      _birthCityController,
      _birthDistrictController,
    ]) {
      controller.addListener(_notifyChanged);
    }
    _jobOtherController.addListener(() {
      if (_jobSelection == kProfessionalOtherOption) {
        _jobController.text = _jobOtherController.text;
      }
    });
    _educationOtherController.addListener(() {
      if (_educationSelection == kProfessionalOtherOption) {
        _educationController.text = _educationOtherController.text;
      }
    });
    _motherTongueOtherController.addListener(_notifyChanged);
    _stayReasonOtherController.addListener(() {
      if (_stayReasonSelection == kLocationOther) {
        _notifyChanged();
      }
    });
    _cityOtherController.addListener(() {
      if (_selectedCity == kLocationOther) _notifyChanged();
    });
  }

  @override
  void didUpdateWidget(covariant SignupFieldsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedImageFile != oldWidget.selectedImageFile) {
      _selectedImageFile = widget.selectedImageFile;
    }
  }

  Map<String, dynamic> _collectData() {
    return {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'other_name': _otherNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'dob': _dobController.text.trim(),
      'birth_city': _birthCityController.text.trim(),
      'birth_district': _birthDistrictController.text.trim(),
      'birth_state': _birthStateSelection ?? '',
      'horoscope_birth_time': _horoscopeBirthTimeController.text.trim(),
      'horoscope_star': _horoscopeStarSelection ?? '',
      'gender': _selectedGender,
      'marital_status': _selectedMaritalStatus,
      'profile_managed_by': _profileManagedBy,
      'partner_gender': _partnerGender,
      'partner_marital_status': _partnerMaritalStatus,
      'job': _jobController.text.trim(),
      'education': _educationController.text.trim(),
      'school_name': _schoolController.text.trim(),
      'college_name': _collegeController.text.trim(),
      'university_name': _universityController.text.trim(),
      'mother_tongue': _motherTongueSelection == 'Other'
          ? _motherTongueOtherController.text.trim()
          : (_motherTongueSelection ?? ''),
      'state_name': _selectedState ?? '',
      'city': _selectedCity == kLocationOther
          ? _cityOtherController.text.trim()
          : (_selectedCity ?? ''),
      'place': _composePlace(),
      'current_city': _currentCitySameAsPrimaryAddress
          ? _composePlace()
          : _currentCityController.text.trim(),
      'current_city_same_as_primary_address': _currentCitySameAsPrimaryAddress,
      'primary_address': _composePlace(),
      'primary_address_stay_period': _primaryAddressStayPeriodController.text
          .trim(),
      'stay_duration': _currentCitySameAsPrimaryAddress
          ? ''
          : (_stayDuration ?? ''),
      'stay_reason': _currentCitySameAsPrimaryAddress
          ? ''
          : (_stayReasonSelection == kLocationOther
                ? _stayReasonOtherController.text.trim()
                : (_stayReasonSelection ?? '')),
      'height_cm': _heightController.text.trim(),
      'weight_kg': _weightController.text.trim(),
      'pincode': _pinCodeController.text.trim(),
      'complexion': _complexionSelection ?? '',
      'facebook_link': _fbLinkController.text.trim(),
      'parents_name': _parentsNameController.text.trim(),
      'parents_job': _parentsJobController.text.trim(),
      'parents_contact': _parentsContactController.text.trim(),
      'truthfulness_confirmed': _truthfulnessConfirmed,
      'referral_code': _referralController.text.trim(),
      'image_url': _uploadedProfileImageUrl ?? '',
    };
  }

  String _composePlace() {
    final city = _selectedCity == kLocationOther
        ? _cityOtherController.text.trim()
        : (_selectedCity ?? '');
    if (city.isEmpty) return '';
    return _selectedState == null ? city : '$city, $_selectedState';
  }

  void _onStateSelected(String? value) {
    setState(() {
      _selectedState = value;
      if (_selectedCity != kLocationOther) {
        _selectedCity = null;
        _cityOtherController.clear();
      }
    });
    _notifyChanged();
  }

  void _onCitySelected(String? value) {
    setState(() => _selectedCity = value);
    _notifyChanged();
  }

  void _onStayReasonSelected(String? value) {
    setState(() {
      _stayReasonSelection = value;
    });
    _notifyChanged();
  }

  void _notifyChanged() {
    widget.onDataChanged?.call(_collectData());
  }

  void _onJobSelected(String? value) {
    setState(() {
      _jobSelection = value;
      _jobController.text = value == kProfessionalOtherOption
          ? _jobOtherController.text
          : (value ?? '');
    });
    _notifyChanged();
  }

  void _onEducationSelected(String? value) {
    setState(() {
      _educationSelection = value;
      _educationController.text = value == kProfessionalOtherOption
          ? _educationOtherController.text
          : (value ?? '');
    });
    _notifyChanged();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 92,
      maxWidth: 1200,
      preferredCameraDevice: CameraDevice.front,
    );
    if (pickedFile == null || !mounted) return;
    setState(() {
      _selectedImageFile = pickedFile;
    });
    widget.onImageChanged?.call(_selectedImageFile);
    try {
      _uploadedProfileImageUrl = await SupabaseService.instance
          .uploadProfilePhoto(pickedFile);
      if (source == ImageSource.camera) {
        await SupabaseService.instance.requestPhotoVerification(
          _uploadedProfileImageUrl!,
        );
      }
      _notifyChanged();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo upload failed. Please try again.')),
      );
    }
  }

  void _showPhotoPickerSheet() {
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
              'Add Profile Photo',
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
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
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
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _jobController.dispose();
    _jobOtherController.dispose();
    _educationController.dispose();
    _educationOtherController.dispose();
    _schoolController.dispose();
    _collegeController.dispose();
    _universityController.dispose();
    _motherTongueOtherController.dispose();
    _currentCityController.dispose();
    _cityOtherController.dispose();
    _stayReasonOtherController.dispose();
    _primaryAddressStayPeriodController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _pinCodeController.dispose();
    _parentsContactController.dispose();
    _fbLinkController.dispose();
    _parentsNameController.dispose();
    _parentsJobController.dispose();
    _referralController.dispose();
    _horoscopeBirthTimeController.dispose();
    _birthCityController.dispose();
    _birthDistrictController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _otherNameController.dispose();
    super.dispose();
  }

  void _checkFbLink(String value) {
    // TODO: Replace with [Riverpod/Bloc] FB profile cross-check service
    final name = _firstNameController.text.trim().toLowerCase();
    final fb = value.toLowerCase();
    setState(() {
      _fbNameMatch =
          name.isNotEmpty &&
          fb.isNotEmpty &&
          fb.contains(name.split(' ').first);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSection(
          title: 'Personal Details',
          icon: Icons.person_outline_rounded,
          children: [
            _buildPhotoUpload(),
            const SizedBox(height: 14),
            _buildField(
              controller: _firstNameController,
              label: 'First Name',
              hint: 'e.g. Priya',
              icon: Icons.badge_outlined,
              isRequiredLabel: true,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'First name is required'
                  : null,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _lastNameController,
              label: 'Last Name',
              hint: 'e.g. Sharma',
              icon: Icons.badge_outlined,
              isRequiredLabel: true,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Last name is required'
                  : null,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _otherNameController,
              label: 'Other Name',
              hint: 'e.g. nickname or alias (optional)',
              icon: Icons.badge_outlined,
              isOptional: true,
            ),
            const SizedBox(height: 14),
            _buildGenderSelector(),
            const SizedBox(height: 14),
            _buildMotherTongueField(),
            const SizedBox(height: 14),
            _buildDropdownField(
              label: 'Marital Status',
              value: _selectedMaritalStatus,
              options: kMaritalStatuses,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMaritalStatus = value);
                  _notifyChanged();
                }
              },
            ),
            const SizedBox(height: 14),
            _buildDropdownField(
              label: 'Profile created by',
              value: _profileManagedBy,
              options: kProfileCreators,
              labels: kProfileCreatorLabels,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _profileManagedBy = value);
                  _notifyChanged();
                }
              },
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _dobController,
              label: 'Date of Birth',
              hint: 'Select your birth date',
              icon: Icons.cake_outlined,
              readOnly: true,
              onTap: _selectDateOfBirth,
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: Color(0xFF9A8A9E),
                ),
                onPressed: _selectDateOfBirth,
              ),
              validator: _validateDateOfBirth,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _phoneController,
              label: 'Mobile Number',
              hint: '+91 98765 43210',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.length < 10) ? 'Valid mobile required' : null,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Professional & Physical',
          icon: Icons.work_outline_rounded,
          children: [
            _buildOptionField(
              otherController: _jobOtherController,
              options: kOccupationOptions,
              selectedValue: _jobSelection,
              onSelected: _onJobSelected,
              label: 'Occupation',
              hint: 'Select occupation',
              icon: Icons.business_center_outlined,
            ),
            const SizedBox(height: 14),
            _buildOptionField(
              otherController: _educationOtherController,
              options: kEducationOptions,
              selectedValue: _educationSelection,
              onSelected: _onEducationSelected,
              label: 'Education',
              hint: 'Select education',
              icon: Icons.school_outlined,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _schoolController,
              label: 'School',
              hint: 'School name',
              icon: Icons.school_outlined,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _collegeController,
              label: 'College',
              hint: 'College name',
              icon: Icons.account_balance_outlined,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _universityController,
              label: 'University',
              hint: 'University name',
              icon: Icons.account_balance_rounded,
            ),
            const SizedBox(height: 14),
            _buildDropdownField(
              label: 'State / Union Territory',
              value: _selectedState,
              options: kIndianStatesAndUnionTerritories,
              onChanged: _onStateSelected,
            ),
            const SizedBox(height: 14),
            _buildDropdownField(
              label: 'City',
              value: _selectedCity,
              options: _selectedState == null
                  ? const []
                  : citiesForState(_selectedState),
              onChanged: _onCitySelected,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _pinCodeController,
              label: 'Pincode',
              hint: '6-digit pincode',
              icon: Icons.pin_drop_outlined,
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value == null || !RegExp(r'^\d{6}$').hasMatch(value.trim())
                  ? 'Enter a valid 6-digit pincode'
                  : null,
            ),
            if (_selectedCity == kLocationOther) ...[
              const SizedBox(height: 14),
              _buildField(
                controller: _cityOtherController,
                label: 'Enter City',
                hint: 'Enter city or town',
                icon: Icons.edit_location_alt_outlined,
              ),
            ],
            const SizedBox(height: 14),
            _buildSameAddressField(),
            const SizedBox(height: 14),
            _buildField(
              controller: _primaryAddressStayPeriodController,
              label: 'Primary Address Stay Period',
              hint: 'e.g. Since birth, 10 years',
              icon: Icons.home_outlined,
            ),
            if (!_currentCitySameAsPrimaryAddress) ...[
              const SizedBox(height: 14),
              _buildField(
                controller: _currentCityController,
                label: 'Current City',
                hint: 'Where do you currently live?',
                icon: Icons.location_on_outlined,
              ),
            ],
            if (!_currentCitySameAsPrimaryAddress) ...[
              const SizedBox(height: 14),
              _buildDropdownField(
                label: 'Duration of Stay',
                value: _stayDuration,
                options: kStayDurationOptions,
                onChanged: (value) {
                  setState(() => _stayDuration = value);
                  _notifyChanged();
                },
              ),
              const SizedBox(height: 14),
              _buildDropdownField(
                label: 'Reason for Stay',
                value: _stayReasonSelection,
                options: kStayReasonOptions,
                onChanged: _onStayReasonSelected,
              ),
              if (_stayReasonSelection == kLocationOther) ...[
                const SizedBox(height: 14),
                _buildField(
                  controller: _stayReasonOtherController,
                  label: 'Other Reason',
                  hint: 'Enter reason for staying here',
                  icon: Icons.edit_note_rounded,
                ),
              ],
            ],
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _heightController,
                    label: 'Height (cm)',
                    hint: '165',
                    icon: Icons.height_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _weightController,
                    label: 'Weight (kg)',
                    hint: '58',
                    icon: Icons.monitor_weight_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildDropdownField(
              label: 'Complexion',
              value: _complexionSelection,
              options: const ['Light', 'Medium', 'Deep'],
              onChanged: (value) {
                setState(() => _complexionSelection = value);
                _notifyChanged();
              },
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _horoscopeBirthTimeController,
              label: 'Time of Birth',
              hint: 'HH:MM (24-hour time)',
              icon: Icons.schedule_outlined,
              keyboardType: TextInputType.datetime,
              validator: (value) =>
                  value == null ||
                      !RegExp(
                        r'^([01]\d|2[0-3]):[0-5]\d$',
                      ).hasMatch(value.trim())
                  ? 'Enter birth time as HH:MM'
                  : null,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _birthCityController,
              label: 'City of Birth',
              hint: 'Enter birth city or town',
              icon: Icons.location_city_outlined,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _birthDistrictController,
              label: 'District of Birth',
              hint: 'Enter birth district',
              icon: Icons.map_outlined,
            ),
            const SizedBox(height: 14),
            _buildDropdownField(
              label: 'State / Union Territory of Birth',
              value: _birthStateSelection,
              options: kIndianStatesAndUnionTerritories,
              onChanged: (value) {
                setState(() => _birthStateSelection = value);
                _notifyChanged();
              },
            ),
            const SizedBox(height: 14),
            _buildDropdownField(
              label: 'Birth Star (Nakshatra)',
              value: _horoscopeStarSelection,
              options: const [
                'Ashwini',
                'Bharani',
                'Krittika',
                'Rohini',
                'Mrigashira',
                'Ardra',
                'Punarvasu',
                'Pushya',
                'Ashlesha',
                'Magha',
                'Purva Phalguni',
                'Uttara Phalguni',
                'Hasta',
                'Chitra',
                'Swati',
                'Vishakha',
                'Anuradha',
                'Jyeshtha',
                'Mula',
                'Purva Ashadha',
                'Uttara Ashadha',
                'Shravana',
                'Dhanishta',
                'Shatabhisha',
                'Purva Bhadrapada',
                'Uttara Bhadrapada',
                'Revati',
              ],
              onChanged: (value) {
                setState(() => _horoscopeStarSelection = value);
                _notifyChanged();
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Looking For',
          icon: Icons.favorite_border_rounded,
          children: [
            _buildDropdownField(
              label: 'Gender',
              value: _partnerGender,
              options: kPartnerGenderOptions,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _partnerGender = value);
                  _notifyChanged();
                }
              },
            ),
            const SizedBox(height: 14),
            _buildDropdownField(
              label: 'Marital Status',
              value: _partnerMaritalStatus,
              options: kPartnerMaritalOptions,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _partnerMaritalStatus = value);
                  _notifyChanged();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Family Details',
          icon: Icons.family_restroom_rounded,
          children: [
            _buildField(
              controller: _parentsNameController,
              label: "Parent's Name",
              hint: "Father's / Mother's name",
              icon: Icons.people_outline_rounded,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _parentsJobController,
              label: "Parent's Occupation",
              hint: 'e.g. Retired Government Officer',
              icon: Icons.work_history_outlined,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _parentsContactController,
              label: "Parent's Contact Number",
              hint: '+91 98765 43210',
              icon: Icons.call_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value == null ||
                      value.replaceAll(RegExp(r'\D'), '').length < 10
                  ? 'Enter a valid parent contact number'
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Social Verification',
          icon: Icons.verified_user_outlined,
          children: [
            _buildField(
              controller: _fbLinkController,
              label: 'Facebook Profile Link (Optional)',
              hint: 'https://facebook.com/yourprofile',
              icon: Icons.link_rounded,
              onChanged: _checkFbLink,
              isOptional: true,
            ),
            if (_fbNameMatch) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D3D22).withAlpha(179),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF2D7A4F),
                    width: 0.5,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: Color(0xFF4ADE80),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Name matches FB profile. Last name will be masked until interest is accepted.',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: Color(0xFF4ADE80),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: _truthfulnessConfirmed,
          onChanged: (value) {
            setState(() => _truthfulnessConfirmed = value ?? false);
            _notifyChanged();
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          activeColor: const Color(0xFFC8556A),
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            'I confirm that all details I provide are true.',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              color: Color(0xFFEEE0F0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Referral',
          icon: Icons.card_giftcard_rounded,
          children: [
            _buildField(
              controller: _referralController,
              label: 'Referral Code',
              hint: 'Enter referral code if you have one',
              icon: Icons.discount_outlined,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2D1A00).withAlpha(153),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE8A87C).withAlpha(77),
                  width: 0.5,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Color(0xFFE8A87C),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Earn ₹100 bonus for every friend you refer who pays the ₹500 registration fee.',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        color: Color(0xFFE8A87C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x0AFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: const Color(0xFFC8556A)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      color: Color(0xFFEEE0F0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return GestureDetector(
      onTap: _showPhotoPickerSheet,
      child: Container(
        width: double.infinity,
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0x33FFFFFF),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: _selectedImageFile == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 28,
                    color: Color(0xFFC8556A),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Upload Profile Photo',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      color: Color(0xFF9A8A9E),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'JPG, PNG up to 5MB',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      color: Color(0xFF6B5870),
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(_selectedImageFile!.path),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF120D16).withAlpha(191),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 12,
                              color: Color(0xFFEEE0F0),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Change',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 10,
                                color: Color(0xFFEEE0F0),
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

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9A8A9E),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: kProfileGenders.map((g) {
            final isSelected = _selectedGender == g;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedGender = g);
                  _notifyChanged();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFC8556A).withAlpha(51)
                        : const Color(0x1AFFFFFF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFC8556A)
                          : const Color(0x33FFFFFF),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    g,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFFC8556A)
                          : const Color(0xFF9A8A9E),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMotherTongueField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownField(
          label: 'Mother Tongue',
          value: _motherTongueSelection,
          options: kMotherTongueOptions,
          onChanged: (value) {
            setState(() => _motherTongueSelection = value);
            _notifyChanged();
          },
        ),
        if (_motherTongueSelection == 'Other') ...[
          const SizedBox(height: 12),
          _buildField(
            controller: _motherTongueOtherController,
            label: 'Other mother tongue',
            hint: 'Enter language',
            icon: Icons.translate_rounded,
          ),
        ],
      ],
    );
  }

  Widget _buildSameAddressField() => Material(
    color: Colors.transparent,
    child: SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        'Current city same as primary address',
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 12,
          color: Color(0xFFEEE0F0),
        ),
      ),
      value: _currentCitySameAsPrimaryAddress,
      activeColor: const Color(0xFFC8556A),
      onChanged: (value) {
        setState(() => _currentCitySameAsPrimaryAddress = value);
        _notifyChanged();
      },
    ),
  );

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> options,
    List<String>? labels,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9A8A9E),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E1520),
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            color: Color(0xFFEEE0F0),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0x1AFFFFFF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x33FFFFFF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x33FFFFFF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFC8556A),
                width: 1.5,
              ),
            ),
          ),
          items: [
            for (var index = 0; index < options.length; index++)
              DropdownMenuItem(
                value: options[index],
                child: Text(labels == null ? options[index] : labels[index]),
              ),
          ],
          validator: (selected) => selected == null || selected.isEmpty
              ? '$label is required'
              : null,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildOptionField({
    required TextEditingController otherController,
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String?> onSelected,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9A8A9E),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: selectedValue,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E1520),
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            color: Color(0xFFEEE0F0),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF9A8A9E),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: Color(0xFF6B5870),
            ),
            prefixIcon: Icon(icon, size: 16, color: const Color(0xFF9A8A9E)),
            filled: true,
            fillColor: const Color(0x1AFFFFFF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x33FFFFFF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x33FFFFFF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFC8556A),
                width: 1.5,
              ),
            ),
          ),
          items: [
            for (final option in options)
              DropdownMenuItem(value: option, child: Text(option)),
          ],
          validator: (selected) => selected == null || selected.isEmpty
              ? '$label is required'
              : null,
          onChanged: onSelected,
        ),
        if (selectedValue == kProfessionalOtherOption) ...[
          const SizedBox(height: 12),
          _buildField(
            controller: otherController,
            label: 'Specify $label',
            hint: 'Enter $label',
            icon: icon,
          ),
        ],
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    bool isOptional = false,
    bool readOnly = false,
    bool isRequiredLabel = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9A8A9E),
            ),
            children: isRequiredLabel
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Color(0xFFB91C1C)),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              readOnly: readOnly,
              onTap: onTap,
              onChanged: onChanged,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: Color(0xFFEEE0F0),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  color: Color(0xFF6B5870),
                ),
                prefixIcon: Icon(
                  icon,
                  size: 16,
                  color: const Color(0xFF9A8A9E),
                ),
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: const Color(0x1AFFFFFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0x33FFFFFF),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0x33FFFFFF),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFC8556A),
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFB91C1C),
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              validator: isOptional
                  ? validator
                  : validator ??
                        (value) => value == null || value.trim().isEmpty
                            ? '$label is required'
                            : null,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final lastSelectableDate = now.subtract(const Duration(days: 365 * 16));
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: lastSelectableDate,
      helpText: 'Select date of birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFC8556A),
              onPrimary: Colors.white,
              surface: Color(0xFF120D16),
              onSurface: Color(0xFFEEE0F0),
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF120D16),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFC8556A),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    _dobController.text =
        '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
    _notifyChanged();
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  String? _validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) return 'Date of birth required';
    final dob = DateTime.tryParse(value);
    if (dob == null) return 'Date of birth required';
    final age = _calculateAge(dob);
    final minAge = _selectedGender == 'Female' ? 18 : 21;
    if (age < minAge) {
      return 'You must be at least $minAge years old to register';
    }
    return null;
  }
}
