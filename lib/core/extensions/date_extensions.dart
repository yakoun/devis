import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String get formatted => DateFormat('dd/MM/yyyy').format(this);
  String get formattedDateTime => DateFormat('dd/MM/yyyy HH:mm').format(this);
  String get formattedTime => DateFormat('HH:mm').format(this);
  String get formattedMonth => DateFormat('MMMM yyyy', 'fr_FR').format(this);
  String get formattedShort => DateFormat('dd/MM/yy').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
        isBefore(weekEnd);
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365} ans';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30} mois';
    if (diff.inDays > 0) return '${diff.inDays}j';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}min';
    return 'à l\'instant';
  }
}
