import '../models/models.dart';
import 'api_service.dart';

class SecurityReportService extends ApiService {
  SecurityReportService({super.client});

  Future<SecurityReport> createReport(SecurityReport report) async {
    return post(
      '/security_reports',
      report.toJson(),
      (json) => SecurityReport.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<List<SecurityReport>> fetchReports() async {
    return get('/security_reports', (json) {
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => SecurityReport.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<SecurityReport> updateReport(SecurityReport report) async {
    if (report.id == null) throw ArgumentError('id required');
    return put(
      '/security_reports/${report.id}',
      report.toJson(),
      (json) => SecurityReport.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<void> deleteReport(String id) async {
    await delete('/security_reports/$id', (_) => null);
  }
}
