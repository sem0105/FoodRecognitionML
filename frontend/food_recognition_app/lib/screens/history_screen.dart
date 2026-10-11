import 'dart:io';
import 'package:flutter/material.dart';
import '../services/history_service.dart';
import 'history_detail_screen.dart';

enum HistoryFilter { today, week, all }

class HistoryScreen extends StatefulWidget {
  final VoidCallback? onScanNow;

  const HistoryScreen({super.key, this.onScanNow});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  List<ScanHistoryItem> _allItems = [];
  bool _isLoading = true;
  HistoryFilter _selectedFilter = HistoryFilter.all;

  @override
  void initState() {
    super.initState();
    refreshHistory();
  }

  Future<void> refreshHistory() async {
    setState(() => _isLoading = true);
    final history = await HistoryService.getHistory();
    if (mounted) {
      setState(() {
        _allItems = history;
        _isLoading = false;
      });
    }
  }

  List<ScanHistoryItem> get _filteredItems {
    final now = DateTime.now();
    if (_selectedFilter == HistoryFilter.today) {
      return _allItems.where((i) =>
          i.scannedAt.year == now.year &&
          i.scannedAt.month == now.month &&
          i.scannedAt.day == now.day).toList();
    } else if (_selectedFilter == HistoryFilter.week) {
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      return _allItems.where((i) => i.scannedAt.isAfter(sevenDaysAgo)).toList();
    }
    return _allItems;
  }

  Future<void> _deleteItem(ScanHistoryItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Entry'),
        content: Text('Delete ${item.foodName} from your meal history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await HistoryService.deleteHistoryItem(item.id);
      await refreshHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed ${item.foodName} from history'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.no_meals_rounded,
                size: 64,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _selectedFilter == HistoryFilter.all
                  ? 'No Meal Scans Yet'
                  : 'No Scans in Selected Period',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your recognized meals and calculated calories, carbs, protein, and fats will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: widget.onScanNow,
              icon: const Icon(Icons.camera_alt_rounded, size: 20),
              label: const Text('Scan Dish Now', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(ScanHistoryItem item) {
    if (item.localImagePath != null) {
      final file = File(item.localImagePath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            file,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        );
      }
    }
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.restaurant_rounded, color: Color(0xFF94A3B8), size: 30),
    );
  }

  Widget _buildFilterChip(String label, HistoryFilter filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _filteredItems;

    return RefreshIndicator(
      onRefresh: refreshHistory,
      child: Column(
        children: [
          // Filter Tabs (Today, This week, All)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            color: Colors.white,
            child: Row(
              children: [
                _buildFilterChip('All', HistoryFilter.all),
                const SizedBox(width: 8),
                _buildFilterChip('Today', HistoryFilter.today),
                const SizedBox(width: 8),
                _buildFilterChip('This week', HistoryFilter.week),
                const Spacer(),
                Text(
                  '${filtered.length} items',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Main list or empty view
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final dateStr =
                          '${item.scannedAt.day}/${item.scannedAt.month} • ${item.scannedAt.hour.toString().padLeft(2, '0')}:${item.scannedAt.minute.toString().padLeft(2, '0')}';

                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.delete_rounded, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              title: const Text('Delete Entry'),
                              content: Text('Delete ${item.foodName} from history?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEF4444),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) async {
                          await HistoryService.deleteHistoryItem(item.id);
                          _allItems.removeWhere((e) => e.id == item.id);
                          setState(() {});
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () async {
                              final changed = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HistoryDetailScreen(item: item),
                                ),
                              );
                              if (changed == true) {
                                await refreshHistory();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  _buildThumbnail(item),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.foodName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1E293B),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              '${item.calories.toStringAsFixed(0)} Cal >',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF10B981), // Green calorie badge
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              dateStr,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF94A3B8),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${item.portionGrams.toInt()}g',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _buildMacroPill('P: ${item.protein.toStringAsFixed(1)}g', const Color(0xFF2563EB)),
                                            const SizedBox(width: 6),
                                            _buildMacroPill('C: ${item.carbs.toStringAsFixed(1)}g', const Color(0xFFD97706)),
                                            const SizedBox(width: 6),
                                            _buildMacroPill('F: ${item.fat.toStringAsFixed(1)}g', const Color(0xFFDB2777)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded,
                                        color: Color(0xFFCBD5E1), size: 20),
                                    onPressed: () => _deleteItem(item),
                                  ),
                                ],
                              ),
                            ),
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

  Widget _buildMacroPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
