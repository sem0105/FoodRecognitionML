import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onHistoryCleared;

  const SettingsScreen({super.key, this.onHistoryCleared});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  BackendStatus? _backendStatus;
  AppSettings _settings = AppSettings();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkStatus();
  }

  Future<void> _loadSettings() async {
    final s = await SettingsService.loadSettings();
    if (mounted) setState(() => _settings = s);
  }

  Future<void> _checkStatus() async {
    final status = await ApiService.checkBackendStatus();
    if (mounted) setState(() => _backendStatus = status);
  }

  void _showServerIpDialog() {
    final controller = TextEditingController(text: ApiConfig.baseUrl);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.dns_rounded, color: Color(0xFF2563EB)),
              SizedBox(width: 10),
              Text('Backend Connection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your backend server base URL (e.g. your Wi-Fi IP or emulator host):',
                style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Server Base URL',
                  hintText: 'http://10.130.177.159:5000',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.link_rounded),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final input = controller.text.trim();
                if (input.isNotEmpty) {
                  ApiConfig.setBaseUrl(input);
                  Navigator.pop(context);
                  _checkStatus();
                }
              },
              child: const Text('Save & Test'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Meal History'),
        content: const Text(
          'This will permanently delete all saved meal scans and locally stored food pictures. This cannot be undone.',
        ),
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
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await HistoryService.clearAll();
      widget.onHistoryCleared?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All meal history and stored photos cleared.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = _backendStatus?.isBackendOnline == true && _backendStatus?.isFlaskOnline == true;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // User Profile Header Card (Matching Screenshot 1)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF10B981)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.person_rounded, color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FoodLens User',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'AI Nutrition Tracker • v1.0.0',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section: Preferences (Matching Screenshot 4 App Settings)
        const Text(
          'GENERAL PREFERENCES',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.straighten_rounded, color: Color(0xFF2563EB)),
                title: const Text('Measurement Units', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(_settings.unit == 'metric' ? 'Metric (Grams • g)' : 'Imperial (Ounces • oz)'),
                trailing: DropdownButton<String>(
                  value: _settings.unit,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'metric', child: Text('Metric (g)')),
                    DropdownMenuItem(value: 'imperial', child: Text('Imperial (oz)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      final updated = _settings.copyWith(unit: val);
                      setState(() => _settings = updated);
                      SettingsService.saveSettings(updated);
                    }
                  },
                ),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.palette_outlined, color: Color(0xFF2563EB)),
                title: const Text('Appearance Theme', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(_settings.themeMode == 'light' ? 'Light Theme' : 'Dark Theme'),
                trailing: DropdownButton<String>(
                  value: _settings.themeMode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'light', child: Text('Light')),
                    DropdownMenuItem(value: 'dark', child: Text('Dark')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      final updated = _settings.copyWith(themeMode: val);
                      setState(() => _settings = updated);
                      SettingsService.saveSettings(updated);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section: System & Connectivity
        const Text(
          'BACKEND & SERVICES',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.dns_rounded, color: Color(0xFF2563EB)),
                title: const Text('Backend API Server', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(ApiConfig.baseUrl),
                trailing: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF94A3B8)),
                onTap: _showServerIpDialog,
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(
                  isOnline ? Icons.check_circle_rounded : Icons.error_rounded,
                  color: isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
                title: const Text('System Connection', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(_backendStatus?.message ?? 'Testing connection...'),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  onPressed: _checkStatus,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section: Data & Storage
        const Text(
          'DATA & PRIVACY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: ListTile(
            leading: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFEF4444)),
            title: const Text(
              'Clear All Scan History',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFFEF4444)),
            ),
            subtitle: const Text('Delete all persistent meal logs and photos'),
            onTap: _clearHistory,
          ),
        ),
      ],
    );
  }
}
