import 'package:flutter/material.dart';

import '../databases/report_db.dart';
import '../databases/user_db.dart';
import '../models/reports.dart';
import 'report_form.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<Report> _reports = <Report>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refreshReports();
  }

  Future<void> _refreshReports() async {
    setState(() {
      _loading = true;
    });

    final List<Report> results = await ReportDatabase.refreshReports();
    if (!mounted) return;

    setState(() {
      _reports = results;
      _loading = false;
    });
  }

  Future<void> _openForm({Report? report}) async {
    final bool? changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => ReportFormPage(report: report),
      ),
    );

    if (changed == true) {
      await _refreshReports();
    }
  }

  Future<void> _deleteReport(Report report) async {
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Report'),
          content: const Text('Are you sure you want to delete this report?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop('cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('delete'),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result != 'delete') return;

    await ReportDatabase.deleteReport(report.id!);
    if (!mounted) return;
    await _refreshReports();
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (UserDatabase.currentUserId == null) {
      return const Center(
        child: Text('Log in to create and view your reports.'),
      );
    }

    if (_reports.isEmpty) {
      return const Center(
        child: Text('No reports yet. Tap + to add one.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: _reports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        final Report report = _reports[index];
        return _ReportCard(
          report: report,
          onEdit: () => _openForm(report: report),
          onDelete: () => _deleteReport(report),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Report Page',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D0CC2),
                ),
              ),
            ),
            Expanded(child: _buildList()),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 8),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF1D0CC2),
          onPressed: () => _openForm(),
          child: const Icon(
            Icons.add,
            size: 28,
            color: Colors.white, // <<< Change applied here
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.onEdit,
    required this.onDelete,
  });

  final Report report;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE3F6FF),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  report.productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.problem,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, color: Color(0xFF1D0CC2)),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, color: Color(0xFF1D0CC2)),
          ),
        ],
      ),
    );
  }
}