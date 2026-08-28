import '../../data/models/ai_plan.dart';

abstract class AiPlannerRepository {
  Future<List<AiDayPlan>> generatePlan({
    required String scheduleText,
    required DateTime monthStart,
    required DateTime monthEnd,
    List<int>? pdfBytes,
  });

  Future<int> importDayPlans(List<AiDayPlan> days);
}
