import 'package:flutter/material.dart';
import '../models/analysis.dart';

class AnalysisReportPage extends StatelessWidget {
  final AnalysisResponse report;

  const AnalysisReportPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    // 动态计算表格可用宽度，确保填满屏幕不溢出
    final screenWidth = MediaQuery.of(context).size.width;
    // 扣除页面的 Padding(32) + 表格 Margin(24) + 两列间的 Spacing(32) = 88
    final availableWidth = screenWidth - 88;
    final tableWidth = availableWidth > 0 ? availableWidth : 300.0; // 防护极端小屏幕
    
    final col1Width = tableWidth * 0.42; // 成分名占 42%
    final col2Width = tableWidth * 0.38; // 功能占 38%
    final col3Width = tableWidth * 0.20; // 来源占 20%

    final summaryParams = {
      'Natural': report.summary.isNatural,
      'Vegan': report.summary.isVegan,
      'Fragrance Free': report.summary.isFragranceFree,
      'Paraben Free': report.summary.isParabenFree,
      'Silicone Free': report.summary.isSiliconeFree,
      'Sulphate Free': report.summary.isSulphateFree,
      'Gluten Free': report.summary.isGlutenFree,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ingredient Analysis Report", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1D0CC2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 第一部分：汇总列表 (ListView 风格) ---
            const Text("Product Safety Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              elevation: 3,
              child: Column(
                children: summaryParams.entries.map((entry) {
                  return ListTile(
                    leading: Icon(
                      entry.value ? Icons.check_circle : Icons.cancel,
                      color: entry.value ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 25),

            // --- 第二部分：详细表格 (DataTable) ---
            const Text("Ingredient Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16, // 大幅缩小列间距 (默认56)
                horizontalMargin: 12, // 缩小表格左右边缘的空白
                dataRowMaxHeight: double.infinity, // 允许行高根据内容自动无限制拉伸
                dataRowMinHeight: 60, // 设置最小行高
                headingRowColor: WidgetStateProperty.all(const Color(0xFFE1F5FE)), // Baby blue color
                columns: const [
                  DataColumn(label: Text('Ingredients')),
                  DataColumn(label: Text('Function')),
                  DataColumn(label: Text('Origin')),
                ],
                rows: report.ingredientsReport.map((item) {
                  return DataRow(cells: [
                    DataCell(
                      Container(
                        width: col1Width,
                        padding: const EdgeInsets.symmetric(vertical: 12), // 增加上下边距避免拥挤
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.inciName, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.matchedType, 
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        width: col2Width,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          item.ingFunction, 
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        width: col3Width,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          item.ingOrigin, 
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}