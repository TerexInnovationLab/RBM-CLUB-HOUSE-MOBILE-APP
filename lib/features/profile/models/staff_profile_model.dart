/// Staff profile as provided by the backend (HR-registered).
class StaffProfileModel {
  /// Creates a staff profile.
  const StaffProfileModel({
    required this.id,
    required this.employeeNumber,
    required this.fullName,
    required this.department,
    required this.grade,
    required this.email,
    required this.phoneMasked,
    required this.status,
  });

  /// Backend identifier.
  final String id;

  /// Employee number (e.g., EMP-00123).
  final String employeeNumber;

  /// Full name.
  final String fullName;

  /// Department.
  final String department;

  /// Grade (e.g., G3).
  final String grade;

  /// Email.
  final String email;

  /// Masked phone number (backend-provided).
  final String phoneMasked;

  /// Employment status.
  final String status;

  /// Parses JSON.
  factory StaffProfileModel.fromJson(Map<String, dynamic> json) {
    return StaffProfileModel(
      id: (json['id'] ?? '').toString(),
      employeeNumber: (json['employeeNumber'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      department: (json['department'] ?? '').toString(),
      grade: (json['grade'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneMasked: (json['phoneMasked'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }

  /// Serializes JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeNumber': employeeNumber,
        'fullName': fullName,
        'department': department,
        'grade': grade,
        'email': email,
        'phoneMasked': phoneMasked,
        'status': status,
      };
}

