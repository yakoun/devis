import 'package:equatable/equatable.dart';

class TechnicienInfo extends Equatable {
  final String nom;
  final String prenom;
  final String entreprise;
  final String siret;
  final String telephone;
  final String email;
  final String adresse;
  final String ville;
  final String codePostal;
  final String logoPath;

  const TechnicienInfo({
    this.nom = '',
    this.prenom = '',
    this.entreprise = '',
    this.siret = '',
    this.telephone = '',
    this.email = '',
    this.adresse = '',
    this.ville = '',
    this.codePostal = '',
    this.logoPath = '',
  });

  bool get isEmpty =>
      nom.isEmpty && prenom.isEmpty && entreprise.isEmpty;

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'prenom': prenom,
        'entreprise': entreprise,
        'siret': siret,
        'telephone': telephone,
        'email': email,
        'adresse': adresse,
        'ville': ville,
        'codePostal': codePostal,
        'logoPath': logoPath,
      };

  factory TechnicienInfo.fromJson(Map<String, dynamic> json) => TechnicienInfo(
        nom: json['nom'] as String? ?? '',
        prenom: json['prenom'] as String? ?? '',
        entreprise: json['entreprise'] as String? ?? '',
        siret: json['siret'] as String? ?? '',
        telephone: json['telephone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        adresse: json['adresse'] as String? ?? '',
        ville: json['ville'] as String? ?? '',
        codePostal: json['codePostal'] as String? ?? '',
        logoPath: json['logoPath'] as String? ?? '',
      );

  TechnicienInfo copyWith({
    String? nom,
    String? prenom,
    String? entreprise,
    String? siret,
    String? telephone,
    String? email,
    String? adresse,
    String? ville,
    String? codePostal,
    String? logoPath,
  }) =>
      TechnicienInfo(
        nom: nom ?? this.nom,
        prenom: prenom ?? this.prenom,
        entreprise: entreprise ?? this.entreprise,
        siret: siret ?? this.siret,
        telephone: telephone ?? this.telephone,
        email: email ?? this.email,
        adresse: adresse ?? this.adresse,
        ville: ville ?? this.ville,
        codePostal: codePostal ?? this.codePostal,
        logoPath: logoPath ?? this.logoPath,
      );

  @override
  List<Object?> get props => [
        nom, prenom, entreprise, siret, telephone, email,
        adresse, ville, codePostal, logoPath,
      ];
}
