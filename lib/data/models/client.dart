import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/enums.dart';

class AppClient extends Equatable {
  final String id;
  final String nom;
  final String? email;
  final String telephone;
  final String? adresse;
  final String? ville;
  final String? codePostal;
  final String? siret;
  final ClientCategory category;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  const AppClient({
    required this.id,
    required this.nom,
    this.email,
    required this.telephone,
    this.adresse,
    this.ville,
    this.codePostal,
    this.siret,
    this.category = ClientCategory.particulier,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
  });

  factory AppClient.create({
    required String nom,
    String? email,
    required String telephone,
    String? adresse,
    String? ville,
    String? codePostal,
    String? siret,
    ClientCategory category = ClientCategory.particulier,
    String? notes,
  }) {
    final now = DateTime.now();
    return AppClient(
      id: const Uuid().v4(),
      nom: nom,
      email: email,
      telephone: telephone,
      adresse: adresse,
      ville: ville,
      codePostal: codePostal,
      siret: siret,
      category: category,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  AppClient copyWith({
    String? nom,
    String? email,
    String? telephone,
    String? adresse,
    String? ville,
    String? codePostal,
    String? siret,
    ClientCategory? category,
    String? notes,
    bool? isArchived,
  }) {
    return AppClient(
      id: id,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      ville: ville ?? this.ville,
      codePostal: codePostal ?? this.codePostal,
      siret: siret ?? this.siret,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'email': email,
        'telephone': telephone,
        'adresse': adresse,
        'ville': ville,
        'codePostal': codePostal,
        'siret': siret,
        'category': category.index,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isArchived': isArchived,
      };

  factory AppClient.fromJson(Map<String, dynamic> json) => AppClient(
        id: json['id'] as String,
        nom: json['nom'] as String,
        email: json['email'] as String?,
        telephone: json['telephone'] as String,
        adresse: json['adresse'] as String?,
        ville: json['ville'] as String?,
        codePostal: json['codePostal'] as String?,
        siret: json['siret'] as String?,
        category: ClientCategory.values[json['category'] as int? ?? 0],
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        isArchived: json['isArchived'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [
        id, nom, email, telephone, adresse, ville, codePostal, siret,
        category, notes, createdAt, updatedAt, isArchived,
      ];
}
