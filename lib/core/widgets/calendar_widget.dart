import 'package:flutter/material.dart';
import 'package:devis/design_system/design_system.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final Map<DateTime, List<CalendarEvent>>? events;

  const CalendarWidget({
    super.key,
    this.selectedDate,
    this.onDateSelected,
    this.events,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _currentMonth;
  late DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _selectedDate = widget.selectedDate;
  }

  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _selectedDate = widget.selectedDate;
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7;

    return Card(
      color: isDark ? AppColors.darkSurfaceLight : AppColors.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  _monthYearString(_currentMonth),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.electricBlue,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Weekday headers
            Row(
              children: ['D', 'L', 'M', 'M', 'J', 'V', 'S'].map((d) {
                return Expanded(
                  child: Center(
                    child: Text(d,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            // Days grid
            ...List.generate(_weeks(daysInMonth, firstWeekday), (weekIndex) {
              return Row(
                children: List.generate(7, (dayIndex) {
                  final day = weekIndex * 7 + dayIndex - firstWeekday + 1;
                  if (day < 1 || day > daysInMonth) {
                    return const Expanded(child: SizedBox(height: 40));
                  }
                  final date = DateTime(
                    _currentMonth.year,
                    _currentMonth.month,
                    day,
                  );
                  final isSelected = _selectedDate != null &&
                      _selectedDate!.day == day &&
                      _selectedDate!.month == _currentMonth.month &&
                      _selectedDate!.year == _currentMonth.year;
                  final isToday = date.day == DateTime.now().day &&
                      date.month == DateTime.now().month &&
                      date.year == DateTime.now().year;
                  final hasEvents = widget.events?.keys.any((e) =>
                          e.year == date.year &&
                          e.month == date.month &&
                          e.day == date.day) ??
                      false;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedDate = date);
                        widget.onDateSelected?.call(date);
                      },
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.electricBlue
                              : (isToday
                                  ? AppColors.electricBlue.withValues(alpha: 0.1)
                                  : null),
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    isSelected || isToday
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.textOnDark
                                        : AppColors.textPrimary),
                              ),
                            ),
                            if (hasEvents)
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppColors.electricGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ],
        ),
      ),
    );
  }

  int _weeks(int days, int firstWeekday) {
    return ((days + firstWeekday + 6) / 7).ceil();
  }

  String _monthYearString(DateTime date) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class CalendarEvent {
  final String title;
  final DateTime date;
  final Color? color;

  const CalendarEvent({
    required this.title,
    required this.date,
    this.color,
  });
}
