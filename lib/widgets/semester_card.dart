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

class _SemesterCardState extends State<SemesterCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _arrowController;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      upperBound: 0.5,
    );
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // --- Header (шапка карты) ---
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (_isExpanded) {
                  _arrowController.forward();
                } else {
                  _arrowController.reverse();
                }
              });
            },
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card(context),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.semester.toUpperCase(),
                          style: AppTextStyles.subheading(context)
                              .copyWith(color: AppColors.textPrimary(context)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Wahltermine: von ${widget.openDate} bis ${widget.closeDate}',
                          style: AppTextStyles.body(context)
                              .copyWith(color: AppColors.textPrimary(context)),
                        ),
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns: _arrowController,
                    child: Icon(Icons.expand_more, color: AppColors.textPrimary(context)),
                  ),
                ],
              ),
            ),
          ),

          // --- Module list ---
          if (_isExpanded)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card(context), // фон для модулей
                borderRadius: const BorderRadius.all(
                    Radius.circular(12)),
              ),
              child: Column(
                children: widget.modules.map((m) {
                  final moduleName = m['name'] ?? '';
                  final moduleDozent = m['dozent'] ?? '';
                  final isSelected =
                      widget.selectedModules[widget.semester]?.contains(moduleName) ?? false;

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
    );
  }
}
