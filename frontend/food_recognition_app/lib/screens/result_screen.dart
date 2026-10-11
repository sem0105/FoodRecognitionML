import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/prediction_result.dart';

class ResultScreen extends StatefulWidget {
  final File? imageFile;
  final Uint8List? imageBytes;
  final PredictionResponse result;

  const ResultScreen({
    super.key,
    this.imageFile,
    this.imageBytes,
    required this.result,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late double _portionGrams;

  @override
  void initState() {
    super.initState();
    _portionGrams = widget.result.nutrition?.portionGrams ?? 100.0;
  }

  double get _calculatedCalories {
    final per100g = widget.result.nutrition?.caloriesPer100g ??
        widget.result.nutritionPer100g?.calories ??
        0.0;
    return (per100g * _portionGrams) / 100.0;
  }

  double get _calculatedProtein {
    final per100g = widget.result.nutrition?.proteinPer100g ??
        widget.result.nutritionPer100g?.protein ??
        0.0;
    return (per100g * _portionGrams) / 100.0;
  }

  double get _calculatedCarbs {
    final per100g = widget.result.nutrition?.carbsPer100g ??
        widget.result.nutritionPer100g?.carbs ??
        0.0;
    return (per100g * _portionGrams) / 100.0;
  }

  double get _calculatedFat {
    final per100g = widget.result.nutrition?.fatPer100g ??
        widget.result.nutritionPer100g?.fat ??
        0.0;
    return (per100g * _portionGrams) / 100.0;
  }

  ImageProvider _getImageProvider() {
    if (widget.imageBytes != null && widget.imageBytes!.isNotEmpty) {
      return MemoryImage(widget.imageBytes!);
    }
    if (widget.imageFile != null) {
      if (kIsWeb) {
        return NetworkImage(widget.imageFile!.path);
      } else {
        return FileImage(widget.imageFile!);
      }
    }
    return const AssetImage('assets/placeholder.png');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pred = widget.result.prediction;
    final nut = widget.result.nutrition;

    final foodName = pred?.displayName ?? pred?.food ?? 'Recognized Food';
    final confidence = pred?.confidence ?? 0.0;
    final caloriesPer100g = nut?.caloriesPer100g ?? 0.0;
    final note = nut?.note ?? 'Estimated nutritional values based on average standard recipes.';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Dish Analysis',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Curved Image Preview Header with Floating Title Pill (Matching Reference Image 1 & 3)
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                children: [
                  Container(
                    height: 240,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                      image: DecorationImage(
                        image: _getImageProvider(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Gradient overlay on photo bottom
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.75),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Top Glassmorphism Confidence Badge (Matching Score Badge in Reference Image 1 & 3)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.4),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Match: ${confidence.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Floating Dish Name Tag on Photo (Matching Reference Image 1)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        foodName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Description Header Section
            const Text(
              'Nutritional Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Detailed macro breakdown per serving calculated using AI model & nutritional dataset.',
              style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
            ),
            const SizedBox(height: 18),

            // 4 Macro Pastel Pills Grid (Matching Reference Image 1 & 3)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildMacroPillCard(
                  label: 'Calories',
                  value: '${_calculatedCalories.toStringAsFixed(1)} kcal',
                  color: const Color(0xFFFFF1F2),
                  textColor: const Color(0xFFE11D48), // Coral / Berry accent
                  borderColor: const Color(0xFFFFE4E6),
                  icon: Icons.local_fire_department_rounded,
                ),
                _buildMacroPillCard(
                  label: 'Protein',
                  value: '${_calculatedProtein.toStringAsFixed(1)} g',
                  color: const Color(0xFFEFF6FF),
                  textColor: const Color(0xFF2563EB),
                  borderColor: const Color(0xFFDBEAFE),
                  icon: Icons.fitness_center_rounded,
                ),
                _buildMacroPillCard(
                  label: 'Carbs',
                  value: '${_calculatedCarbs.toStringAsFixed(1)} g',
                  color: const Color(0xFFFEF3C7),
                  textColor: const Color(0xFFD97706),
                  borderColor: const Color(0xFFFDE68A),
                  icon: Icons.grain_rounded,
                ),
                _buildMacroPillCard(
                  label: 'Fat',
                  value: '${_calculatedFat.toStringAsFixed(1)} g',
                  color: const Color(0xFFFDF2F8),
                  textColor: const Color(0xFFDB2777),
                  borderColor: const Color(0xFFFCE7F3),
                  icon: Icons.opacity_rounded,
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Portion Adjuster Slider Card
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Adjust Serving Weight',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_portionGrams.toStringAsFixed(0)} grams',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2563EB),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF2563EB),
                        inactiveTrackColor: const Color(0xFFE2E8F0),
                        thumbColor: const Color(0xFF2563EB),
                        overlayColor: const Color(0xFF2563EB).withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: _portionGrams,
                        min: 25,
                        max: 1000,
                        divisions: 39,
                        label: '${_portionGrams.toStringAsFixed(0)}g',
                        onChanged: (val) {
                          setState(() {
                            _portionGrams = val;
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('25g', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        Text('Per 100g: ${caloriesPer100g.toStringAsFixed(0)} kcal',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                        const Text('1000g', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            note,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF64748B),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Top Matches Probabilities (Matching Reference Image 2 List Style)
            if (pred != null && pred.topPredictions.isNotEmpty) ...[
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Confidence Matches',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...pred.topPredictions.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.food,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    '${item.confidence.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: (item.confidence / 100.0).clamp(0.0, 1.0),
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Scan Another Item Button
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text(
                  'Scan Another Food Item',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroPillCard({
    required String label,
    required String value,
    required Color color,
    required Color textColor,
    required Color borderColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

