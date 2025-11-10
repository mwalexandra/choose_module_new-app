import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/module.dart';
import '../models/semester.dart';

class SemesterCard extends StatefulWidget {
  final Semester semester;
  final int maxModulesPerSemester;
  final void Function(Module module) onModuleChanged;

  const SemesterCard({
    required this.semester,
    required this.maxModulesPerSemester,
    required this.onModuleChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<SemesterCard> createState() => _SemesterCardState();
}

class _SemesterCardState extends State<SemesterCard> with SingleTickerProviderStateMixin {
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

  bool get _isSelectionActive => widget.semester.isSelectionActive();

  void _toggleModuleSelection(Module module) {
    final selectedCount = widget.semester.modules.where(
      (m) => m.isSelected).length;

    if (!module.isSelected && selectedCount >= widget.maxModulesPerSemester) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sie können nicht mehr als ${widget.maxModulesPerSemester} Module auswählen.'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!module.isSelected && module.participants >= module.maxParticipants) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximale Anzahl von Teilnehmern erreicht.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      module.isSelected = !module.isSelected;
      module.participants += module.isSelected ? 1 : -1;
    });

    widget.onModuleChanged(module);
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
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                _isExpanded ? _arrowController.forward() : _arrowController.reverse();
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.semester.name.toUpperCase(),
                            style: AppTextStyles.subheading(context)
                                .copyWith(color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          'Wahltermine: von ${widget.semester.openDate.toLocal().toString().split(" ")[0]} '
                          'bis ${widget.semester.closeDate.toLocal().toString().split(" ")[0]}',
                          style: AppTextStyles.body(context)
                              .copyWith(color: Colors.white70),
                        ),
                        if (!_isSelectionActive)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Auswahl nicht möglich',
                              style: AppTextStyles.body(context)
                                  .copyWith(color: Colors.redAccent),
                            ),
                          ),
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns: _arrowController,
                    child: const Icon(Icons.expand_more, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Modules
          if (_isExpanded)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Column(
                children: widget.semester.modules.map((module) {
                  final isSelectable =
                      _isSelectionActive && (module.isSelected || module.participants < module.maxParticipants);

                  return CheckboxListTile(
                    activeColor: colorScheme.primary,
                    checkColor: colorScheme.onPrimary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text('${module.name} (${module.dozent})',
                              style: AppTextStyles.body(context)),
                        ),
                        SizedBox(
                          width: 60,
                          child: Text(
                            '${module.participants}/${module.maxParticipants}',
                            textAlign: TextAlign.right,
                            style: AppTextStyles.body(context).copyWith(
                                color: isSelectable ? Colors.black54 : Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                    value: module.isSelected,
                    onChanged: isSelectable ? (_) => _toggleModuleSelection(module) : null,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
