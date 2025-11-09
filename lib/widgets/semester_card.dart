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
  late bool _isSelectionActive;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      upperBound: 0.5,
    );
    _isSelectionActive = _checkSelectionActive();
  }

  bool _checkSelectionActive() {
    try {
      final now = DateTime.now();
      final open = DateTime.parse(widget.openDate);
      final close = DateTime.parse(widget.closeDate);
      return now.isAfter(open.subtract(const Duration(days: 1))) &&
          now.isBefore(close.add(const Duration(days: 1)));
    } catch (_) {
      return true; // если формат даты некорректный, выбор разрешаем
    }
  }

  bool _isModuleSelectable(Map<String, dynamic> module) {
    final participants = module['participants'] ?? 0;
    final maxParticipants = module['maxParticipants'] ?? 20;
    return _isSelectionActive && participants < maxParticipants;
  }

  void _handleModuleChange(Map<String, dynamic> module, bool isSelected) {
    final moduleName = module['name'] ?? '';
    final participants = module['participants'] ?? 0;
    final maxParticipants = module['maxParticipants'] ?? 20;

    setState(() {
      // Обновляем локальное количество участников
      if (isSelected) {
        if (participants < maxParticipants) {
          module['participants'] = participants + 1;
        }
      } else {
        module['participants'] = (participants > 0) ? participants - 1 : 0;
      }
    });

    widget.onModuleChanged(moduleName, isSelected);
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
          // --- Header ---
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
                        Text(
                          widget.semester.toUpperCase(),
                          style: AppTextStyles.subheading(context)
                              .copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Wahltermine: von ${widget.openDate} bis ${widget.closeDate}',
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
                    child: Icon(Icons.expand_more, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // --- Modules ---
          if (_isExpanded)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Column(
                children: widget.modules.map((m) {
                  final moduleName = m['name'] ?? '';
                  final moduleDozent = m['dozent'] ?? '';
                  final participants = m['participants'] ?? 0;
                  final maxParticipants = m['maxParticipants'] ?? 20;
                  final isSelected =
                      widget.selectedModules[widget.semester]?.contains(moduleName) ?? false;
                  final isSelectable = _isSelectionActive && participants < maxParticipants;

                  return CheckboxListTile(
                    activeColor: colorScheme.primary,
                    checkColor: colorScheme.onPrimary,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$moduleName ($moduleDozent)',
                            style: AppTextStyles.body(context),
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: Text(
                            '$participants/$maxParticipants',
                            textAlign: TextAlign.right,
                            style: AppTextStyles.body(context).copyWith(
                              color: isSelectable ? Colors.black54 : Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    value: isSelected,
                    onChanged: isSelectable
                        ? (val) => _handleModuleChange(m, val ?? false)
                        : null,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
