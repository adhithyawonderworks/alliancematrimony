import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/india_location_data.dart';
import '../../../core/professional_education_data.dart';
import '../../../core/profile_relationship_data.dart';
import '../../../core/religion_caste_data.dart';

class EditPersonalSectionWidget extends StatefulWidget {
  final Map<String, String> initialValues;
  final void Function(Map<String, String> values) onChanged;
  /// When true (Aadhar name verified), first/last name become read-only.
  final bool namesLocked;

  const EditPersonalSectionWidget({
    super.key,
    required this.initialValues,
    required this.onChanged,
    this.namesLocked = false,
  });

  @override
  State<EditPersonalSectionWidget> createState() =>
      _EditPersonalSectionWidgetState();
}

class _EditPersonalSectionWidgetState extends State<EditPersonalSectionWidget> {
  late final Map<String, TextEditingController> _controllers;
  late final TextEditingController _religionOtherController;
  late final TextEditingController _motherTongueOtherController;
  late final TextEditingController _schoolController;
  late final TextEditingController _collegeController;
  late final TextEditingController _universityController;
  late final TextEditingController _primaryAddressStayPeriodController;
  late final TextEditingController _casteOtherController;
  late final TextEditingController _jobOtherController;
  late final TextEditingController _educationOtherController;
  late final TextEditingController _cityOtherController;
  late final TextEditingController _stayReasonOtherController;
  String? _religionSelection;
  String? _casteSelection;
  String? _jobSelection;
  String? _educationSelection;
  String? _genderSelection;
  String? _maritalStatusSelection;
  String? _stateSelection;
  String? _citySelection;
  String? _stayDurationSelection;
  String? _stayReasonSelection;
  String? _motherTongueSelection;
  bool _currentCitySameAsPrimaryAddress = false;

  static const _fields = [
    {'key': 'firstName', 'label': 'First Name', 'hint': 'Enter first name', 'required': 'true'},
    {'key': 'lastName', 'label': 'Last Name', 'hint': 'Enter last name', 'required': 'true'},
    {'key': 'otherName', 'label': 'Other Name (Optional)', 'hint': 'Any other name you go by'},
    {'key': 'dob', 'label': 'Date of Birth', 'hint': 'e.g. 14 March 1998'},
    {
      'key': 'birthTime',
      'label': 'Time of Birth',
      'hint': 'HH:MM (24-hour time)',
    },
    {
      'key': 'birthCity',
      'label': 'City of Birth',
      'hint': 'Birth city or town',
    },
    {
      'key': 'birthDistrict',
      'label': 'District of Birth',
      'hint': 'Birth district',
    },
    {
      'key': 'birthState',
      'label': 'State / UT of Birth',
      'hint': 'Birth state',
    },
    {'key': 'gender', 'label': 'Gender', 'hint': 'Select gender'},
    {
      'key': 'maritalStatus',
      'label': 'Marital Status',
      'hint': 'Select marital status',
    },
    {
      'key': 'motherTongue',
      'label': 'Mother Tongue',
      'hint': 'Select language',
    },
    {'key': 'religion', 'label': 'Religion', 'hint': 'e.g. Hindu'},
    {'key': 'caste', 'label': 'Caste', 'hint': 'e.g. Brahmin'},
    {'key': 'job', 'label': 'Occupation', 'hint': 'e.g. Software Engineer'},
    {'key': 'education', 'label': 'Education', 'hint': 'e.g. B.Tech, IIT'},
    {'key': 'schoolName', 'label': 'School', 'hint': 'School name'},
    {'key': 'collegeName', 'label': 'College', 'hint': 'College name'},
    {'key': 'universityName', 'label': 'University', 'hint': 'University name'},
    {
      'key': 'stateName',
      'label': 'State / Union Territory',
      'hint': 'Select state or Union Territory',
    },
    {'key': 'city', 'label': 'City', 'hint': 'Select city'},
    {
      'key': 'primaryAddressStayPeriod',
      'label': 'Primary Address Stay Period',
      'hint': 'e.g. Since birth, 10 years',
    },
    {
      'key': 'currentCitySameAsPrimaryAddress',
      'label': 'Current city same as primary address',
      'hint': '',
    },
    {
      'key': 'currentCity',
      'label': 'Current City',
      'hint': 'Where do you currently live?',
    },
    {
      'key': 'stayDuration',
      'label': 'Duration of Stay',
      'hint': 'Select duration',
    },
    {'key': 'stayReason', 'label': 'Reason for Stay', 'hint': 'Select reason'},
    {'key': 'heightCm', 'label': 'Height', 'hint': 'e.g. 163 cm'},
    {'key': 'weightKg', 'label': 'Weight', 'hint': 'e.g. 55 kg'},
    {
      'key': 'facebookLink',
      'label': 'Facebook Profile Link (Optional)',
      'hint': 'https://facebook.com/...',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final f in _fields)
        f['key']!: TextEditingController(
          text: widget.initialValues[f['key']] ?? '',
        ),
    };
    for (final entry in _controllers.entries) {
      entry.value.addListener(_notifyChange);
    }
    final initialGender = widget.initialValues['gender'];
    final initialMaritalStatus = widget.initialValues['maritalStatus'];
    _genderSelection = kProfileGenders.contains(initialGender)
        ? initialGender
        : null;
    _maritalStatusSelection = kMaritalStatuses.contains(initialMaritalStatus)
        ? initialMaritalStatus
        : null;

    final initialTongue = widget.initialValues['motherTongue'] ?? '';
    _motherTongueSelection = kMotherTongueOptions.contains(initialTongue)
        ? initialTongue
        : (initialTongue.isEmpty ? null : 'Other');
    _motherTongueOtherController = TextEditingController(
      text: _motherTongueSelection == 'Other' ? initialTongue : '',
    );
    _schoolController = TextEditingController(
      text: widget.initialValues['schoolName'] ?? '',
    );
    _collegeController = TextEditingController(
      text: widget.initialValues['collegeName'] ?? '',
    );
    _universityController = TextEditingController(
      text: widget.initialValues['universityName'] ?? '',
    );
    _primaryAddressStayPeriodController = TextEditingController(
      text: widget.initialValues['primaryAddressStayPeriod'] ?? '',
    );
    _currentCitySameAsPrimaryAddress =
        widget.initialValues['currentCitySameAsPrimaryAddress'] == 'true';

    final parsedPlace = parseIndianPlace(widget.initialValues['place'] ?? '');
    final initialState = widget.initialValues['stateName']?.isNotEmpty == true
        ? widget.initialValues['stateName']!
        : parsedPlace.state;
    _stateSelection = kIndianStatesAndUnionTerritories.contains(initialState)
        ? initialState
        : null;
    final initialCity = widget.initialValues['city']?.isNotEmpty == true
        ? widget.initialValues['city']!
        : parsedPlace.city;
    final cityOptions = citiesForState(_stateSelection);
    _citySelection = cityOptions.contains(initialCity)
        ? initialCity
        : (initialCity.isEmpty ? null : kLocationOther);
    _cityOtherController = TextEditingController(
      text: _citySelection == kLocationOther ? initialCity : '',
    );
    final initialStayDuration = widget.initialValues['stayDuration'] ?? '';
    _stayDurationSelection = kStayDurationOptions.contains(initialStayDuration)
        ? initialStayDuration
        : null;
    final initialStayReason = widget.initialValues['stayReason'] ?? '';
    _stayReasonSelection = kStayReasonOptions.contains(initialStayReason)
        ? initialStayReason
        : (initialStayReason.isEmpty ? null : kLocationOther);
    _stayReasonOtherController = TextEditingController(
      text: _stayReasonSelection == kLocationOther ? initialStayReason : '',
    );

    final initialReligion = widget.initialValues['religion'] ?? '';
    final initialCaste = widget.initialValues['caste'] ?? '';

    _religionSelection = kReligions.contains(initialReligion)
        ? initialReligion
        : (initialReligion.isEmpty ? null : kOtherOption);
    _religionOtherController = TextEditingController(
      text: _religionSelection == kOtherOption ? initialReligion : '',
    );

    final casteOptions = castesFor(_religionSelection);
    _casteSelection = casteOptions.contains(initialCaste)
        ? initialCaste
        : (initialCaste.isEmpty ? null : kOtherOption);
    _casteOtherController = TextEditingController(
      text: _casteSelection == kOtherOption ? initialCaste : '',
    );
    final initialJob = widget.initialValues['job'] ?? '';
    final initialEducation = widget.initialValues['education'] ?? '';
    _jobSelection = _selectionFor(initialJob, kOccupationOptions);
    _educationSelection = _selectionFor(initialEducation, kEducationOptions);
    _jobOtherController = TextEditingController(
      text: _jobSelection == kProfessionalOtherOption ? initialJob : '',
    );
    _educationOtherController = TextEditingController(
      text: _educationSelection == kProfessionalOtherOption
          ? initialEducation
          : '',
    );

    _religionOtherController.addListener(() {
      if (_religionSelection == kOtherOption) {
        _controllers['religion']!.text = _religionOtherController.text;
      }
    });
    _casteOtherController.addListener(() {
      if (_casteSelection == kOtherOption) {
        _controllers['caste']!.text = _casteOtherController.text;
      }
    });
    _jobOtherController.addListener(() {
      if (_jobSelection == kProfessionalOtherOption) {
        _controllers['job']!.text = _jobOtherController.text;
      }
    });
    _educationOtherController.addListener(() {
      if (_educationSelection == kProfessionalOtherOption) {
        _controllers['education']!.text = _educationOtherController.text;
      }
    });
    _cityOtherController.addListener(() {
      if (_citySelection == kLocationOther) {
        _controllers['city']!.text = _cityOtherController.text;
      }
    });
    _stayReasonOtherController.addListener(() {
      _motherTongueOtherController.addListener(() {
        if (_motherTongueSelection == 'Other') {
          _controllers['motherTongue']!.text =
              _motherTongueOtherController.text;
        }
      });
      for (final controller in [
        _schoolController,
        _collegeController,
        _universityController,
        _primaryAddressStayPeriodController,
      ]) {
        controller.addListener(_notifyChange);
      }
      if (_stayReasonSelection == kLocationOther) {
        _controllers['stayReason']!.text = _stayReasonOtherController.text;
      }
    });
  }

  String? _selectionFor(String value, List<String> options) {
    if (options.contains(value)) return value;
    return value.isEmpty ? null : kProfessionalOtherOption;
  }

  void _notifyChange() {
    final values = {
      for (final entry in _controllers.entries) entry.key: entry.value.text,
    };
    final city = _citySelection == kLocationOther
        ? _cityOtherController.text.trim()
        : (_citySelection ?? '');
    values['stateName'] = _stateSelection ?? '';
    values['city'] = city;
    values['place'] = city.isEmpty
        ? ''
        : (_stateSelection == null ? city : '$city, $_stateSelection');
    values['stayDuration'] = _stayDurationSelection ?? '';
    values['stayReason'] = _stayReasonSelection == kLocationOther
        ? _stayReasonOtherController.text.trim()
        : (_stayReasonSelection ?? '');
    values['schoolName'] = _schoolController.text;
    values['collegeName'] = _collegeController.text;
    values['universityName'] = _universityController.text;
    values['currentCitySameAsPrimaryAddress'] = _currentCitySameAsPrimaryAddress
        .toString();
    if (_currentCitySameAsPrimaryAddress) {
      values['currentCity'] = values['place'] ?? '';
      values['stayDuration'] = '';
      values['stayReason'] = '';
    }
    values['primaryAddressStayPeriod'] = _primaryAddressStayPeriodController
        .text
        .trim();
    values['currentCitySameAsPrimaryAddress'] = _currentCitySameAsPrimaryAddress
        .toString();
    widget.onChanged(values);
  }

  void _onReligionSelected(String? value) {
    setState(() {
      _religionSelection = value;
      _controllers['religion']!.text = value == kOtherOption
          ? _religionOtherController.text
          : (value ?? '');
      // Caste options depend on religion, so reset the caste selection.
      _casteSelection = null;
      _casteOtherController.text = '';
      _controllers['caste']!.text = '';
    });
  }

  void _onCasteSelected(String? value) {
    setState(() {
      _casteSelection = value;
      _controllers['caste']!.text = value == kOtherOption
          ? _casteOtherController.text
          : (value ?? '');
    });
  }

  void _onJobSelected(String? value) {
    setState(() {
      _jobSelection = value;
      _controllers['job']!.text = value == kProfessionalOtherOption
          ? _jobOtherController.text
          : (value ?? '');
    });
  }

  void _onEducationSelected(String? value) {
    setState(() {
      _educationSelection = value;
      _controllers['education']!.text = value == kProfessionalOtherOption
          ? _educationOtherController.text
          : (value ?? '');
    });
  }

  void _onGenderSelected(String? value) {
    setState(() => _genderSelection = value);
    _controllers['gender']!.text = value ?? '';
  }

  void _onMaritalStatusSelected(String? value) {
    setState(() => _maritalStatusSelection = value);
    _controllers['maritalStatus']!.text = value ?? '';
  }

  void _onStateSelected(String? value) {
    setState(() {
      _stateSelection = value;
      if (_citySelection != kLocationOther) {
        _citySelection = null;
        _cityOtherController.clear();
        _controllers['city']!.clear();
      }
      _controllers['stateName']!.text = value ?? '';
    });
    _notifyChange();
  }

  void _onCitySelected(String? value) {
    setState(() => _citySelection = value);
    _controllers['city']!.text = value == kLocationOther
        ? _cityOtherController.text
        : (value ?? '');
    _notifyChange();
  }

  void _onStayDurationSelected(String? value) {
    setState(() => _stayDurationSelection = value);
    _controllers['stayDuration']!.text = value ?? '';
  }

  void _onStayReasonSelected(String? value) {
    setState(() => _stayReasonSelection = value);
    _controllers['stayReason']!.text = value == kLocationOther
        ? _stayReasonOtherController.text
        : (value ?? '');
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _religionOtherController.dispose();
    _casteOtherController.dispose();
    _jobOtherController.dispose();
    _educationOtherController.dispose();
    _cityOtherController.dispose();
    _stayReasonOtherController.dispose();
    _motherTongueOtherController.dispose();
    _schoolController.dispose();
    _collegeController.dispose();
    _universityController.dispose();
    _primaryAddressStayPeriodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1520).withAlpha(204),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const Divider(height: 1, color: Color(0x1AFFFFFF), thickness: 1),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    for (int i = 0; i < _fields.length; i++) ...[
                      _buildField(_fields[i]),
                      if (i < _fields.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFC8556A).withAlpha(31),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 16,
              color: Color(0xFFC8556A),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Personal & Professional',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFEEE0F0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(Map<String, String> field) {
    if (field['key'] == 'dob') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(field['label']!),
          const SizedBox(height: 4),
          TextFormField(
            controller: _controllers['dob'],
            readOnly: true,
            onTap: _selectDateOfBirth,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: Color(0xFFEEE0F0),
            ),
            decoration: _fieldDecoration(hintText: 'Select your birth date'),
          ),
        ],
      );
    }
    if (field['key'] == 'religion') {
      return _buildReligionField(field);
    }
    if (field['key'] == 'motherTongue') {
      return _buildMotherTongueField(field);
    }
    if (field['key'] == 'caste') {
      return _buildCasteField(field);
    }
    if (field['key'] == 'job') {
      return _buildOtherChoiceField(
        field: field,
        value: _jobSelection,
        options: kOccupationOptions,
        otherController: _jobOtherController,
        onChanged: _onJobSelected,
      );
    }
    if (field['key'] == 'education') {
      return _buildOtherChoiceField(
        field: field,
        value: _educationSelection,
        options: kEducationOptions,
        otherController: _educationOtherController,
        onChanged: _onEducationSelected,
      );
    }
    if (field['key'] == 'gender') {
      return _buildChoiceField(
        field: field,
        value: _genderSelection,
        options: kProfileGenders,
        onChanged: _onGenderSelected,
      );
    }
    if (field['key'] == 'maritalStatus') {
      return _buildChoiceField(
        field: field,
        value: _maritalStatusSelection,
        options: kMaritalStatuses,
        onChanged: _onMaritalStatusSelected,
      );
    }
    if (field['key'] == 'stateName') {
      return _buildChoiceField(
        field: field,
        value: _stateSelection,
        options: kIndianStatesAndUnionTerritories,
        onChanged: _onStateSelected,
      );
    }
    if (field['key'] == 'city') return _buildCityField(field);
    if (field['key'] == 'schoolName') {
      return _buildTextField('School', _schoolController, 'School name');
    }
    if (field['key'] == 'collegeName') {
      return _buildTextField('College', _collegeController, 'College name');
    }
    if (field['key'] == 'universityName') {
      return _buildTextField(
        'University',
        _universityController,
        'University name',
      );
    }
    if (field['key'] == 'primaryAddressStayPeriod') {
      return _buildTextField(
        field['label']!,
        _primaryAddressStayPeriodController,
        field['hint']!,
      );
    }
    if (field['key'] == 'currentCitySameAsPrimaryAddress') {
      return _buildSameAddressSwitch();
    }
    if (_currentCitySameAsPrimaryAddress &&
        ['currentCity', 'stayDuration', 'stayReason'].contains(field['key'])) {
      return const SizedBox.shrink();
    }
    if (field['key'] == 'stayDuration') {
      return _buildChoiceField(
        field: field,
        value: _stayDurationSelection,
        options: kStayDurationOptions,
        onChanged: _onStayDurationSelected,
      );
    }
    if (field['key'] == 'stayReason') return _buildStayReasonField(field);
    final isLockedName =
        widget.namesLocked && (field['key'] == 'firstName' || field['key'] == 'lastName');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildLabel(field['label']!),
            if (field['required'] == 'true')
              const Text(
                ' *',
                style: TextStyle(color: Color(0xFFE57373), fontWeight: FontWeight.w700),
              ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _controllers[field['key']],
          readOnly: isLockedName,
          validator: field['required'] == 'true'
              ? (value) => (value == null || value.trim().isEmpty)
                  ? '${field['label']} is required'
                  : null
              : null,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            color: isLockedName ? const Color(0xFF9A8A9E) : const Color(0xFFEEE0F0),
          ),
          decoration: _fieldDecoration(hintText: field['hint']).copyWith(
            suffixIcon: isLockedName
                ? const Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF9A8A9E))
                : null,
          ),
        ),
        if (isLockedName)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Locked after Aadhar name verification',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, color: Color(0xFF9A8A9E)),
            ),
          ),
      ],
    );
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final initial =
        DateTime.tryParse(_controllers['dob']!.text) ??
        DateTime(now.year - 25, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select date of birth',
    );
    if (picked == null || !mounted) return;
    _controllers['dob']!.text =
        '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
    _notifyChange();
  }

  Widget _buildMotherTongueField(Map<String, String> field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field['label']!),
        const SizedBox(height: 4),
        _buildDropdown(
          value: _motherTongueSelection,
          hint: field['hint']!,
          items: kMotherTongueOptions,
          onChanged: (value) {
            setState(() => _motherTongueSelection = value);
            _controllers['motherTongue']!.text = value == 'Other'
                ? _motherTongueOtherController.text
                : (value ?? '');
          },
        ),
        if (_motherTongueSelection == 'Other') ...[
          const SizedBox(height: 8),
          _buildTextField(
            'Other mother tongue',
            _motherTongueOtherController,
            'Enter language',
          ),
        ],
      ],
    );
  }

  Widget _buildSameAddressSwitch() {
    return Material(
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
          _notifyChange();
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildLabel(label),
      const SizedBox(height: 4),
      TextFormField(
        controller: controller,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 13,
          color: Color(0xFFEEE0F0),
        ),
        decoration: _fieldDecoration(hintText: hint),
      ),
    ],
  );

  Widget _buildReligionField(Map<String, String> field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field['label']!),
        const SizedBox(height: 4),
        _buildDropdown(
          value: _religionSelection,
          hint: 'Select religion',
          items: kReligions,
          onChanged: _onReligionSelected,
        ),
        if (_religionSelection == kOtherOption) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _religionOtherController,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: Color(0xFFEEE0F0),
            ),
            decoration: _fieldDecoration(hintText: 'Enter your religion'),
          ),
        ],
      ],
    );
  }

  Widget _buildCasteField(Map<String, String> field) {
    final casteOptions = castesFor(_religionSelection);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field['label']!),
        const SizedBox(height: 4),
        _buildDropdown(
          value: casteOptions.contains(_casteSelection)
              ? _casteSelection
              : null,
          hint: 'Select caste / community',
          items: casteOptions,
          onChanged: _onCasteSelected,
        ),
        if (_casteSelection == kOtherOption) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _casteOtherController,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: Color(0xFFEEE0F0),
            ),
            decoration: _fieldDecoration(hintText: 'Enter your caste'),
          ),
        ],
      ],
    );
  }

  Widget _buildOtherChoiceField({
    required Map<String, String> field,
    required String? value,
    required List<String> options,
    required TextEditingController otherController,
    required ValueChanged<String?> onChanged,
  }) {
    final fieldKey = field['key']!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field['label']!),
        const SizedBox(height: 4),
        _buildDropdown(
          value: value,
          hint: 'Select ${field['label']!.toLowerCase()}',
          items: options,
          onChanged: onChanged,
        ),
        if (value == kProfessionalOtherOption) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: otherController,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: Color(0xFFEEE0F0),
            ),
            decoration: _fieldDecoration(
              hintText:
                  'Enter ${fieldKey == 'job' ? 'your occupation' : 'your education'}',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChoiceField({
    required Map<String, String> field,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field['label']!),
        const SizedBox(height: 4),
        _buildDropdown(
          value: value,
          hint: field['hint']!,
          items: options,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCityField(Map<String, String> field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field['label']!),
        const SizedBox(height: 4),
        _buildDropdown(
          value: _stateSelection == null ? null : _citySelection,
          hint: _stateSelection == null
              ? 'Select a state or Union Territory first'
              : field['hint']!,
          items: _stateSelection == null
              ? const []
              : citiesForState(_stateSelection),
          onChanged: _stateSelection == null ? null : _onCitySelected,
        ),
        if (_citySelection == kLocationOther) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _cityOtherController,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: Color(0xFFEEE0F0),
            ),
            decoration: _fieldDecoration(hintText: 'Enter your city'),
          ),
        ],
      ],
    );
  }

  Widget _buildStayReasonField(Map<String, String> field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field['label']!),
        const SizedBox(height: 4),
        _buildDropdown(
          value: _stayReasonSelection,
          hint: field['hint']!,
          items: kStayReasonOptions,
          onChanged: _onStayReasonSelected,
        ),
        if (_stayReasonSelection == kLocationOther) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _stayReasonOtherController,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: Color(0xFFEEE0F0),
            ),
            decoration: _fieldDecoration(hintText: 'Enter your reason'),
          ),
        ],
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Color(0xFF9A8A9E),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
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
      decoration: _fieldDecoration(hintText: hint),
      items: [
        for (final item in items)
          DropdownMenuItem<String>(value: item, child: Text(item)),
      ],
      onChanged: onChanged,
    );
  }

  InputDecoration _fieldDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 13,
        color: Color(0x559A8A9E),
      ),
      filled: true,
      fillColor: const Color(0xFF120D16).withAlpha(128),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0x1AFFFFFF), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0x1AFFFFFF), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFC8556A), width: 1.5),
      ),
    );
  }
}
