import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../widgets/food_image_picker.dart';
import '../widgets/loading_view.dart';
import 'analysis_screen.dart';
import 'history_screen.dart';
import 'result_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  XFile? _selectedXFile;
  Uint8List? _selectedBytes;

  final TextEditingController _portionController =
      TextEditingController(text: '100');
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  BackendStatus? _backendStatus;
  int _activeNavIndex = 0;

  final List<double> _portionPresets = [50, 100, 150, 250, 500];
  List<ScanHistoryItem> _todayHistory = [];

  // Keys to trigger child refreshes on tab switch
  final GlobalKey<HistoryScreenState> _historyKey = GlobalKey<HistoryScreenState>();
  final GlobalKey<AnalysisScreenState> _analysisKey = GlobalKey<AnalysisScreenState>();

  @override
  void initState() {
    super.initState();
    _checkBackendStatus();
    _loadTodayHistory();
  }

  @override
  void dispose() {
    _portionController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayHistory() async {
    final list = await HistoryService.getHistory();
    if (mounted) {
      setState(() {
        _todayHistory = list;
      });
    }
  }

  Future<void> _checkBackendStatus() async {
    final status = await ApiService.checkBackendStatus();
    if (mounted) {
      setState(() {
        _backendStatus = status;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedXFile = file;
          _selectedBytes = bytes;
          _selectedImage = File(file.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _selectedXFile = null;
      _selectedBytes = null;
    });
  }

  Future<void> _handleRecognizeFood() async {
    if (_selectedXFile == null && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or capture a food photo first.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    final portionText = _portionController.text.trim();
    final portionWeight = double.tryParse(portionText);

    if (portionWeight == null || portionWeight <= 0 || portionWeight > 5000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid portion weight (1 to 5000 grams).'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await ApiService.predictFoodImage(
      filePath: _selectedImage?.path ?? _selectedXFile?.path ?? '',
      xFile: _selectedXFile,
      portionGrams: portionWeight,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (response.success && response.prediction != null) {
      // 1. Copy image to app-owned persistent storage
      final persistentImagePath = await HistoryService.persistImage(
        originalFile: _selectedImage,
        imageBytes: _selectedBytes,
      );

      // 2. Add history record once upon successful prediction
      final historyEntry = ScanHistoryItem(
        id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
        foodName: response.foodName ?? response.prediction!.displayName,
        scannedAt: DateTime.now(),
        portionGrams: response.portionGrams ?? portionWeight,
        calories: response.calories ?? response.nutrition?.estimatedCalories ?? 0.0,
        protein: response.protein ?? response.nutrition?.estimatedProtein ?? 0.0,
        carbs: response.carbs ?? response.nutrition?.estimatedCarbs ?? 0.0,
        fat: response.fat ?? response.nutrition?.estimatedFat ?? 0.0,
        confidence: response.confidence ?? response.prediction!.confidence,
        localImagePath: persistentImagePath,
        note: response.nutrition?.note,
        dataType: response.nutrition?.dataType ?? response.nutritionPer100g?.dataType,
        sourceUrl: response.nutrition?.sourceUrl ?? response.nutritionPer100g?.sourceUrl,
      );

      await HistoryService.addHistoryItem(historyEntry);
      _loadTodayHistory();
      _historyKey.currentState?.refreshHistory();
      _analysisKey.currentState?.refreshAnalysis();

      // 3. Open ResultScreen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              imageFile: _selectedImage,
              imageBytes: _selectedBytes,
              result: response,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error ?? 'Prediction failed.'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Crisp light background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.blur_on_rounded, color: Color(0xFF2563EB), size: 22),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FoodLens',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'AI Nutrition & Meal Recognition',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Compact Connection Status Indicator (Requirement 1)
          _buildCompactConnectionBadge(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2563EB), size: 20),
            onPressed: () {
              _checkBackendStatus();
              _loadTodayHistory();
            },
            tooltip: 'Refresh Status',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _activeNavIndex,
        children: [
          // Tab 0: Home / Scan Screen
          _buildHomeScanTab(),
          // Tab 1: History Screen
          HistoryScreen(
            key: _historyKey,
            onScanNow: () => setState(() => _activeNavIndex = 0),
          ),
          // Tab 2: Analysis Screen
          AnalysisScreen(
            key: _analysisKey,
            onScanNow: () => setState(() => _activeNavIndex = 0),
          ),
          // Tab 3: Settings Screen
          SettingsScreen(
            onHistoryCleared: () {
              _loadTodayHistory();
              _historyKey.currentState?.refreshHistory();
              _analysisKey.currentState?.refreshAnalysis();
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _activeNavIndex,
          onTap: (idx) {
            setState(() => _activeNavIndex = idx);
            if (idx == 0) _loadTodayHistory();
            if (idx == 1) _historyKey.currentState?.refreshHistory();
            if (idx == 2) _analysisKey.currentState?.refreshAnalysis();
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2563EB), // Classic Blue primary
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          elevation: 0,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Analysis',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeScanTab() {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Nutrition Ring Card (Matching Screenshot 1 & 2)
              _buildNutritionSummaryCard(),
              const SizedBox(height: 18),

              // Section Header
              const Text(
                'Scan Your Dish',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),

              // Scanner Viewfinder Card
              FoodImagePicker(
                selectedImage: _selectedImage,
                imageBytes: _selectedBytes,
                onPickFromGallery: () => _pickImage(ImageSource.gallery),
                onCaptureFromCamera: () => _pickImage(ImageSource.camera),
                onClearImage: _clearImage,
              ),
              const SizedBox(height: 16),

              // Portion Weight Card with Presets
              _buildPortionCard(),
              const SizedBox(height: 20),

              // Recognize Button
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
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleRecognizeFood,
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 22),
                  label: const Text(
                    'Recognize Dish & Calculate Nutrients',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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

        if (_isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.4),
            child: const LoadingView(),
          ),
      ],
    );
  }

  Widget _buildNutritionSummaryCard() {
    final now = DateTime.now();
    final todayScans = _todayHistory.where((i) =>
        i.scannedAt.year == now.year &&
        i.scannedAt.month == now.month &&
        i.scannedAt.day == now.day).toList();

    final calToday = todayScans.fold<double>(0, (sum, i) => sum + i.calories);
    final protToday = todayScans.fold<double>(0, (sum, i) => sum + i.protein);
    final carbToday = todayScans.fold<double>(0, (sum, i) => sum + i.carbs);
    final fatToday = todayScans.fold<double>(0, (sum, i) => sum + i.fat);

    const double goalCalories = 2000.0;
    final double remainingCal = (goalCalories - calToday).clamp(0.0, goalCalories);
    final double eatenRatio = (calToday / goalCalories).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Header with count and shortcut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.local_fire_department_rounded, color: Color(0xFFEF4444), size: 20),
                  SizedBox(width: 6),
                  Text(
                    "Today's Nutrition Intake",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => setState(() => _activeNavIndex = 1),
                child: Text(
                  todayScans.isEmpty ? '0 logged' : '${todayScans.length} meals >',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Ring & Eaten Overview (Matching Screenshot 1 & 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Eaten Calorie Text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Eaten', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        calToday.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('cal', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text('of ${goalCalories.toInt()} goal', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),

              // Center Circular Progress Indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 82,
                    height: 82,
                    child: CircularProgressIndicator(
                      value: eatenRatio,
                      strokeWidth: 8,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        remainingCal.toStringAsFixed(0),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Text(
                        'left',
                        style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // 3 Macronutrient Mini Meters (Matching Screenshot 1 & 2)
          Row(
            children: [
              Expanded(
                child: _buildMacroMiniBar('Protein', protToday, 120.0, const Color(0xFF2563EB)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMacroMiniBar('Carbs', carbToday, 200.0, const Color(0xFFF59E0B)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMacroMiniBar('Fat', fatToday, 65.0, const Color(0xFFEC4899)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroMiniBar(String name, double eaten, double goal, Color color) {
    final ratio = (eaten / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
            Text('${eaten.toStringAsFixed(1)}g', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 5,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildPortionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.scale_rounded, color: Color(0xFF2563EB), size: 18),
              SizedBox(width: 8),
              Text(
                'Portion Weight (Grams)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _portionController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter weight (e.g. 150)',
              suffixText: 'grams',
              suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Presets: ',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _portionPresets.map((preset) {
                      final isSelected = _portionController.text.trim() == preset.toStringAsFixed(0);
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text('${preset.toInt()}g'),
                          selected: isSelected,
                          selectedColor: const Color(0xFF2563EB),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          backgroundColor: const Color(0xFFF1F5F9),
                          onSelected: (_) {
                            setState(() {
                              _portionController.text = preset.toStringAsFixed(0);
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactConnectionBadge() {
    final isOnline = _backendStatus?.isBackendOnline == true && _backendStatus?.isFlaskOnline == true;
    final isChecking = _backendStatus == null;

    final Color dotColor = isChecking
        ? const Color(0xFF94A3B8)
        : (isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444));

    return InkWell(
      onTap: () => setState(() => _activeNavIndex = 3),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: dotColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: dotColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              isChecking ? 'Checking' : (isOnline ? 'Online' : 'Offline'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: dotColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
