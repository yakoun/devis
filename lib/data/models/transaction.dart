import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/enums.dart';

class Transaction extends Equatable {
  final String id;
  final String libelle;
  final double montant;
  final String categorie;
  final DateTime date;
  final bool isDepense;
  final String? factureId;
  final PaiementMode modePaiement;
  final String? notes;

  const Transaction({
    required this.id,
    required this.libelle,
    required this.montant,
    required this.categorie,
    required this.date,
    required this.isDepense,
    this.factureId,
    this.modePaiement = PaiementMode.especes,
    this.notes,
  });

  factory Transaction.create({
    required String libelle,
    required double montant,
    required String categorie,
    required bool isDepense,
    String? factureId,
    PaiementMode modePaiement = PaiementMode.especes,
    String? notes,
  }) {
    return Transaction(
      id: const Uuid().v4(),
      libelle: libelle,
      montant: montant,
      categorie: categorie,
      date: DateTime.now(),
      isDepense: isDepense,
      factureId: factureId,
      modePaiement: modePaiement,
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'libelle': libelle,
        'montant': montant,
        'categorie': categorie,
        'date': date.toIso8601String(),
        'isDepense': isDepense,
        'factureId': factureId,
        'modePaiement': modePaiement.index,
        'notes': notes,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      Transaction(
        id: json['id'] as String,
        libelle: json['libelle'] as String,
        montant: (json['montant'] as num).toDouble(),
        categorie: json['categorie'] as String,
        date: DateTime.parse(json['date'] as String),
        isDepense: json['isDepense'] as bool,
        factureId: json['factureId'] as String?,
        modePaiement:
            PaiementMode.values[json['modePaiement'] as int? ?? 0],
        notes: json['notes'] as String?,
      );

  @override
  List<Object?> get props => [
        id, libelle, montant, categorie, date, isDepense,
        factureId, modePaiement, notes,
      ];
}
