import 'dart:ui';
import 'package:flutter/material.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showLogo;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showLogo = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 60 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: const Color(0xFF120D16).withAlpha(179),
            border: const Border(
              bottom: BorderSide(color: Color(0x1AFFFFFF), width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 8)],
                if (showLogo) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC8556A), Color(0xFFE8A87C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: showLogo
                      ? RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Alliance Matrimony',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFEEE0F0),
                                ),
                              ),
                              TextSpan(
                                text: ' Matrimony',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFC8556A),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEEE0F0),
                          ),
                        ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
