import '../extensions/string_extensions.dart';

class Validators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Champ requis';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Champ requis';
    if (!value.trim().isValidEmail) return 'Email invalide';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Champ requis';
    if (!value.trim().isValidPhone) return 'Téléphone invalide';
    return null;
  }

  static String? Function(String?) min(double min, String field) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) return 'Champ requis';
      final number = double.tryParse(value.replaceAll(' ', ''));
      if (number == null) return 'Nombre invalide';
      if (number < min) return 'Minimum: $min';
      return null;
    };
  }

  static String? positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Champ requis';
    final number = double.tryParse(value.replaceAll(' ', ''));
    if (number == null) return 'Nombre invalide';
    if (number <= 0) return 'Doit être positif';
    return null;
  }
}
