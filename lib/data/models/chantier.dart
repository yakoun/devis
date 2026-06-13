import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/enums.dart';

class Chantier extends Equatable {
  final String id;
  final String nom;
  final String? description;
  final String? clientId;
  final String? clientNom;
  final String? adresse;
  final String? ville;
  final ChantierStatus statut;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final List<String> photos;
  final List<ChecklistItem> checklist;
  final String? notes;
  final String? signatureBase64;
  final Duration tempsPasse;
  final double budget;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Chantier({
    required this.id,
    required this.nom,
    this.description,
    this.clientId,
    this.clientNom,
    this.adresse,
    this.ville,
    this.statut = ChantierStatus.planifie,
    required this.dateDebut,
    this.dateFin,
    this.photos = const [],
    this.checklist = const [],
    this.notes,
    this.signatureBase64,
    this.tempsPasse = Duration.zero,
    this.budget = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Chantier.create({
    required String nom,
    String? description,
    String? clientId,
    String? clientNom,
    String? adresse,
    String? ville,
    double budget = 0,
  }) {
    final now = DateTime.now();
    return Chantier(
      id: const Uuid().v4(),
      nom: nom,
      description: description,
      clientId: clientId,
      clientNom: clientNom,
      adresse: adresse,
      ville: ville,
      dateDebut: now,
      budget: budget,
      createdAt: now,
      updatedAt: now,
    );
  }

  Chantier copyWith({
    String? nom,
    String? description,
    String? clientId,
    String? clientNom,
    String? adresse,
    String? ville,
    ChantierStatus? statut,
    DateTime? dateDebut,
    DateTime? dateFin,
    List<String>? photos,
    List<ChecklistItem>? checklist,
    String? notes,
    String? signatureBase64,
    Duration? tempsPasse,
    double? budget,
  }) {
    return Chantier(
      id: id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      clientId: clientId ?? this.clientId,
      clientNom: clientNom ?? this.clientNom,
      adresse: adresse ?? this.adresse,
      ville: ville ?? this.ville,
      statut: statut ?? this.statut,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      photos: photos ?? this.photos,
      checklist: checklist ?? this.checklist,
      notes: notes ?? this.notes,
      signatureBase64: signatureBase64 ?? this.signatureBase64,
      tempsPasse: tempsPasse ?? this.tempsPasse,
      budget: budget ?? this.budget,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'description': description,
        'clientId': clientId,
        'clientNom': clientNom,
        'adresse': adresse,
        'ville': ville,
        'statut': statut.index,
        'dateDebut': dateDebut.toIso8601String(),
        'dateFin': dateFin?.toIso8601String(),
        'photos': photos,
        'checklist': checklist.map((c) => c.toJson()).toList(),
        'notes': notes,
        'signatureBase64': signatureBase64,
        'tempsPasse': tempsPasse.inSeconds,
        'budget': budget,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Chantier.fromJson(Map<String, dynamic> json) => Chantier(
        id: json['id'] as String,
        nom: json['nom'] as String,
        description: json['description'] as String?,
        clientId: json['clientId'] as String?,
        clientNom: json['clientNom'] as String?,
        adresse: json['adresse'] as String?,
        ville: json['ville'] as String?,
        statut: ChantierStatus.values[json['statut'] as int? ?? 0],
        dateDebut: DateTime.parse(json['dateDebut'] as String),
        dateFin: json['dateFin'] != null
            ? DateTime.parse(json['dateFin'] as String)
            : null,
        photos: (json['photos'] as List?)?.cast<String>() ?? [],
        checklist: (json['checklist'] as List?)
                ?.map((c) =>
                    ChecklistItem.fromJson(Map<String, dynamic>.from(c)))
                .toList() ??
            [],
        notes: json['notes'] as String?,
        signatureBase64: json['signatureBase64'] as String?,
        tempsPasse:
            Duration(seconds: json['tempsPasse'] as int? ?? 0),
        budget: (json['budget'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  @override
  List<Object?> get props => [
        id, nom, description, clientId, clientNom, adresse, ville,
        statut, dateDebut, dateFin, photos, checklist, notes,
        signatureBase64, tempsPasse, budget, createdAt, updatedAt,
      ];
}

class ChecklistItem extends Equatable {
  final String id;
  final String libelle;
  final bool isDone;

  const ChecklistItem({
    required this.id,
    required this.libelle,
    this.isDone = false,
  });

  factory ChecklistItem.create(String libelle) {
    return ChecklistItem(
      id: const Uuid().v4(),
      libelle: libelle,
    );
  }

  ChecklistItem copyWith({bool? isDone}) {
    return ChecklistItem(
      id: id,
      libelle: libelle,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'libelle': libelle,
        'isDone': isDone,
      };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) =>
      ChecklistItem(
        id: json['id'] as String,
        libelle: json['libelle'] as String,
        isDone: json['isDone'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, libelle, isDone];
}
