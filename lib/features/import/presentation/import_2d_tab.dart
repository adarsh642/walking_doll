import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../characters/domain/character_animation.dart';
import '../../characters/domain/character_model.dart';
import '../../characters/engines/two_d/two_d_procedural_view.dart';
import '../../characters/engines/two_d/two_d_sprite_view.dart';
import '../../characters/presentation/controllers/doll_provider.dart';

/// 2D Character Import Tab: supports PNG, GIF, and animated sprite-sheets
/// with columns, rows, and FPS controls.
class Import2DTab extends StatefulWidget {
  final VoidCallback onSuccess;

  const Import2DTab({super.key, required this.onSuccess});

  @override
  State<Import2DTab> createState() => _Import2DTabState();
}

class _Import2DTabState extends State<Import2DTab> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedFilePath;
  bool _isSpriteSheet = false;
  int _columns = 4;
  int _rows = 1;
  int _fps = 8;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pick2DFile() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'gif', 'jpg', 'jpeg', 'webp'],
      );

      if (files.isNotEmpty) {
        final path = files.first.path;
        if (path != null) {
          setState(() {
            _selectedFilePath = path;
            if (_nameController.text.trim().isEmpty) {
              final rawName = files.first.name.split('.').first;
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
    if (_selectedFilePath == null) {
      setState(() {
        _errorMessage = 'Please select a PNG, GIF, or sprite image file first.';
      });
      return;
    }

    final name = _nameController.text.trim().isEmpty
        ? 'Custom 2D Doll'
        : _nameController.text.trim();

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final dollProvider = context.read<DollProvider>();
      await dollProvider.importNewCharacter(
        name: name,
        type: CharacterType.twoD,
        filePath: _selectedFilePath!,
        isSpriteSheet: _isSpriteSheet,
        columns: _columns,
        rows: _rows,
        fps: _fps,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported "$name"!'),
            backgroundColor: AppColors.mintGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onSuccess();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to import character: $e';
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
        // File Selection Card
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
                '1. Select Image Asset',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Supports transparent PNGs, animated GIFs, or multi-frame sprite sheets.',
                style: TextStyle(fontSize: 12, color: isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pick2DFile,
                icon: const Icon(Icons.add_photo_alternate_rounded),
                label: Text(_selectedFilePath == null ? 'Choose PNG / GIF File' : 'Change Selected Image'),
              ),
              if (_selectedFilePath != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Selected: ${_selectedFilePath!.split(Platform.pathSeparator).last}',
                  style: const TextStyle(fontSize: 11, color: AppColors.primaryPink, fontWeight: FontWeight.w600),
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
                '2. Character Name',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Cherry Princess, Chibi Panda...',
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

        // Sprite Sheet Parameters
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sprite Sheet Animation',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      Text(
                        'Enable if the image contains frame tiles',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  Switch(
                    value: _isSpriteSheet,
                    activeThumbColor: AppColors.primaryPink,
                    onChanged: (val) {
                      setState(() {
                        _isSpriteSheet = val;
                      });
                    },
                  ),
                ],
              ),
              if (_isSpriteSheet) ...[
                const Divider(height: 24),
                // Columns slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Columns: $_columns', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Expanded(
                      child: Slider(
                        value: _columns.toDouble(),
                        min: 1,
                        max: 16,
                        divisions: 15,
                        activeColor: AppColors.primaryPink,
                        onChanged: (v) => setState(() => _columns = v.round()),
                      ),
                    ),
                  ],
                ),
                // Rows slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rows: $_rows', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Expanded(
                      child: Slider(
                        value: _rows.toDouble(),
                        min: 1,
                        max: 8,
                        divisions: 7,
                        activeColor: AppColors.primaryPink,
                        onChanged: (v) => setState(() => _rows = v.round()),
                      ),
                    ),
                  ],
                ),
                // FPS slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('FPS: $_fps', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Expanded(
                      child: Slider(
                        value: _fps.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        activeColor: AppColors.softLavender,
                        onChanged: (v) => setState(() => _fps = v.round()),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Live Preview Box
        if (_selectedFilePath != null) ...[
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: isLight ? AppColors.lightCardSubtle : AppColors.darkCardSubtle,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
              ),
            ),
            child: _buildLivePreview(),
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
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Import 2D Doll Companion'),
        ),
      ],
    );
  }

  Widget _buildLivePreview() {
    if (_selectedFilePath == null) return const SizedBox.shrink();

    final previewModel = CharacterModel(
      id: 'preview_temp',
      name: _nameController.text.isEmpty ? 'Preview' : _nameController.text,
      type: CharacterType.twoD,
      assetPath: _selectedFilePath!,
      isAsset: false,
      isSpriteSheet: _isSpriteSheet,
      columns: _columns,
      rows: _rows,
      fps: _fps,
      createdAt: DateTime.now(),
    );

    if (_isSpriteSheet) {
      return TwoDSpriteView(
        character: previewModel,
        currentAnimation: CharacterAnimation.idle,
      );
    } else {
      return TwoDProceduralView(
        character: previewModel,
        currentAnimation: CharacterAnimation.idle,
      );
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
