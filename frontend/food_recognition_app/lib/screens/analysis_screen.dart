import 'package:flutter/material.dart';
import '../services/history_service.dart';

enum AnalysisPeriod { today, sevenDays, thirtyDays }

class AnalysisScreen extends StatefulWidget {
  final VoidCallback? onScanNow;

  const AnalysisScreen({super.key, this.onScanNow});

  @override
  State<AnalysisScreen> createState() => AnalysisScreenState();
}

class AnalysisScreenState extends State<AnalysisScreen> {
  List<ScanHistoryItem> _allItems = [];
  bool _isLoading = true;
  AnalysisPeriod _selectedPeriod = AnalysisPeriod.sevenDays;

  @override
  void initState() {
    super.initState();
    refreshAnalysis();
  }

  Future<void> refreshAnalysis() async {
    setState(() => _isLoading = true);
    final history = await HistoryService.getHistory();
    if (mounted) {
      setState(() {
        _allItems = history;
        _isLoading = false;
      });
    }
  }

  List<ScanHistoryItem> get _periodItems {
    final now = DateTime.now();
    if (_selectedPeriod == AnalysisPeriod.today) {
      return _allItems.where((i) =>
          i.scannedAt.year == now.year &&
          i.scannedAt.month == now.month &&
          i.scannedAt.day == now.day).toList();
    } else if (_selectedPeriod == AnalysisPeriod.sevenDays) {
      final start = now.subtract(const Duration(days: 7));
      return _allItems.where((i) => i.scannedAt.isAfter(start)).toList();
    } else {
      final start = now.subtract(const Duration(days: 30));
      return _allItems.where((i) => i.scannedAt.isAfter(start)).toList();
    }
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPeriodTab('Today', AnalysisPeriod.today),
          _buildPeriodTab('7 Days', AnalysisPeriod.sevenDays),
          _buildPeriodTab('30 Days', AnalysisPeriod.thirtyDays),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String label, AnalysisPeriod period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bar_chart_rounded, size: 54, color: Color(0xFF2563EB)),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Nutrition Data to Analyze',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scan meals to view weekly calorie trends, macronutrient ratios, and your most frequent dishes.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: widget.onScanNow,
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: const Text('Scan a Meal', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyBarChart(List<ScanHistoryItem> items) {
    // Generate data for past 7 days
    final now = DateTime.now();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<Map<String, dynamic>> daysData = [];

    double maxCal = 1.0;
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayItems = items.where((item) =>
          item.scannedAt.year == day.year &&
          item.scannedAt.month == day.month &&
          item.scannedAt.day == day.day);
      final total = dayItems.fold<double>(0, (sum, item) => sum + item.calories);
      if (total > maxCal) maxCal = total;
      final weekdayIndex = day.weekday - 1; // 0=Mon, 6=Sun
      daysData.add({
        'name': dayNames[weekdayIndex],
        'calories': total,
        'isToday': i == 0,
      });
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF2563EB)),
                  SizedBox(width: 8),
                  Text(
                    'Daily Calorie Intake (Est.)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Past 7 Days', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: daysData.map((d) {
              final double cal = d['calories'];
              final bool isToday = d['isToday'];
              final double heightFactor = (cal / maxCal).clamp(0.08, 1.0);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cal > 0)
                    Text(
                      '${cal.toInt()}',
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    )
                  else
                    const SizedBox(height: 12),
                  const SizedBox(height: 6),
                  Container(
                    width: 22,
                    height: 110 * heightFactor,
                    decoration: BoxDecoration(
                      color: cal == 0
                          ? const Color(0xFFF1F5F9)
                          : (isToday ? const Color(0xFF2563EB) : const Color(0xFF10B981)),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: cal > 0
                          ? [
                              BoxShadow(
                                color: (isToday ? const Color(0xFF2563EB) : const Color(0xFF10B981)).withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    d['name'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      color: isToday ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroDistributionCard(double totalProtein, double totalCarbs, double totalFat) {
    final double totalMacroGrams = totalProtein + totalCarbs + totalFat;
    final double pPercent = totalMacroGrams > 0 ? (totalProtein / totalMacroGrams) * 100 : 0.0;
    final double cPercent = totalMacroGrams > 0 ? (totalCarbs / totalMacroGrams) * 100 : 0.0;
    final double fPercent = totalMacroGrams > 0 ? (totalFat / totalMacroGrams) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Macronutrient Distribution',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 16),
          // Multi-color segmented progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 14,
              child: totalMacroGrams == 0
                  ? Container(color: const Color(0xFFF1F5F9))
                  : Row(
                      children: [
                        if (cPercent > 0)
                          Expanded(
                            flex: (cPercent * 10).toInt(),
                            child: Container(color: const Color(0xFFF59E0B)),
                          ),
                        if (pPercent > 0)
                          Expanded(
                            flex: (pPercent * 10).toInt(),
                            child: Container(color: const Color(0xFF2563EB)),
                          ),
                        if (fPercent > 0)
                          Expanded(
                            flex: (fPercent * 10).toInt(),
                            child: Container(color: const Color(0xFFEC4899)),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroStat('Carbs', '${cPercent.toStringAsFixed(1)}%', '${totalCarbs.toStringAsFixed(1)}g', const Color(0xFFF59E0B)),
              _buildMacroStat('Protein', '${pPercent.toStringAsFixed(1)}%', '${totalProtein.toStringAsFixed(1)}g', const Color(0xFF2563EB)),
              _buildMacroStat('Fat', '${fPercent.toStringAsFixed(1)}%', '${totalFat.toStringAsFixed(1)}g', const Color(0xFFEC4899)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroStat(String label, String percent, String grams, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(percent, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(grams, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildTopFoodsCard(List<ScanHistoryItem> items) {
    final Map<String, int> counts = {};
    for (var i in items) {
      counts[i.foodName] = (counts[i.foodName] ?? 0) + 1;
    }
    final sortedFoods = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topThree = sortedFoods.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Most Frequently Scanned Foods',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 14),
          if (topThree.isEmpty)
            const Text('No meal scans recorded yet.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B)))
          else
            ...topThree.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final dish = entry.value.key;
              final count = entry.value.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: rank == 1
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: rank == 1 ? const Color(0xFFD97706) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dish,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1E293B)),
                      ),
                    ),
                    Text(
                      '$count ${count == 1 ? "time" : "times"}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2563EB)),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = _periodItems;
    final totalCalories = items.fold<double>(0, (sum, i) => sum + i.calories);
    final totalProtein = items.fold<double>(0, (sum, i) => sum + i.protein);
    final totalCarbs = items.fold<double>(0, (sum, i) => sum + i.carbs);
    final totalFat = items.fold<double>(0, (sum, i) => sum + i.fat);
    final avgCal = items.isNotEmpty ? totalCalories / items.length : 0.0;

    return RefreshIndicator(
      onRefresh: refreshAnalysis,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 20),

          if (items.isEmpty)
            _buildEmptyState()
          else ...[
            // Aggregate Hero Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Energy Consumed (Est.)',
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${items.length} Scans', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        totalCalories.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 8),
                      const Text('kcal', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Average per meal scan: ${avgCal.toStringAsFixed(1)} kcal',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bar chart of daily calorie intake
            _buildDailyBarChart(items),
            const SizedBox(height: 20),

            // Macronutrient distribution chart
            _buildMacroDistributionCard(totalProtein, totalCarbs, totalFat),
            const SizedBox(height: 20),

            // Top scanned dishes
            _buildTopFoodsCard(items),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
