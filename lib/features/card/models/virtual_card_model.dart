/// Virtual card model.
class VirtualCardModel {
  /// Creates a virtual card.
  const VirtualCardModel({
    required this.cardId,
    required this.cardholderName,
    required this.employeeNumber,
    required this.qrPayload,
  });

  /// Card id.
  final String cardId;

  /// Cardholder name.
  final String cardholderName;

  /// Employee number.
  final String employeeNumber;

  /// QR payload string.
  final String qrPayload;

  /// Parses JSON.
  factory VirtualCardModel.fromJson(Map<String, dynamic> json) {
    return VirtualCardModel(
      cardId: (json['cardId'] ?? json['id'] ?? '').toString(),
      cardholderName: (json['cardholderName'] ?? '').toString(),
      employeeNumber: (json['employeeNumber'] ?? '').toString(),
      qrPayload: (json['qrPayload'] ?? '').toString(),
    );
  }
}

