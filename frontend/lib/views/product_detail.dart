import 'package:flutter/material.dart';

import '../models/products.dart';
import '../services/api_service.dart';
import '../databases/analysis_cache_db.dart';
import '../databases/user_db.dart';
import '../databases/chat_db.dart';
import 'analysis_report.dart';
import 'report_form.dart';
import 'chat_page.dart';
import 'package:uuid/uuid.dart';
import 'login_page.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.product, this.isGuest = false});

  final Product product;
  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D0CC2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          product.product,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            _DetailRow(label: 'Notification No', value: product.notifNo),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Brand',
              value: (product.brand == null || product.brand!.isEmpty)
                  ? 'N/A'
                  : product.brand!,
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Product', value: product.product),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Type',
              value: (product.type == null || product.type!.isEmpty)
                  ? 'N/A'
                  : product.type!,
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Company', value: product.company),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Country',
              value: (product.country == null || product.country!.isEmpty)
                  ? 'N/A'
                  : product.country!,
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(
                    color: Color(0xFF8A8DA4),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      product.status.toLowerCase() == 'notified'
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: product.status.toLowerCase() == 'notified'
                          ? const Color(0xFF33BE66)
                          : const Color(0xFFD42222),
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      product.status,
                      style: TextStyle(
                        color: product.status.toLowerCase() == 'notified'
                            ? const Color(0xFF33BE66)
                            : const Color(0xFFD42222),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (product.status.toLowerCase() == 'notified') ...[
              _DetailRow(
                label: 'Ingredients',
                value: (product.ingredients == null || product.ingredients!.isEmpty)
                    ? 'None'
                    : product.ingredients!,
              ),
              const SizedBox(height: 12),
              _DetailRow(
                label: 'After Use/Targets',
                value: (product.afterUseTargets == null || product.afterUseTargets!.isEmpty)
                    ? 'None'
                    : product.afterUseTargets!,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: isGuest ? Colors.grey : const Color(0xFF1D0CC2), 
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    Icons.report_problem_outlined, 
                    color: isGuest ? Colors.grey : const Color(0xFF1D0CC2),
                  ),
                  label: Text(
                    'Report Product',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isGuest ? Colors.grey : const Color(0xFF1D0CC2),
                    ),
                  ),
                  onPressed: () {
                    if (isGuest) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportFormPage(
                            initialProductName: product.product,
                            initialNotificationNumber: product.notifNo,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isGuest ? Colors.grey : const Color(0xFF26A69A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (isGuest) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    } else {
                      final user = await UserDatabase.getCurrentUser();
                      final skinProfile = _buildSkinProfileText(user?.skinProfile.skinTypes, user?.skinProfile.skinConcerns);

                      final existingSession = await ChatDb.instance.getSessionByProductId(product.notifNo);
                      final sessionId = existingSession?.id ?? const Uuid().v4();

                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            sessionId: sessionId,
                            flowType: 'product',
                            productId: product.notifNo,
                            productName: product.product,
                            ingredients: product.ingredients,
                            skinProfile: skinProfile,
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.smart_toy_outlined, color: Colors.white),
                  label: const Text(
                    'Ask AI Advice',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ] else
                _DetailRow(
                  label: 'Substance Detected',
                  value: product.substanceDetected.isEmpty
                      ? 'None'
                      : product.substanceDetected,
                ),
              if (product.status.toLowerCase() == 'notified' &&
                  product.ingredients != null &&
                  product.ingredients!.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isGuest ? Colors.grey : const Color(0xFF1D0CC2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (isGuest) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      } else {
                        print('🟢 [UI] Button clicked, showing dialog');
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (dialogContext) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        try {
                          print('🟢 [UI] Checking local cache for ${product.notifNo}...');
                          var report = await AnalysisCacheDb.instance.getCache(product.notifNo);

                          if (report != null) {
                            print('🟢 [UI] Found report in local cache!');
                          } else {
                            print('🟢 [UI] Cache miss. Calling ApiService...');
                            report = await ApiService.analyzeIngredients(product.ingredients!);
                            print('🟢 [UI] ApiService returned report successfully!');
                            
                            // Save to local cache
                            await AnalysisCacheDb.instance.upsertCache(
                              product.notifNo,
                              product.product,
                              report,
                            );
                            print('🟢 [UI] Saved report to local cache.');
                          }
                          
                          if (context.mounted) {
                            print('🟢 [UI] context is mounted, popping dialog...');
                            Navigator.of(context, rootNavigator: true).pop(); // Force close dialog on root navigator
                            print('🟢 [UI] pushing AnalysisReportPage...');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AnalysisReportPage(report: report!),
                              ),
                            );
                            print('🟢 [UI] Navigation complete.');
                          } else {
                            print('🔴 [UI] ERROR: context.mounted is false! Navigation aborted.');
                          }
                        } catch (e) {
                          print('🔴 [UI] Caught error in UI: $e');
                          if (context.mounted) {
                            Navigator.of(context, rootNavigator: true).pop(); // Force close dialog on root navigator
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to analyze: $e')),
                            );
                          }
                        }
                      }
                    },
                    child: const Text(
                      'Analyze Ingredients',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _buildSkinProfileText(List<String>? skinTypes, List<String>? skinConcerns) {
  final types = (skinTypes ?? []).where((e) => e.trim().isNotEmpty).join(', ');
  final concerns = (skinConcerns ?? []).where((e) => e.trim().isNotEmpty).join(', ');

  if (types.isEmpty && concerns.isEmpty) {
    return 'No saved skin profile';
  }
  if (concerns.isEmpty) {
    return 'Skin type: $types';
  }
  if (types.isEmpty) {
    return 'Concerns: $concerns';
  }
  return 'Skin type: $types; Concerns: $concerns';
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A8DA4),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF333752),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
