import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

class EditFamilySectionWidget extends StatefulWidget {
  final Map<String, String> initialValues;
  final void Function(Map<String, String> values) onChanged;

  const EditFamilySectionWidget({
    super.key,
    required this.initialValues,
    required this.onChanged,
  });

  @override
  State<EditFamilySectionWidget> createState() =>
      _EditFamilySectionWidgetState();
}

class _EditFamilySectionWidgetState extends State<EditFamilySectionWidget> {
  late final TextEditingController _fatherNameController;
  late final TextEditingController _fatherJobController;
  late final TextEditingController _motherNameController;
  late final TextEditingController _motherJobController;
  late bool _fatherIsDeceased;
  late bool _motherIsDeceased;
  final List<_SiblingDraft> _siblings = [];

  @override
  void initState() {
    super.initState();
    final values = widget.initialValues;
    _fatherNameController = TextEditingController(text: values['fatherName']);
    _fatherJobController = TextEditingController(text: values['fatherJob']);
    _motherNameController = TextEditingController(text: values['motherName']);
    _motherJobController = TextEditingController(text: values['motherJob']);
    _fatherIsDeceased = values['fatherIsDeceased'] == 'true';
    _motherIsDeceased = values['motherIsDeceased'] == 'true';
    for (final controller in [
      _fatherNameController,
      _fatherJobController,
      _motherNameController,
      _motherJobController,
    ]) {
      controller.addListener(_notifyChange);
    }
    _loadSiblings(values['siblings']);
  }

  void _loadSiblings(String? value) {
    if (value == null || value.isEmpty) return;
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List) return;
      for (final item in decoded.whereType<Map>()) {
        final sibling = _SiblingDraft.fromMap(item);
        _siblings.add(sibling);
        sibling.addListener(_notifyChange);
      }
    } on FormatException {
      return;
    }
  }

  void _notifyChange() {
    widget.onChanged({
      'fatherName': _fatherNameController.text,
      'fatherIsDeceased': _fatherIsDeceased.toString(),
      'fatherJob': _fatherJobController.text,
      'motherName': _motherNameController.text,
      'motherIsDeceased': _motherIsDeceased.toString(),
      'motherJob': _motherJobController.text,
      'siblings': jsonEncode(
        _siblings.map((sibling) => sibling.toMap()).toList(),
      ),
    });
  }

  void _addSibling() {
    setState(() {
      final sibling = _SiblingDraft();
      sibling.addListener(_notifyChange);
      _siblings.add(sibling);
    });
    _notifyChange();
  }

  void _removeSibling(_SiblingDraft sibling) {
    setState(() => _siblings.remove(sibling));
    sibling.removeListener(_notifyChange);
    sibling.dispose();
    _notifyChange();
  }

  @override
  void dispose() {
    _fatherNameController.dispose();
    _fatherJobController.dispose();
    _motherNameController.dispose();
    _motherJobController.dispose();
    for (final sibling in _siblings) {
      sibling.removeListener(_notifyChange);
      sibling.dispose();
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildParentSection(
                      title: "Father's Details",
                      nameController: _fatherNameController,
                      jobController: _fatherJobController,
                      isDeceased: _fatherIsDeceased,
                      onDeceasedChanged: (value) => setState(() {
                        _fatherIsDeceased = value;
                        _notifyChange();
                      }),
                    ),
                    const SizedBox(height: 18),
                    _buildParentSection(
                      title: "Mother's Details",
                      nameController: _motherNameController,
                      jobController: _motherJobController,
                      isDeceased: _motherIsDeceased,
                      onDeceasedChanged: (value) => setState(() {
                        _motherIsDeceased = value;
                        _notifyChange();
                      }),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Siblings',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEEE0F0),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _addSibling,
                          tooltip: 'Add sibling',
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: Color(0xFFC8556A),
                          ),
                        ),
                      ],
                    ),
                    if (_siblings.isEmpty)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'No siblings added',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            color: Color(0xFF9A8A9E),
                          ),
                        ),
                      ),
                    for (var index = 0; index < _siblings.length; index++)
                      _buildSibling(_siblings[index], index),
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
              Icons.family_restroom_rounded,
              size: 16,
              color: Color(0xFFC8556A),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Family Details',
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

  Widget _buildParentSection({
    required String title,
    required TextEditingController nameController,
    required TextEditingController jobController,
    required bool isDeceased,
    required ValueChanged<bool> onDeceasedChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFFEEE0F0),
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          label: 'Name',
          hint: 'Enter name',
          controller: nameController,
        ),
        Material(
          color: Colors.transparent,
          child: SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Passed away',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                color: Color(0xFFEEE0F0),
              ),
            ),
            value: isDeceased,
            activeColor: const Color(0xFFC8556A),
            onChanged: onDeceasedChanged,
          ),
        ),
        _buildTextField(
          label: 'Occupation',
          hint: isDeceased
              ? 'Former occupation (optional)'
              : 'Enter occupation',
          controller: jobController,
        ),
      ],
    );
  }

  Widget _buildSibling(_SiblingDraft sibling, int index) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF120D16).withAlpha(128),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sibling ${index + 1}',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEEE0F0),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _removeSibling(sibling),
                tooltip: 'Remove sibling',
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: const Color(0xFF9A8A9E),
              ),
            ],
          ),
          _buildTextField(
            label: 'Name',
            hint: 'Enter name',
            controller: sibling.nameController,
          ),
          const SizedBox(height: 10),
          _buildDropdown(
            label: 'Relationship',
            value: sibling.relationship,
            options: const ['Brother', 'Sister'],
            onChanged: (value) {
              sibling.relationship = value ?? 'Brother';
              _notifyChange();
            },
          ),
          Material(
            color: Colors.transparent,
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Married',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: Color(0xFFEEE0F0),
                ),
              ),
              value: sibling.isMarried,
              activeColor: const Color(0xFFC8556A),
              onChanged: (value) {
                sibling.isMarried = value;
                setState(() {});
                _notifyChange();
              },
            ),
          ),
          _buildTextField(
            label: 'Occupation',
            hint: 'Enter occupation',
            controller: sibling.jobController,
          ),
          Material(
            color: Colors.transparent,
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Has children',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: Color(0xFFEEE0F0),
                ),
              ),
              value: sibling.hasChildren,
              activeColor: const Color(0xFFC8556A),
              onChanged: (value) {
                sibling.hasChildren = value;
                setState(() {});
                _notifyChange();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E1520),
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            color: Color(0xFFEEE0F0),
          ),
          decoration: _decoration(),
          items: [
            for (final option in options)
              DropdownMenuItem(value: option, child: Text(option)),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
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
          decoration: _decoration(hint),
        ),
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

  InputDecoration _decoration([String? hint]) {
    return InputDecoration(
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

class _SiblingDraft {
  final TextEditingController nameController;
  final TextEditingController jobController;
  String relationship;
  bool isMarried;
  bool hasChildren;

  _SiblingDraft({
    String name = '',
    this.relationship = 'Brother',
    this.isMarried = false,
    String job = '',
    this.hasChildren = false,
  }) : nameController = TextEditingController(text: name),
       jobController = TextEditingController(text: job);

  factory _SiblingDraft.fromMap(Map<dynamic, dynamic> map) {
    return _SiblingDraft(
      name: map['name']?.toString() ?? '',
      relationship: map['relationship'] == 'Sister' ? 'Sister' : 'Brother',
      isMarried: map['isMarried'] == true,
      job: map['job']?.toString() ?? '',
      hasChildren: map['hasChildren'] == true,
    );
  }

  void addListener(VoidCallback listener) {
    nameController.addListener(listener);
    jobController.addListener(listener);
  }

  void removeListener(VoidCallback listener) {
    nameController.removeListener(listener);
    jobController.removeListener(listener);
  }

  Map<String, dynamic> toMap() => {
    'name': nameController.text,
    'relationship': relationship,
    'isMarried': isMarried,
    'job': jobController.text,
    'hasChildren': hasChildren,
  };

  void dispose() {
    nameController.dispose();
    jobController.dispose();
  }
}
