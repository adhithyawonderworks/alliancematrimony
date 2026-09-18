import 'dart:ui';
import 'package:flutter/material.dart';

class ProfileField {
  final String label;
  final String value;
  const ProfileField(this.label, this.value);
}

class ProfileInfoSectionWidget extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<ProfileField> fields;

  const ProfileInfoSectionWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.fields,
  });

  @override
  State<ProfileInfoSectionWidget> createState() =>
      _ProfileInfoSectionWidgetState();
}

class _ProfileInfoSectionWidgetState extends State<ProfileInfoSectionWidget>
    with SingleTickerProviderStateMixin {
  bool _expanded = true;
  late AnimationController _controller;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );
    _expandAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
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
            children: [
              InkWell(
                onTap: _toggle,
                borderRadius: BorderRadius.circular(16),
                splashColor: const Color(0xFFC8556A).withAlpha(20),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC8556A).withAlpha(31),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 16,
                          color: const Color(0xFFC8556A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEEE0F0),
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _expanded ? 0 : -0.25,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: Color(0xFF9A8A9E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizeTransition(
                sizeFactor: _expandAnim,
                child: Column(
                  children: [
                    const Divider(
                      height: 1,
                      color: Color(0x1AFFFFFF),
                      thickness: 1,
                    ),
                    ...widget.fields.asMap().entries.map((entry) {
                      final i = entry.key;
                      final field = entry.value;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 130,
                                  child: Text(
                                    field.label,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12,
                                      color: Color(0xFF9A8A9E),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    field.value,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFEEE0F0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (i < widget.fields.length - 1)
                            const Divider(
                              height: 1,
                              color: Color(0x0AFFFFFF),
                              thickness: 1,
                              indent: 14,
                              endIndent: 14,
                            ),
                        ],
                      );
                    }),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
