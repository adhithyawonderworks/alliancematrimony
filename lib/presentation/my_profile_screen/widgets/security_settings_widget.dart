import 'package:flutter/material.dart';

import '../../../services/security_service.dart';
import '../../../services/supabase_service.dart';

const _kBg = Color(0xFF1E1520);
const _kAccent = Color(0xFFC8556A);
const _kText = Color(0xFFEEE0F0);
const _kMuted = Color(0xFF9A8A9E);

InputDecoration _pinDecoration(String hint) => InputDecoration(
  counterText: '',
  hintText: hint,
  hintStyle: const TextStyle(color: _kMuted),
  filled: true,
  fillColor: const Color(0xFF2A1E2E),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
);

TextStyle get _pinStyle => const TextStyle(
  fontFamily: 'Plus Jakarta Sans',
  fontSize: 20,
  letterSpacing: 8,
  color: _kText,
  fontWeight: FontWeight.w700,
);

/// Opens the "Security Settings" sheet where the user sets/changes their
/// 4-digit passcode and toggles fingerprint login for High Security options.
Future<void> showSecuritySettingsSheet(BuildContext context) async {
  var hasPasscode = await SecurityService.instance.hasPasscode();
  final biometricAvailable = await SecurityService.instance
      .canCheckBiometrics();
  var biometricEnabled = await SecurityService.instance.isBiometricEnabled();
  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: _kBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Security Settings',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasPasscode
                      ? 'Your 4-digit passcode protects High Security options.'
                      : 'Set a 4-digit passcode to protect High Security options such as account deletion.',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    color: _kMuted,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final changed = await _promptSetPasscode(context);
                      if (changed) {
                        setSheetState(() => hasPasscode = true);
                      }
                    },
                    icon: const Icon(Icons.pin_outlined, color: _kAccent),
                    label: Text(
                      hasPasscode ? 'Change passcode' : 'Set 4-digit passcode',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kText,
                      side: const BorderSide(color: _kAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (biometricAvailable)
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: biometricEnabled,
                    activeColor: _kAccent,
                    onChanged: (value) async {
                      if (value && !(await SecurityService.instance.hasPasscode())) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Set a passcode first, then enable fingerprint login.',
                            ),
                          ),
                        );
                        return;
                      }
                      await SecurityService.instance.setBiometricEnabled(value);
                      await SupabaseService.instance.updateSecuritySettings(
                        biometricEnabled: value,
                      );
                      setSheetState(() => biometricEnabled = value);
                    },
                    title: const Text(
                      'Fingerprint login',
                      style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: _kText),
                    ),
                    subtitle: const Text(
                      'Use your fingerprint instead of the passcode',
                      style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: _kMuted),
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Done',
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
}

Future<bool> _promptSetPasscode(BuildContext context) async {
  final passcodeController = TextEditingController();
  final confirmController = TextEditingController();
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: _kBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Set passcode', style: TextStyle(color: _kText)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: passcodeController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            style: _pinStyle,
            textAlign: TextAlign.center,
            decoration: _pinDecoration('4-digit passcode'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: confirmController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            style: _pinStyle,
            textAlign: TextAlign.center,
            decoration: _pinDecoration('Confirm passcode'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel', style: TextStyle(color: _kMuted)),
        ),
        TextButton(
          onPressed: () async {
            final code = passcodeController.text.trim();
            if (code.length != 4 || int.tryParse(code) == null) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(content: Text('Enter exactly 4 digits.')),
              );
              return;
            }
            if (code != confirmController.text.trim()) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(content: Text('Passcodes do not match.')),
              );
              return;
            }
            final hash = await SecurityService.instance.setPasscode(code);
            await SupabaseService.instance.updateSecuritySettings(
              passcodeHash: hash,
            );
            if (dialogContext.mounted) Navigator.pop(dialogContext, true);
          },
          child: const Text('Save', style: TextStyle(color: _kAccent)),
        ),
      ],
    ),
  );
  passcodeController.dispose();
  confirmController.dispose();
  if (result == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Passcode saved.')),
    );
  }
  return result ?? false;
}

/// Gates access to High Security options: tries fingerprint first (if
/// enabled), otherwise prompts for the 4-digit passcode. Returns true only
/// once the user is authenticated.
Future<bool> requestHighSecurityUnlock(BuildContext context) async {
  final hasPasscode = await SecurityService.instance.hasPasscode();
  if (!hasPasscode) {
    if (!context.mounted) return false;
    final setNow = await _promptSetPasscode(context);
    return setNow;
  }

  final biometricEnabled = await SecurityService.instance.isBiometricEnabled();
  if (biometricEnabled) {
    final ok = await SecurityService.instance.authenticateWithBiometrics();
    if (ok) return true;
    // Fall through to passcode entry if biometric fails/cancelled.
  }

  if (!context.mounted) return false;
  final passcodeController = TextEditingController();
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: _kBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Enter passcode', style: TextStyle(color: _kText)),
      content: TextField(
        controller: passcodeController,
        keyboardType: TextInputType.number,
        obscureText: true,
        maxLength: 4,
        autofocus: true,
        style: _pinStyle,
        textAlign: TextAlign.center,
        decoration: _pinDecoration('4-digit passcode'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel', style: TextStyle(color: _kMuted)),
        ),
        TextButton(
          onPressed: () async {
            final valid = await SecurityService.instance.verifyPasscode(
              passcodeController.text.trim(),
            );
            if (!dialogContext.mounted) return;
            if (!valid) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(content: Text('Incorrect passcode.')),
              );
              return;
            }
            Navigator.pop(dialogContext, true);
          },
          child: const Text('Unlock', style: TextStyle(color: _kAccent)),
        ),
      ],
    ),
  );
  passcodeController.dispose();
  return result ?? false;
}
