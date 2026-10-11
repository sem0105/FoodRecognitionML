import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FoodImagePicker extends StatelessWidget {
  final File? selectedImage;
  final Uint8List? imageBytes;
  final VoidCallback onPickFromGallery;
  final VoidCallback onCaptureFromCamera;
  final VoidCallback onClearImage;

  const FoodImagePicker({
    super.key,
    required this.selectedImage,
    this.imageBytes,
    required this.onPickFromGallery,
    required this.onCaptureFromCamera,
    required this.onClearImage,
  });

  ImageProvider _getImageProvider() {
    if (imageBytes != null && imageBytes!.isNotEmpty) {
      return MemoryImage(imageBytes!);
    }
    if (selectedImage != null) {
      if (kIsWeb) {
        return NetworkImage(selectedImage!.path);
      } else {
        return FileImage(selectedImage!);
      }
    }
    return const AssetImage('assets/placeholder.png');
  }

  bool get _hasImage => (imageBytes != null && imageBytes!.isNotEmpty) || selectedImage != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_hasImage) {
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.12),
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
                // Subtle bottom gradient shadow for contrast
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.25),
                        ],
                        stops: const [0.7, 1.0],
                      ),
                    ),
                  ),
                ),

                // Close / Delete Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.65),
                    radius: 18,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.close, color: Colors.white, size: 18),
                      onPressed: onClearImage,
                      tooltip: 'Remove Image',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined, size: 16),
                  label: const Text('Change (Gallery)', maxLines: 1, overflow: TextOverflow.ellipsis),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFFDBEAFE), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCaptureFromCamera,
                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                  label: const Text('Change (Camera)', maxLines: 1, overflow: TextOverflow.ellipsis),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFFDBEAFE), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Soft light blue fill
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              size: 44,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Scan or Pick Food Photo',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Upload a clear food photo to instantly identify the dish and calculate full nutritional details.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF475569),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPickFromGallery,
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: const Text('Gallery', maxLines: 1, overflow: TextOverflow.ellipsis),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCaptureFromCamera,
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Camera', maxLines: 1, overflow: TextOverflow.ellipsis),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

