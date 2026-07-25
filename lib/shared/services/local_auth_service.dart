import 'package:local_auth/local_auth.dart';

/// Wraps device-level authentication (Face ID / fingerprint / PIN).
/// Used to gate re-entry for an already-signed-in user without making
/// them go through full email/password login every time — "sign in
/// once," then a quick device unlock on return visits.
class LocalAuthService {
  LocalAuthService._();
  static final LocalAuthService instance = LocalAuthService._();

  final LocalAuthentication _auth = LocalAuthentication();

  /// True only if the device both supports local auth AND actually has
  /// something enrolled (fingerprint/face/PIN). Checking only device
  /// support isn't enough — a device can have the hardware but nothing
  /// set up, which would make every authenticate() call fail instead
  /// of the feature just not being offered at all.
  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Prompts Face ID / fingerprint / device PIN or pattern. Returns
  /// false for any failure, cancellation, or error — never throws —
  /// so callers can treat "false" as one uniform "didn't unlock"
  /// signal without needing their own try/catch.
  Future<bool> authenticate({String reason = "Unlock Magic Farm"}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          // Allows device PIN/pattern as a fallback, not just
          // fingerprint/face — matters since not everyone's device
          // has biometrics enrolled, but most have a PIN.
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}