import 'package:flutter/material.dart';

class ProfileCompletenessWidget extends StatefulWidget {
  final int percent;

  const ProfileCompletenessWidget({super.key, required this.percent});

  @override
  State<ProfileCompletenessWidget> createState() =>
      _ProfileCompletenessWidgetState();
}

class _ProfileCompletenessWidgetState extends State<ProfileCompletenessWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressAnim = Tween<double>(
      begin: 0,
      end: widget.percent / 100,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1520),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile Completeness',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEEE0F0),
                  ),
                ),
                AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (context, _) => Text(
                    '${(_progressAnim.value * 100).round()}%',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC8556A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _progressAnim,
              builder: (context, _) => ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: _progressAnim.value,
                  minHeight: 6,
                  backgroundColor: const Color(0x1AFFFFFF),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFC8556A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.percent < 100
                  ? 'Complete your profile to get more matches'
                  : 'Your profile is 100% complete!',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                color: Color(0xFF9A8A9E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
