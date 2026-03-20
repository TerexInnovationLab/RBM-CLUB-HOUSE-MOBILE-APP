/// Input validation helpers.
abstract final class Validators {
  /// Validates an employee number.
  static String? employeeNumber(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return 'Employee number is required.';
    if (trimmed.length < 3) return 'Enter a valid employee number.';
    return null;
  }

  /// Validates a 6-digit PIN.
  static String? pin6(String? value) {
    final v = (value ?? '').trim();
    if (v.length != 6) return 'PIN must be 6 digits.';
    if (!RegExp(r'^[0-9]{6}$').hasMatch(v)) return 'PIN must be numeric.';
    return null;
  }

  /// Validates a 3-digit phone suffix.
  static String? phoneLast3(String? value) {
    final v = (value ?? '').trim();
    if (v.length != 3) return 'Enter the last 3 digits.';
    if (!RegExp(r'^[0-9]{3}$').hasMatch(v)) return 'Digits only.';
    return null;
  }
}
