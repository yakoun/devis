import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final String technicianNom;
  final String technicianPrenom;
  final String companyName;
  final String companySlogan;
  final String phone;
  final String phoneSecondary;
  final String email;
  final String address;
  final String taxId;
  final String logoPath;
  final String currency;
  final bool tvaEnabled;
  final double tvaRate;
  final double defaultExpenses;
  final bool pdfShowLogo;
  final bool pdfShowSignature;
  final double pdfMarginCm;
  final String themeMode;
  final bool securityEnabled;
  final String pinCode;
  final bool notificationsEnabled;

  const AppSettings({
    this.technicianNom = '',
    this.technicianPrenom = '',
    this.companyName = 'YTech Pro',
    this.companySlogan = 'ERP pour artisans & PME',
    this.phone = '',
    this.phoneSecondary = '',
    this.email = '',
    this.address = '',
    this.taxId = '',
    this.logoPath = '',
    this.currency = 'XOF',
    this.tvaEnabled = false,
    this.tvaRate = 18,
    this.defaultExpenses = 0,
    this.pdfShowLogo = true,
    this.pdfShowSignature = false,
    this.pdfMarginCm = 0.5,
    this.themeMode = 'dark',
    this.securityEnabled = false,
    this.pinCode = '',
    this.notificationsEnabled = true,
  });

  AppSettings copyWith({
    String? technicianNom,
    String? technicianPrenom,
    String? companyName,
    String? companySlogan,
    String? phone,
    String? phoneSecondary,
    String? email,
    String? address,
    String? taxId,
    String? logoPath,
    String? currency,
    bool? tvaEnabled,
    double? tvaRate,
    double? defaultExpenses,
    bool? pdfShowLogo,
    bool? pdfShowSignature,
    double? pdfMarginCm,
    String? themeMode,
    bool? securityEnabled,
    String? pinCode,
    bool? notificationsEnabled,
  }) =>
      AppSettings(
        technicianNom: technicianNom ?? this.technicianNom,
        technicianPrenom: technicianPrenom ?? this.technicianPrenom,
        companyName: companyName ?? this.companyName,
        companySlogan: companySlogan ?? this.companySlogan,
        phone: phone ?? this.phone,
        phoneSecondary: phoneSecondary ?? this.phoneSecondary,
        email: email ?? this.email,
        address: address ?? this.address,
        taxId: taxId ?? this.taxId,
        logoPath: logoPath ?? this.logoPath,
        currency: currency ?? this.currency,
        tvaEnabled: tvaEnabled ?? this.tvaEnabled,
        tvaRate: tvaRate ?? this.tvaRate,
        defaultExpenses: defaultExpenses ?? this.defaultExpenses,
        pdfShowLogo: pdfShowLogo ?? this.pdfShowLogo,
        pdfShowSignature: pdfShowSignature ?? this.pdfShowSignature,
        pdfMarginCm: pdfMarginCm ?? this.pdfMarginCm,
        themeMode: themeMode ?? this.themeMode,
        securityEnabled: securityEnabled ?? this.securityEnabled,
        pinCode: pinCode ?? this.pinCode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      );

  Map<String, dynamic> toJson() => {
        'technicianNom': technicianNom,
        'technicianPrenom': technicianPrenom,
        'companyName': companyName,
        'companySlogan': companySlogan,
        'phone': phone,
        'phoneSecondary': phoneSecondary,
        'email': email,
        'address': address,
        'taxId': taxId,
        'logoPath': logoPath,
        'currency': currency,
        'tvaEnabled': tvaEnabled,
        'tvaRate': tvaRate,
        'defaultExpenses': defaultExpenses,
        'pdfShowLogo': pdfShowLogo,
        'pdfShowSignature': pdfShowSignature,
        'pdfMarginCm': pdfMarginCm,
        'themeMode': themeMode,
        'securityEnabled': securityEnabled,
        'pinCode': pinCode,
        'notificationsEnabled': notificationsEnabled,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        technicianNom: json['technicianNom'] as String? ?? '',
        technicianPrenom: json['technicianPrenom'] as String? ?? '',
        companyName: json['companyName'] as String? ?? 'YTech Pro',
        companySlogan: json['companySlogan'] as String? ?? 'ERP pour artisans & PME',
        phone: json['phone'] as String? ?? '',
        phoneSecondary: json['phoneSecondary'] as String? ?? '',
        email: json['email'] as String? ?? '',
        address: json['address'] as String? ?? '',
        taxId: json['taxId'] as String? ?? '',
        logoPath: json['logoPath'] as String? ?? '',
        currency: json['currency'] as String? ?? 'XOF',
        tvaEnabled: json['tvaEnabled'] as bool? ?? false,
        tvaRate: (json['tvaRate'] as num?)?.toDouble() ?? 18,
        defaultExpenses: (json['defaultExpenses'] as num?)?.toDouble() ?? 0,
        pdfShowLogo: json['pdfShowLogo'] as bool? ?? true,
        pdfShowSignature: json['pdfShowSignature'] as bool? ?? false,
        pdfMarginCm: (json['pdfMarginCm'] as num?)?.toDouble() ?? 0.5,
        themeMode: json['themeMode'] as String? ?? 'dark',
        securityEnabled: json['securityEnabled'] as bool? ?? false,
        pinCode: json['pinCode'] as String? ?? '',
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [
        technicianNom,
        technicianPrenom,
        companyName,
        companySlogan,
        phone,
        phoneSecondary,
        email,
        address,
        taxId,
        logoPath,
        currency,
        tvaEnabled,
        tvaRate,
        defaultExpenses,
        pdfShowLogo,
        pdfShowSignature,
        pdfMarginCm,
        themeMode,
        securityEnabled,
        pinCode,
        notificationsEnabled,
      ];
}
