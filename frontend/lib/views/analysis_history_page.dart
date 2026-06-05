import 'dart:convert';
import 'package:flutter/material.dart';
import '../databases/analysis_cache_db.dart';
import '../models/analysis.dart';
import 'analysis_report.dart';

class AnalysisHistoryPage extends StatefulWidget {
  const AnalysisHistoryPage({super.key});

  @override
  State<AnalysisHistoryPage> createState() => _AnalysisHistoryPageState();
}

class _AnalysisHistoryPageState extends State<AnalysisHistoryPage> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await AnalysisCacheDb.instance.getAllCache();
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  Future<void> _deleteRecord(String productId) async {
    await AnalysisCacheDb.instance.deleteCache(productId);
    _loadHistory();
  }

  Future<void> _clearAllHistory() async {
    await AnalysisCacheDb.instance.clearAll();
    _loadHistory();
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text('This will permanently delete all your ingredient analysis reports. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All history cleared')),
              );
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthStr = months[date.month - 1];
    final dayStr = date.day.toString().padLeft(2, '0');
    
    int hour = date.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = date.minute.toString().padLeft(2, '0');
    
    return '$monthStr $dayStr, ${date.year} - $hourStr:$minuteStr $period';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header Section to match Home style
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1D0CC2),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Analysis History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_history.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep, color: Colors.white, size: 28),
                    tooltip: 'Clear All',
                    onPressed: () => _showClearAllDialog(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
                    ? const Center(
                        child: Text(
                          'No analysis history yet.\nAnalyze some products to see them here!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final item = _history[index];
                          final productId = item['product_id'] as String;
                          final productName = item['product_name'] as String;
                          final lastViewed = item['last_viewed_at'] as int;

                          return Dismissible(
                            key: Key(productId),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              _deleteRecord(productId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$productName removed from history'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFE1F5FE),
                                  child: Icon(Icons.science, color: Color(0xFF1D0CC2)),
                                ),
                                title: Text(
                                  productName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Last viewed: ${_formatDate(lastViewed)}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                                onTap: () {
                                  // Decode JSON and navigate directly
                                  final analysisDataStr = item['analysis_data'] as String;
                                  final jsonData = jsonDecode(analysisDataStr);
                                  final report = AnalysisResponse.fromJson(jsonData);

                                  // Update last viewed time in DB asynchronously
                                  AnalysisCacheDb.instance.getCache(productId).then((_) {
                                    if (mounted) _loadHistory(); // refresh list in background
                                  });

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AnalysisReportPage(report: report),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
