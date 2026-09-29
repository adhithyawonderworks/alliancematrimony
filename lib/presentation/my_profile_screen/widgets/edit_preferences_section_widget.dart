import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/india_location_data.dart';
import '../../../core/profile_relationship_data.dart';
import '../../../core/religion_caste_data.dart';

class EditPreferencesSectionWidget extends StatefulWidget {
  final Map<String, String> initialValues;
  final void Function(Map<String, String> values) onChanged;

  const EditPreferencesSectionWidget({
    super.key,
    required this.initialValues,
    required this.onChanged,
  });

  @override
  State<EditPreferencesSectionWidget> createState() =>
      _EditPreferencesSectionWidgetState();
}

class _EditPreferencesSectionWidgetState
    extends State<EditPreferencesSectionWidget> {
  late final Map<String, TextEditingController> _controllers;
  late final TextEditingController _religionOtherController;
  late final TextEditingController _casteOtherController;
  late final TextEditingController _countryOtherController;
  late final TextEditingController _districtOtherController;
  late final TextEditingController _ageMinController;
  late final TextEditingController _ageMaxController;
  late final TextEditingController _heightCmController;
  late final TextEditingController _heightFeetController;
  late final TextEditingController _heightInchesController;

  String _religionMode = 'religion_caste';
  String? _religionSelection;
  String? _casteSelection;
  String? _partnerGender;
  String? _partnerMaritalStatus;
  String? _partnerLocationMode;
  String? _partnerState;
  String? _partnerDistrict;
  String? _partnerCountry;
  String? _partnerLanguage;
  final Set<String> _partnerLanguages = {};

  static final List<String> _ageOptions = List.generate(
    53,
    (index) => '${index + 18}',
  );
  static const _heightFeetOptions = ['4', '5', '6', '7'];
  static final List<String> _heightInchOptions = List.generate(
    12,
    (index) => '$index',
  );
  static const _religionModes = {
    'religion_caste': 'Religion and caste',
    'religion_only': 'Religion only, no caste preference',
    'any_religion': 'No religion preference',
  };

  @override
  void initState() {
    super.initState();
    final initialAgeRange = widget.initialValues['partnerAgeRange'] ?? '';
    final ages = RegExp(
      r'\d+',
    ).allMatches(initialAgeRange).map((m) => m[0]!).toList();
    final initialHeight = widget.initialValues['partnerHeightRange'] ?? '';
    final heightCm = RegExp(r'\d+').firstMatch(initialHeight)?.group(0) ?? '';
    final religionValue = widget.initialValues['partnerReligion'] ?? '';
    final casteValue = widget.initialValues['partnerCaste'] ?? '';
    final initialLocationMode =
        widget.initialValues['partnerLocationMode'] ?? '';

    _ageMinController = TextEditingController(
      text:
          widget.initialValues['partnerAgeMin'] ??
          (ages.isNotEmpty ? ages.first : ''),
    );
    _ageMaxController = TextEditingController(
      text:
          widget.initialValues['partnerAgeMax'] ??
          (ages.length > 1 ? ages[1] : ''),
    );
    _heightCmController = TextEditingController(
      text: widget.initialValues['partnerHeightCm'] ?? heightCm,
    );
    final initialFeet = widget.initialValues['partnerHeightFeet'] ?? '';
    final initialInches = widget.initialValues['partnerHeightInches'] ?? '';
    if (initialFeet.isNotEmpty || initialInches.isNotEmpty) {
      _heightFeetController = TextEditingController(text: initialFeet);
      _heightInchesController = TextEditingController(text: initialInches);
    } else {
      final cm = int.tryParse(heightCm) ?? 0;
      final totalInches = (cm / 2.54).round();
      _heightFeetController = TextEditingController(
        text: cm == 0 ? '' : '${totalInches ~/ 12}',
      );
      _heightInchesController = TextEditingController(
        text: cm == 0 ? '' : '${totalInches % 12}',
      );
    }
    _religionSelection = kReligions.contains(religionValue)
        ? religionValue
        : null;
    _casteSelection = castesFor(_religionSelection).contains(casteValue)
        ? casteValue
        : null;
    _religionMode =
        widget.initialValues['partnerReligionMode'] ??
        (religionValue.isEmpty
            ? 'any_religion'
            : (casteValue.isEmpty ? 'religion_only' : 'religion_caste'));
    _religionOtherController = TextEditingController(
      text: _religionSelection == null && religionValue.isNotEmpty
          ? religionValue
          : '',
    );
    _casteOtherController = TextEditingController(
      text: _casteSelection == null && casteValue.isNotEmpty ? casteValue : '',
    );
    _countryOtherController = TextEditingController(
      text: widget.initialValues['partnerCountryOther'] ?? '',
    );
    _districtOtherController = TextEditingController(
      text: widget.initialValues['partnerDistrictOther'] ?? '',
    );
    _partnerGender =
        kPartnerGenderOptions.contains(widget.initialValues['partnerGender'])
        ? widget.initialValues['partnerGender']
        : 'No preference';
    _partnerMaritalStatus =
        kPartnerMaritalOptions.contains(
          widget.initialValues['partnerMaritalStatus'],
        )
        ? widget.initialValues['partnerMaritalStatus']
        : 'No preference';
    _partnerLocationMode = kPartnerLocationModes.contains(initialLocationMode)
        ? initialLocationMode
        : (widget.initialValues['partnerState']?.isNotEmpty == true
              ? 'India'
              : (widget.initialValues['partnerCountry']?.isNotEmpty == true
                    ? 'Foreign country'
                    : 'Anywhere in the world'));
    _partnerState =
        kIndianStatesAndUnionTerritories.contains(
          widget.initialValues['partnerState'],
        )
        ? widget.initialValues['partnerState']
        : null;
    _partnerDistrict =
        districtsForState(
          _partnerState,
        ).contains(widget.initialValues['partnerDistrict'])
        ? widget.initialValues['partnerDistrict']
        : 'No district preference';
    _partnerCountry =
        kPartnerCountries.contains(widget.initialValues['partnerCountry'])
        ? widget.initialValues['partnerCountry']
        : null;
    _partnerLanguage =
        kLanguagePreferenceOptions.contains(
          widget.initialValues['partnerLanguage'],
        )
        ? widget.initialValues['partnerLanguage']
        : 'No preference';
    _partnerLanguages.addAll(
      (widget.initialValues['partnerLanguages'] ?? '')
          .split(',')
          .map((language) => language.trim())
          .where((language) => kPartnerLanguageOptions.contains(language)),
    );

    for (final controller in [
      _ageMinController,
      _ageMaxController,
      _heightCmController,
      _heightFeetController,
      _heightInchesController,
      _religionOtherController,
      _casteOtherController,
      _countryOtherController,
      _districtOtherController,
    ]) {
      controller.addListener(_notifyChange);
    }
  }

  void _notifyChange() {
    final ageMin = _ageMinController.text;
    final ageMax = _ageMaxController.text;
    final heightCm = _heightCmController.text;
    widget.onChanged({
      'partnerAgeMin': ageMin,
      'partnerAgeMax': ageMax,
      'partnerAgeRange': ageMin.isEmpty && ageMax.isEmpty
          ? ''
          : '${ageMin.isEmpty ? '18' : ageMin}-${ageMax.isEmpty ? '70' : ageMax}',
      'partnerHeightCm': heightCm,
      'partnerHeightFeet': _heightFeetController.text,
      'partnerHeightInches': _heightInchesController.text,
      'partnerHeightRange': heightCm.isEmpty
          ? (_heightFeetController.text.isEmpty
                ? ''
                : "${_heightFeetController.text}' ${_heightInchesController.text}\" ")
          : '$heightCm cm',
      'partnerReligionMode': _religionMode,
      'partnerReligion': _religionMode == 'any_religion'
          ? 'No religion preference'
          : (_religionSelection ?? _religionOtherController.text.trim()),
      'partnerCaste': _religionMode != 'religion_caste'
          ? ''
          : (_casteSelection ?? _casteOtherController.text.trim()),
      'partnerGender': _partnerGender ?? 'No preference',
      'partnerMaritalStatus': _partnerMaritalStatus ?? 'No preference',
      'partnerLocationMode': _partnerLocationMode ?? 'Anywhere in the world',
      'partnerState': _partnerState ?? '',
      'partnerDistrict': _partnerDistrict == 'Other district'
          ? _districtOtherController.text.trim()
          : (_partnerDistrict ?? ''),
      'partnerDistrictOther': _districtOtherController.text,
      'partnerCountry': _partnerCountry == 'Other country'
          ? _countryOtherController.text.trim()
          : (_partnerCountry ?? ''),
      'partnerCountryOther': _countryOtherController.text,
      'partnerLanguage': _partnerLanguage ?? 'No preference',
      'partnerLanguages': _partnerLanguages.join(', '),
      'partnerPlace': _composePartnerPlace(),
    });
  }

  String _composePartnerPlace() {
    switch (_partnerLocationMode) {
      case 'India':
        if (_partnerState == null) return '';
        if (_partnerDistrict == null ||
            _partnerDistrict == 'No district preference') {
          return _partnerState!;
        }
        final district = _partnerDistrict == 'Other district'
            ? _districtOtherController.text.trim()
            : _partnerDistrict!;
        return district.isEmpty ? _partnerState! : '$district, $_partnerState';
      case 'Foreign country':
        return _partnerCountry == 'Other country'
            ? _countryOtherController.text.trim()
            : (_partnerCountry ?? '');
      default:
        return 'Anywhere in the world';
    }
  }

  void _onReligionModeChanged(String? value) {
    if (value == null) return;
    setState(() {
      _religionMode = value;
      if (value == 'any_religion') {
        _religionSelection = null;
        _casteSelection = null;
      } else if (value == 'religion_only') {
        _casteSelection = null;
      }
    });
    _notifyChange();
  }

  void _onReligionChanged(String? value) {
    setState(() {
      _religionSelection = value;
      _casteSelection = null;
      _casteOtherController.clear();
    });
    _notifyChange();
  }

  void _onPartnerLocationModeChanged(String? value) {
    setState(() {
      _partnerLocationMode = value;
      if (value != 'India') {
        _partnerState = null;
        _partnerDistrict = null;
      }
      if (value != 'Foreign country') _partnerCountry = null;
    });
    _notifyChange();
  }

  void _onPartnerStateChanged(String? value) {
    setState(() {
      _partnerState = value;
      _partnerDistrict = 'No district preference';
      _districtOtherController.clear();
    });
    _notifyChange();
  }

  void _onPartnerCountryChanged(String? value) {
    setState(() => _partnerCountry = value);
    _notifyChange();
  }

  @override
  void dispose() {
    for (final controller in [
      _religionOtherController,
      _casteOtherController,
      _countryOtherController,
      _districtOtherController,
      _ageMinController,
      _ageMaxController,
      _heightCmController,
      _heightFeetController,
      _heightInchesController,
    ]) {
      controller.dispose();
    }
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
            border: Border.all(color: const Color(0x1AFFFFFF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const Divider(height: 1, color: Color(0x1AFFFFFF)),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAgeFields(),
                    const SizedBox(height: 14),
                    _buildHeightFields(),
                    const SizedBox(height: 14),
                    _buildReligionFields(),
                    const SizedBox(height: 14),
                    _buildDropdown(
                      'Looking for gender',
                      _partnerGender,
                      kPartnerGenderOptions,
                      (value) {
                        setState(() => _partnerGender = value);
                        _notifyChange();
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildDropdown(
                      'Looking for marital status',
                      _partnerMaritalStatus,
                      kPartnerMaritalOptions,
                      (value) {
                        setState(() => _partnerMaritalStatus = value);
                        _notifyChange();
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildLocationFields(),
                    const SizedBox(height: 14),
                    _buildDropdown(
                      'Mother tongue preference',
                      _partnerLanguage,
                      kLanguagePreferenceOptions,
                      (value) {
                        setState(() => _partnerLanguage = value);
                        _notifyChange();
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildLanguageChoices(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => const Padding(
    padding: EdgeInsets.all(14),
    child: Row(
      children: [
        Icon(Icons.favorite_border_rounded, size: 18, color: Color(0xFFC8556A)),
        SizedBox(width: 10),
        Text(
          'Partner Preferences',
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

  Widget _buildAgeFields() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Partner Age Range'),
      const SizedBox(height: 5),
      Row(
        children: [
          Expanded(
            child: _buildDropdown(
              'Minimum age',
              _ageMinController.text.isEmpty ? null : _ageMinController.text,
              _ageOptions,
              (value) {
                setState(() {
                  _ageMinController.text = value ?? '';
                  final maxAge = int.tryParse(_ageMaxController.text);
                  if (value != null &&
                      maxAge != null &&
                      maxAge < int.parse(value)) {
                    _ageMaxController.text = value;
                  }
                });
                _notifyChange();
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('to', style: TextStyle(color: Color(0xFF9A8A9E))),
          ),
          Expanded(
            child: _buildDropdown(
              'Maximum age',
              _ageMaxController.text.isEmpty ? null : _ageMaxController.text,
              _ageOptions,
              (value) {
                setState(() {
                  _ageMaxController.text = value ?? '';
                  final minAge = int.tryParse(_ageMinController.text);
                  if (value != null &&
                      minAge != null &&
                      minAge > int.parse(value)) {
                    _ageMinController.text = value;
                  }
                });
                _notifyChange();
              },
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildHeightFields() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Partner Height'),
      const SizedBox(height: 5),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _heightCmController,
              keyboardType: TextInputType.number,
              decoration: _decoration('Height in cm'),
              style: _inputStyle,
              onChanged: (value) {
                setState(() {
                  final cm = int.tryParse(value);
                  if (cm != null) {
                    final inches = (cm / 2.54).round();
                    _heightFeetController.text = '${inches ~/ 12}';
                    _heightInchesController.text = '${inches % 12}';
                  } else if (value.isEmpty) {
                    _heightFeetController.clear();
                    _heightInchesController.clear();
                  }
                });
                _notifyChange();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildDropdown(
              'Feet',
              _heightFeetController.text.isEmpty
                  ? null
                  : _heightFeetController.text,
              _heightFeetOptions,
              (value) {
                _heightFeetController.text = value ?? '';
                _syncHeightCm();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildDropdown(
              'Inches',
              _heightInchesController.text.isEmpty
                  ? null
                  : _heightInchesController.text,
              _heightInchOptions,
              (value) {
                _heightInchesController.text = value ?? '';
                _syncHeightCm();
              },
            ),
          ),
        ],
      ),
    ],
  );

  void _syncHeightCm() {
    final feet = int.tryParse(_heightFeetController.text) ?? 0;
    final inches = int.tryParse(_heightInchesController.text) ?? 0;
    if (_heightFeetController.text.isNotEmpty ||
        _heightInchesController.text.isNotEmpty) {
      setState(() {
        _heightCmController.text = (((feet * 12 + inches) * 2.54).round())
            .toString();
      });
    }
    _notifyChange();
  }

  Widget _buildReligionFields() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _label('Religion and Caste Preference'),
      const SizedBox(height: 5),
      _buildDropdown(
        'Choose preference',
        _religionMode,
        _religionModes.keys.toList(),
        _onReligionModeChanged,
        labels: _religionModes.values.toList(),
      ),
      if (_religionMode != 'any_religion') ...[
        const SizedBox(height: 10),
        _buildDropdown(
          'Religion',
          _religionSelection,
          kReligions,
          _onReligionChanged,
        ),
        if (_religionSelection == kOtherOption) ...[
          const SizedBox(height: 8),
          _buildTextField(_religionOtherController, 'Enter religion'),
        ],
      ],
      if (_religionMode == 'religion_caste') ...[
        const SizedBox(height: 10),
        _buildDropdown(
          'Caste / community',
          _casteSelection,
          castesFor(_religionSelection),
          (value) {
            setState(() => _casteSelection = value);
            _notifyChange();
          },
        ),
        if (_casteSelection == kOtherOption) ...[
          const SizedBox(height: 8),
          _buildTextField(_casteOtherController, 'Enter caste / community'),
        ],
      ],
    ],
  );

  Widget _buildLocationFields() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _label('Preferred Location'),
      const SizedBox(height: 5),
      _buildDropdown(
        'Location preference',
        _partnerLocationMode,
        kPartnerLocationModes,
        _onPartnerLocationModeChanged,
      ),
      if (_partnerLocationMode == 'India') ...[
        const SizedBox(height: 10),
        _buildDropdown(
          'State / Union Territory',
          _partnerState,
          kIndianStatesAndUnionTerritories,
          _onPartnerStateChanged,
        ),
        if (_partnerState != null) ...[
          const SizedBox(height: 10),
          _buildDropdown(
            'District',
            _partnerDistrict,
            districtsForState(_partnerState),
            (value) {
              setState(() => _partnerDistrict = value);
              _notifyChange();
            },
          ),
          if (_partnerDistrict == 'Other district') ...[
            const SizedBox(height: 8),
            _buildTextField(_districtOtherController, 'Enter district'),
          ],
        ],
      ],
      if (_partnerLocationMode == 'Foreign country') ...[
        const SizedBox(height: 10),
        _buildDropdown(
          'Country',
          _partnerCountry,
          kPartnerCountries,
          _onPartnerCountryChanged,
        ),
        if (_partnerCountry == 'Other country') ...[
          const SizedBox(height: 8),
          _buildTextField(_countryOtherController, 'Enter country'),
        ],
      ],
    ],
  );

  Widget _buildLanguageChoices() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Other language preferences'),
      const SizedBox(height: 6),
      Wrap(
        spacing: 6,
        runSpacing: 2,
        children: [
          for (final language in kPartnerLanguageOptions)
            FilterChip(
              label: Text(language),
              selected: _partnerLanguages.contains(language),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _partnerLanguages.add(language);
                  } else {
                    _partnerLanguages.remove(language);
                  }
                });
                _notifyChange();
              },
              selectedColor: const Color(0xFFC8556A).withAlpha(51),
              checkmarkColor: const Color(0xFFC8556A),
              labelStyle: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                color: Color(0xFFEEE0F0),
              ),
              backgroundColor: const Color(0xFF120D16),
              side: const BorderSide(color: Color(0x1AFFFFFF)),
            ),
        ],
      ),
    ],
  );

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> options,
    ValueChanged<String?> onChanged, {
    List<String>? labels,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      const SizedBox(height: 4),
      DropdownButtonFormField<String>(
        initialValue: options.contains(value) ? value : null,
        isExpanded: true,
        dropdownColor: const Color(0xFF1E1520),
        style: _inputStyle,
        decoration: _decoration('Select ${label.toLowerCase()}'),
        items: [
          for (var index = 0; index < options.length; index++)
            DropdownMenuItem(
              value: options[index],
              child: Text(labels == null ? options[index] : labels[index]),
            ),
        ],
        onChanged: onChanged,
      ),
    ],
  );

  Widget _buildTextField(TextEditingController controller, String hint) =>
      TextField(
        controller: controller,
        style: _inputStyle,
        decoration: _decoration(hint),
      );

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: Color(0xFF9A8A9E),
    ),
  );
  TextStyle get _inputStyle => const TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 13,
    color: Color(0xFFEEE0F0),
  );

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
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
      borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFC8556A), width: 1.5),
    ),
  );
}
