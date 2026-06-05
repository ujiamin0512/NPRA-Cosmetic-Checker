import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/reports.dart';
import 'user_db.dart';
import '../services/api_service.dart';

class ReportDatabase {
  ReportDatabase._();

  static Future<String?> makeReport(Report report) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/reports/make');
    try {
      final Map<String, dynamic> data = report.toMap();
      data.remove(Report.colId); // Ensure ID is not inserted so Supabase auto-generates it

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'report_data': data,
        }),
      );

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (resData['status'] == 'success') {
          return null;
        } else {
          return resData['message'] ?? 'Failed to make report';
        }
      } else {
        return 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      print('Error making report: $e');
      return e.toString();
    }
  }

  static Future<List<Report>> refreshReports() async {
    final String? userId = UserDatabase.currentUserId;
    if (userId == null) {
      return <Report>[];
    }

    final url = Uri.parse('${ApiService.baseUrl}/api/reports/fetch');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (resData['status'] == 'success' && resData['reports'] != null) {
          final List<dynamic> reportsList = resData['reports'];
          return reportsList
              .map((item) => Report.fromMap(item as Map<String, dynamic>))
              .toList();
        }
      }
      return <Report>[];
    } catch (e) {
      print('Error fetching reports: $e');
      return <Report>[];
    }
  }

  static Future<String?> editReport(Report report) async {
    if (report.id == null) {
      return 'Report ID is null';
    }

    final url = Uri.parse('${ApiService.baseUrl}/api/reports/edit');
    try {
      final Map<String, dynamic> data = report.toMap();
      data.remove(Report.colId); // Don't update the primary key

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'report_id': report.id,
          'report_data': data,
        }),
      );

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (resData['status'] == 'success') {
          return null;
        } else {
          return resData['message'] ?? 'Failed to edit report';
        }
      } else {
        return 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      print('Error editing report: $e');
      return e.toString();
    }
  }

  static Future<int> deleteReport(int id) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/reports/delete');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'report_id': id,
        }),
      );

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (resData['status'] == 'success') {
          return 1;
        }
      }
      return 0;
    } catch (e) {
      print('Error deleting report: $e');
      return 0;
    }
  }
}