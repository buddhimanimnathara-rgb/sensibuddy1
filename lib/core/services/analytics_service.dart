class AnalyticsService {

  static int calculatePercentage({
    required int completed,
    required int total,
  }) {

    if (total == 0) return 0;

    return ((completed / total) * 100)
        .round();
  }
}