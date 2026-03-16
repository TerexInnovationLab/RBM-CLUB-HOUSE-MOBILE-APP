/// Auth activation request model.
class AuthActivateRequestModel {
  /// Creates an activation request.
  const AuthActivateRequestModel({
    required this.employeeNumber,
    required this.temporaryPin,
    this.newPin,
  });

  /// Employee number.
  final String employeeNumber;

  /// Temporary PIN.
  final String temporaryPin;

  /// New PIN (step 2 only).
  final String? newPin;

  /// Serializes JSON.
  Map<String, dynamic> toJson() => {
        'employeeNumber': employeeNumber,
        'temporaryPin': temporaryPin,
        if (newPin != null) 'newPin': newPin,
      };
}

/// Login request model.
class AuthLoginRequestModel {
  /// Creates a login request.
  const AuthLoginRequestModel({
    required this.employeeNumber,
    required this.pin,
    this.biometric,
  });

  /// Employee number.
  final String employeeNumber;

  /// PIN.
  final String pin;

  /// Biometric flag.
  final bool? biometric;

  /// Serializes JSON.
  Map<String, dynamic> toJson() => {
        'employeeNumber': employeeNumber,
        'pin': pin,
        if (biometric != null) 'biometric': biometric,
      };
}

