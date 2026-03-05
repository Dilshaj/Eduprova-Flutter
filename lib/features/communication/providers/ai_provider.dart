import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/ai_repository.dart';

final aiProvider = Provider<AiRepository>((ref) {
  return AiRepository.instance;
});
