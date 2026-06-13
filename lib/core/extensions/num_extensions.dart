import 'package:intl/intl.dart';

extension NumExtensions on num {
  String get formattedCurrency {
    final format = NumberFormat('#,##0', 'fr_FR');
    return '${format.format(this)} FCFA';
  }

  String get formattedCompact {
    if (this >= 1000000) return '${(this / 1000000).toStringAsFixed(1)}M';
    if (this >= 1000) return '${(this / 1000).toStringAsFixed(1)}k';
    return toString();
  }

  String get formattedPercentage => '${toStringAsFixed(1)}%';

  String get formattedDecimal => NumberFormat('#,##0.00', 'fr_FR').format(this);
}
