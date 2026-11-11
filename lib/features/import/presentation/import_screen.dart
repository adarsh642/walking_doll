import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import 'import_2d_tab.dart';
import 'import_3d_tab.dart';

/// Import Screen containing 2D & 3D tabs, plus a disabled AI Generation teaser card.
class ImportScreen extends StatefulWidget {
  final VoidCallback onImportSuccess;

  const ImportScreen({super.key, required this.onImportSuccess});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.importTitle),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryPink,
          unselectedLabelColor: isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
          indicatorColor: AppColors.primaryPink,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
          tabs: const [
            Tab(icon: Icon(Icons.view_in_ar_rounded, size: 20), text: AppStrings.tab3D),
            Tab(icon: Icon(Icons.brush_rounded, size: 20), text: AppStrings.tab2D),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 3D Doll Studio & PBR Guide Card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: _buildStudioGuideCard(context),
            ),

            // Tab Views for 3D (First) and 2D
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Import3DTab(onSuccess: widget.onImportSuccess),
                  Import2DTab(onSuccess: widget.onImportSuccess),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudioGuideCard(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightCardSubtle : AppColors.darkCardSubtle,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.softLavender.withAlpha(80),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [Color(0xFF64B5F6), Color(0xFFBA68C8)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.view_in_ar_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      AppStrings.studioGuideTitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.softLavender.withAlpha(35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        AppStrings.studioGuideBadge,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.softLavender,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  AppStrings.studioGuideDesc,
                  style: TextStyle(
                    fontSize: 11,
                    color: isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

