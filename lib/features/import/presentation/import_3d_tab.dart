import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../characters/domain/character_animation.dart';
import '../../characters/domain/character_model.dart';
import '../../characters/engines/three_d/three_d_model_view.dart';
import '../../characters/presentation/controllers/doll_provider.dart';

/// 3D Character Import Tab: supports local GLB / GLTF 3D avatars
/// with model validation, 3D interactive preview, and persistent import.
class Import3DTab extends StatefulWidget {
  final VoidCallback onSuccess;

  const Import3DTab({super.key, required this.onSuccess});

  @override
  State<Import3DTab> createState() => _Import3DTabState();
}

class _Import3DTabState extends State<Import3DTab> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedGlbPath;
  int _fileSizeBytes = 0;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pick3DFile() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      // Use FileType.any so Android's Storage Access Framework does not filter
      // or grey out .glb files due to Android OS lacking built-in MIME mapping for GLB.
      final files = await FilePicker.pickFiles(
        type: FileType.any,
      );

      if (files.isNotEmpty) {
        final pickedFile = files.first;
        final path = pickedFile.path;
        if (path != null) {
          final file = File(path);
          final exists = await file.exists();
          if (!exists) {
            setState(() {
              _errorMessage = 'Selected file does not exist on disk.';
            });
            return;
          }

          final lowerName = pickedFile.name.toLowerCase();
          final lowerPath = path.toLowerCase();
          final is3DFormat = lowerName.endsWith('.glb') ||
              lowerName.endsWith('.gltf') ||
              lowerPath.endsWith('.glb') ||
              lowerPath.endsWith('.gltf');

          if (!is3DFormat) {
            setState(() {
              _errorMessage =
                  'Selected file "${pickedFile.name}" is not a 3D model.\nPlease select a .glb or .gltf file (e.g. from your Downloads).';
            });
            return;
          }

          final size = await file.length();
          if (size <= 12) {
            setState(() {
              _errorMessage =
                  'Invalid 3D file: File is empty or corrupt (<12 bytes).';
            });
            return;
          }

          // Verify GLB magic header if file is .glb
          if (lowerName.endsWith('.glb') || lowerPath.endsWith('.glb')) {
            try {
              final stream = file.openRead(0, 4);
              final bytes = await stream.first;
              // ASCII for 'glTF': 'g'=0x67, 'l'=0x6C, 'T'=0x54, 'F'=0x46
              final isGlbHeader = bytes.length >= 4 &&
                  bytes[0] == 0x67 &&
                  bytes[1] == 0x6C &&
                  bytes[2] == 0x54 &&
                  bytes[3] == 0x46;
              if (!isGlbHeader) {
                setState(() {
                  _errorMessage =
                      'The file "${pickedFile.name}" has a .glb extension, but is not a valid binary glTF file. It may be an HTML page or corrupt download.';
                });
                return;
              }
            } catch (_) {
              // Non-blocking fallback if header stream fails
            }
          }

          setState(() {
            _selectedGlbPath = path;
            _fileSizeBytes = size;
            if (_nameController.text.trim().isEmpty) {
              final rawName = pickedFile.name.split('.').first;
              _nameController.text = rawName.replaceAll('_', ' ').capitalize();
            }
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not access file picker: $e';
      });
    }
  }

  Future<void> _handleImport() async {
    if (_selectedGlbPath == null) {
      setState(() {
        _errorMessage = 'Please choose a .glb or .gltf 3D model file first.';
      });
      return;
    }

    final name = _nameController.text.trim().isEmpty
        ? 'Custom 3D Doll'
        : _nameController.text.trim();

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final dollProvider = context.read<DollProvider>();
      await dollProvider.importNewCharacter(
        name: name,
        type: CharacterType.threeD,
        filePath: _selectedGlbPath!,
        isSpriteSheet: false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported 3D doll "$name"!'),
            backgroundColor: AppColors.mintGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onSuccess();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to import 3D model: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        // File Selection Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '1. Select 3D Avatar (.glb / .gltf)',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Standard glTF 2.0 binary (.glb) files with embedded textures and animations.',
                style: TextStyle(fontSize: 12, color: isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pick3DFile,
                icon: const Icon(Icons.view_in_ar_rounded),
                label: Text(_selectedGlbPath == null ? 'Choose GLB / GLTF Model' : 'Change Selected 3D Model'),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.skyBlue.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.skyBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Downloaded models (Sketchfab, ReadyPlayerMe, etc.) will be visible in your Downloads or Files app.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedGlbPath != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Selected: ${_selectedGlbPath!.split(Platform.pathSeparator).last} (${(_fileSizeBytes / 1024).toStringAsFixed(1)} KB)',
                  style: const TextStyle(fontSize: 11, color: AppColors.threeDBadge, fontWeight: FontWeight.w700),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Character Name Input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '2. Model Name',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Cyber Doll, Star Robot, Crystal Gem...',
                  filled: true,
                  fillColor: isLight ? AppColors.lightCardSubtle : AppColors.darkCardSubtle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Interactive 3D Model Preview
        if (_selectedGlbPath != null) ...[
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: isLight ? AppColors.lightCardSubtle : AppColors.darkCardSubtle,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
              ),
            ),
            child: _buildLive3DPreview(),
          ),
          const SizedBox(height: 16),
        ],

        // Error message
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ),
          const SizedBox(height: 16),
        ],

        // Import Button
        ElevatedButton(
          onPressed: _isSaving ? null : _handleImport,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.skyBlue,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Import 3D GLB Model'),
        ),
      ],
    );
  }

  Widget _buildLive3DPreview() {
    if (_selectedGlbPath == null) return const SizedBox.shrink();

    final previewModel = CharacterModel(
      id: 'preview_3d_temp',
      name: _nameController.text.isEmpty ? '3D Preview' : _nameController.text,
      type: CharacterType.threeD,
      assetPath: _selectedGlbPath!,
      isAsset: false,
      hasEmbeddedAnimations: true,
      availableAnimations: const ['idle', 'walk', 'dance'],
      createdAt: DateTime.now(),
    );

    return ThreeDModelView(
      character: previewModel,
      currentAnimation: CharacterAnimation.idle,
      enableControls: true,
      autoRotate: true,
    );
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
