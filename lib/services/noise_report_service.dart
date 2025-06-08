import '../models/models.dart';
import 'api_service.dart';

class NoiseReportService extends ApiService {
  NoiseReportService({super.client});

  Future<NoiseReport> createReport(NoiseReport report) async {
    return post(
      '/noise_reports',
      report.toJson(),
      (json) => NoiseReport.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<List<NoiseReport>> fetchReports() async {
    return get('/noise_reports', (json) {
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => NoiseReport.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<NoiseReport> updateReport(NoiseReport report) async {
    if (report.id == null) throw ArgumentError('id required');
    return put(
      '/noise_reports/${report.id}',
      report.toJson(),
      (json) => NoiseReport.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<void> deleteReport(String id) async {
    await delete('/noise_reports/$id', (_) => null);
  }
}
