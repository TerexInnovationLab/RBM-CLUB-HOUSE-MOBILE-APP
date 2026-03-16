import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/card_repository.dart';
import '../models/virtual_card_model.dart';

/// Card repository provider.
final cardRepositoryProvider = Provider<CardRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  return CardRepository(api);
});

/// Virtual card provider.
final virtualCardProvider = FutureProvider<VirtualCardModel>((ref) async {
  final auth = ref.read(authProvider);
  return ref.read(cardRepositoryProvider).fetchVirtualCard(auth: auth);
});

