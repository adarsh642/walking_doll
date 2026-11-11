import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../characters/presentation/controllers/doll_provider.dart';
import '../../characters/presentation/widgets/doll_card.dart';
import '../../import/presentation/import_screen.dart';
import 'character_detail_sheet.dart';

/// Gallery Screen presenting built-in and imported dolls in an adaptive responsive grid
/// with filter chips (All, 2D, 3D, Imported).
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dollProvider = context.watch<DollProvider>();
    final characters = dollProvider.filteredCharacters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doll Gallery'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: FilledButton.tonalIcon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ImportScreen(
                      onImportSuccess: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Import', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildFilterChips(context, dollProvider),
        ),
      ),
      body: SafeArea(
        child: characters.isEmpty
            ? _buildNoResultsState(context)
            : ResponsiveLayout.constrainedContainer(
                maxWidth: 1100,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = ResponsiveLayout.getGalleryGridColumns(context);

                    return GridView.builder(
                      itemCount: characters.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.82,
                      ),
                      itemBuilder: (context, index) {
                        final doll = characters[index];
                        final isActive = dollProvider.activeDoll?.id == doll.id;

                        return DollCard(
                          doll: doll,
                          isActive: isActive,
                          onTap: () {
                            CharacterDetailSheet.show(context, doll);
                          },
                          onSelect: () {
                            dollProvider.selectDoll(doll);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, DollProvider provider) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final filters = [
      (CharacterFilter.all, 'All Dolls', Icons.grid_view_rounded),
      (CharacterFilter.twoD, '2D Engines', Icons.auto_awesome_rounded),
      (CharacterFilter.threeD, '3D GLB', Icons.view_in_ar_rounded),
      (CharacterFilter.imported, 'Imported', Icons.folder_special_rounded),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: filters.map((item) {
          final isSelected = provider.currentFilter == item.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(item.$2),
              avatar: Icon(
                item.$3,
                size: 14,
                color: isSelected ? Colors.white : AppColors.softLavender,
              ),
              selected: isSelected,
              selectedColor: AppColors.primaryPink,
              backgroundColor: isLight ? AppColors.lightCardSubtle : AppColors.darkCardSubtle,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary),
              ),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primaryPink
                    : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
                width: 1.0,
              ),
              onSelected: (_) => provider.setFilter(item.$1),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'No dolls found in this category',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Import a character or switch the filter tab.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
