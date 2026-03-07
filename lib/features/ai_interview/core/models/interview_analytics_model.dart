class AnalyticsAverages {
  final int overall;
  final int technical;
  final int communication;

  const AnalyticsAverages({
    required this.overall,
    required this.technical,
    required this.communication,
  });

  factory AnalyticsAverages.fromJson(Map<String, dynamic> json) {
    return AnalyticsAverages(
      overall: json['overall'] as int? ?? 0,
      technical: json['technical'] as int? ?? 0,
      communication: json['communication'] as int? ?? 0,
    );
  }
}

class ChartDataPoint {
  final String name;
  final String date;
  final int overall;
  final int technical;
  final int communication;

  const ChartDataPoint({
    required this.name,
    required this.date,
    required this.overall,
    required this.technical,
    required this.communication,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      name: json['name'] as String? ?? '',
      date: json['date'] as String? ?? '',
      overall: json['overall'] as int? ?? 0,
      technical: json['technical'] as int? ?? 0,
      communication: json['communication'] as int? ?? 0,
    );
  }
}

/// [name, count] tuple returned by backend
typedef StrengthEntry = (String, int);

class InterviewAnalytics {
  final int totalSessions;
  final AnalyticsAverages averages;
  final int totalTime;
  final List<StrengthEntry> strengthsArr;
  final List<StrengthEntry> improvementsArr;
  final List<ChartDataPoint> chartData;

  const InterviewAnalytics({
    required this.totalSessions,
    required this.averages,
    required this.totalTime,
    required this.strengthsArr,
    required this.improvementsArr,
    required this.chartData,
  });

  factory InterviewAnalytics.fromJson(Map<String, dynamic> json) {
    StrengthEntry parseEntry(dynamic e) {
      final list = e as List<dynamic>;
      return (list[0] as String, list[1] as int);
    }

    return InterviewAnalytics(
      totalSessions: json['totalSessions'] as int? ?? 0,
      averages: AnalyticsAverages.fromJson(
        json['averages'] as Map<String, dynamic>? ?? {},
      ),
      totalTime: json['totalTime'] as int? ?? 0,
      strengthsArr: (json['strengthsArr'] as List<dynamic>? ?? [])
          .map(parseEntry)
          .toList(),
      improvementsArr: (json['improvementsArr'] as List<dynamic>? ?? [])
          .map(parseEntry)
          .toList(),
      chartData: (json['chartData'] as List<dynamic>? ?? [])
          .map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
