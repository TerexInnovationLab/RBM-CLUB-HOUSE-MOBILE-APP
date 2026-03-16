import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/virtual_card_model.dart';

/// Card repository.
class CardRepository {
  /// Creates a card repository.
  const CardRepository(this._api);

  final ApiService _api;

  /// Fetches virtual card.
  Future<VirtualCardModel> fetchVirtualCard({required AuthState auth}) async {
    if (_api.dio.options.baseUrl.isEmpty) {
      return VirtualCardModel(
        cardId: 'card_1',
        cardholderName: auth.staffProfile?.fullName ?? 'Staff Member',
        employeeNumber: auth.staffProfile?.employeeNumber ?? 'EMP-00000',
        qrPayload: 'RBM|${auth.staffProfile?.employeeNumber ?? 'EMP-00000'}|card_1',
      );
    }
    final resp = await _api.dio.get<Map<String, dynamic>>(ApiEndpoints.virtualCard);
    return VirtualCardModel.fromJson(resp.data ?? const {});
  }
}

