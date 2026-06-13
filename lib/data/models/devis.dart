class LigneDevis {
  final int quantite;
  final String designation;
  final int prixUnitaire;

  const LigneDevis({
    required this.quantite,
    required this.designation,
    required this.prixUnitaire,
  });

  int get prixTotal => quantite * prixUnitaire;

  Map<String, dynamic> toJson() => {
        'quantite': quantite,
        'designation': designation,
        'prixUnitaire': prixUnitaire,
      };

  factory LigneDevis.fromJson(Map<String, dynamic> json) => LigneDevis(
        quantite: json['quantite'] as int,
        designation: json['designation'] as String,
        prixUnitaire: json['prixUnitaire'] as int,
      );
}

class Client {
  final String nom;
  final String? prenom;
  final String contact;

  const Client({
    required this.nom,
    this.prenom,
    required this.contact,
  });

  String get nomComplet => prenom != null ? '$prenom $nom' : nom;

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'prenom': prenom,
        'contact': contact,
      };

  factory Client.fromJson(Map<String, dynamic> json) => Client(
        nom: json['nom'] as String,
        prenom: json['prenom'] as String?,
        contact: json['contact'] as String,
      );
}

class Technicien {
  final String nom;
  final String prenom;

  const Technicien({
    required this.nom,
    required this.prenom,
  });

  String get nomComplet => '$prenom $nom';

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'prenom': prenom,
      };

  factory Technicien.fromJson(Map<String, dynamic> json) => Technicien(
        nom: json['nom'] as String,
        prenom: json['prenom'] as String,
      );
}

class Devis {
  final String id;
  final String numero;
  final DateTime date;
  final Client client;
  final Technicien technicien;
  final String description;
  final List<LigneDevis> lignes;
  final int mainOeuvre;
  final String statut;

  const Devis({
    required this.id,
    required this.numero,
    required this.date,
    required this.client,
    required this.technicien,
    required this.description,
    required this.lignes,
    required this.mainOeuvre,
    this.statut = 'brouillon',
  });

  int get totalAchat => lignes.fold(0, (sum, l) => sum + l.prixTotal);
  int get netAPayer => totalAchat + mainOeuvre;

  Map<String, dynamic> toJson() => {
        'id': id,
        'numero': numero,
        'date': date.toIso8601String(),
        'client': client.toJson(),
        'technicien': technicien.toJson(),
        'description': description,
        'lignes': lignes.map((l) => l.toJson()).toList(),
        'mainOeuvre': mainOeuvre,
        'statut': statut,
      };

  factory Devis.fromJson(Map<String, dynamic> json) => Devis(
        id: json['id'] as String,
        numero: json['numero'] as String,
        date: DateTime.parse(json['date'] as String),
        client: Client.fromJson(Map<String, dynamic>.from(json['client'] as Map)),
        technicien: Technicien.fromJson(Map<String, dynamic>.from(json['technicien'] as Map)),
        description: json['description'] as String,
        lignes: (json['lignes'] as List).map((l) => LigneDevis.fromJson(Map<String, dynamic>.from(l as Map))).toList(),
        mainOeuvre: json['mainOeuvre'] as int,
        statut: json['statut'] as String? ?? 'brouillon',
      );

  Devis copyWith({
    String? statut,
    List<LigneDevis>? lignes,
    int? mainOeuvre,
    String? description,
  }) =>
      Devis(
        id: id,
        numero: numero,
        date: date,
        client: client,
        technicien: technicien,
        description: description ?? this.description,
        lignes: lignes ?? this.lignes,
        mainOeuvre: mainOeuvre ?? this.mainOeuvre,
        statut: statut ?? this.statut,
      );
}
