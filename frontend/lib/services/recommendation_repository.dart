import '../models/recommendation_model.dart';

/// Abstract contract for recommendation repository.
/// Allows swapping MockRecommendationRepository with ApiRecommendationRepository
/// without any UI redesign.
abstract class RecommendationRepository {
  Future<RecommendationResponse> getRecommendation({Map<String, dynamic>? inputs});
}

/// Mock implementation providing deterministic sample data for UI development.
class MockRecommendationRepository implements RecommendationRepository {
  final Duration delay;

  const MockRecommendationRepository({this.delay = Duration.zero});

  @override
  Future<RecommendationResponse> getRecommendation({Map<String, dynamic>? inputs}) async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    return RecommendationResponse.mockSample;
  }
}
