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
  late final TextEditingController _parentsNameCtrl;
  late final TextEditingController _parentsJobCtrl;

  @override
  void initState() {
    super.initState();
    _parentsNameCtrl = TextEditingController(
      text: widget.initialValues['parentsName'] ?? '',
    );
    _parentsJobCtrl = TextEditingController(
      text: widget.initialValues['parentsJob'] ?? '',
    );
    _parentsNameCtrl.addListener(_notifyChange);
    _parentsJobCtrl.addListener(_notifyChange);
  }

  void _notifyChange() {
    widget.onChanged({
      'parentsName': _parentsNameCtrl.text,
      'parentsJob': _parentsJobCtrl.text,
    });
  }

  @override
  void dispose() {
    _parentsNameCtrl.dispose();
    _parentsJobCtrl.dispose();
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
                    _buildField(
                      label: "Parents' Name",
                      hint: 'e.g. Ramesh & Lakshmi Sharma',
                      controller: _parentsNameCtrl,
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      label: "Parents' Occupation",
                      hint: 'e.g. Retired IAS Officer & Teacher',
                      controller: _parentsJobCtrl,
                    ),
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

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9A8A9E),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
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
