import 'dart:ui';
import 'package:flutter/material.dart';

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

  static const _fields = [
    {
      'key': 'partnerAgeRange',
      'label': 'Partner Age Range',
      'hint': 'e.g. 28 – 34 years',
    },
    {
      'key': 'partnerHeightRange',
      'label': 'Partner Height',
      'hint': 'e.g. 170 cm and above',
    },
    {
      'key': 'partnerReligion',
      'label': 'Partner Religion',
      'hint': 'e.g. Hindu',
    },
    {
      'key': 'partnerPlace',
      'label': 'Preferred Location',
      'hint': 'e.g. Tamil Nadu / Karnataka',
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
    for (final c in _controllers.values) {
      c.addListener(_notifyChange);
    }
  }

  void _notifyChange() {
    widget.onChanged({
      for (final entry in _controllers.entries) entry.key: entry.value.text,
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
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
              Icons.favorite_border_rounded,
              size: 16,
              color: Color(0xFFC8556A),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
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
  }

  Widget _buildField(Map<String, String> field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field['label']!,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9A8A9E),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _controllers[field['key']],
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            color: Color(0xFFEEE0F0),
          ),
          decoration: InputDecoration(
            hintText: field['hint'],
            hintStyle: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: Color(0x559A8A9E),
            ),
            filled: true,
            fillColor: const Color(0xFF120D16).withAlpha(128),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
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
              borderSide: const BorderSide(
                color: Color(0xFFC8556A),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
