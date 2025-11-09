import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class SemesterCard extends StatefulWidget {
  final String semester;
  final String openDate;
  final String closeDate;
  final List<Map<String, dynamic>> modules;
  final Map<String, List<String>> selectedModules;
  final int maxModulesPerSemester;
  final void Function(String moduleName, bool isSelected) onModuleChanged;

  const SemesterCard({
    required this.semester,
    required this.openDate,
    required this.closeDate,
    required this.modules,
    required this.selectedModules,
    required this.maxModulesPerSemester,
    required this.onModuleChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<SemesterCard> createState() => _SemesterCardState();
}

class _SemesterCardState extends State<SemesterCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: AppColors.card(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          onExpansionChanged: (expanded) => setState(() => _isExpanded = expanded),
          title: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: double.infinity,
            decoration: BoxDecoration(
              color: _isExpanded
                  ? AppColors.sectionHeaderActive(context)
                  : AppColors.sectionHeaderInactive(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.semester.toUpperCase(),
                  style: AppTextStyles.subheading(context).copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Wahltermine: von ${widget.openDate} bis ${widget.closeDate}',
                  style: AppTextStyles.body(context).copyWith(
                    color: AppColors.textPrimary(context).withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          children: [
            Container(
              color: AppColors.card(context),
              child: Column(
                children: widget.modules.map((m) {
                  final moduleName = m['name'] ?? '';
                  final moduleDozent = m['dozent'] ?? '';
                  final isSelected = widget.selectedModules[widget.semester]
                          ?.contains(moduleName) ??
                      false;

                  return CheckboxListTile(
                    activeColor: colorScheme.primary,
                    checkColor: colorScheme.onPrimary,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      '$moduleName ($moduleDozent)',
                      style: AppTextStyles.body(context),
                    ),
                    value: isSelected,
                    onChanged: (val) =>
                        widget.onModuleChanged(moduleName, val ?? false),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
