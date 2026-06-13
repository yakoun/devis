extension StringExtensions on String {
  String get capitalize => isEmpty
      ? this
      : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  String get capitalizeAll => isEmpty
      ? this
      : split(' ').map((word) => word.capitalize).join(' ');

  String get toPhone => replaceAll(RegExp(r'[^0-9]'), '');

  bool get isValidEmail => RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
      .hasMatch(this);

  bool get isValidPhone => length >= 8 && length <= 15;

  String get masked {
    if (length <= 4) return this;
    return '${substring(0, length - 4).replaceAll(RegExp(r'.'), '*')}${substring(length - 4)}';
  }

  String truncate(int maxLength) =>
      length > maxLength ? '${substring(0, maxLength)}...' : this;
}
