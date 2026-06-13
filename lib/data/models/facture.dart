import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/enums.dart';
import 'devis.dart';

class Facture extends Equatable {
  final String id;
  final String numero;
  final String? devisId;
  final String clientId;
  final String clientNom;
  final List<LigneDevis> items;
  final double remise;
  final double tva;
  final double sousTotal;
  final double montantTva;
  final double total;
  final double montantPaye;
  final FactureStatus statut;
  final PaiementMode? modePaiement;
  final DateTime dateEmission;
  final DateTime dateEcheance;
  final DateTime? datePaiement;
  final String? notes;
  final DateTime updatedAt;

  const Facture({
    required this.id,
    required this.numero,
    this.devisId,
    required this.clientId,
    required this.clientNom,
    required this.items,
    this.remise = 0,
    this.tva = 18.0,
    required this.sousTotal,
    required this.montantTva,
    required this.total,
    this.montantPaye = 0,
    this.statut = FactureStatus.impayee,
    this.modePaiement,
    required this.dateEmission,
    required this.dateEcheance,
    this.datePaiement,
    this.notes,
    required this.updatedAt,
  });

  static int _factureSeq = 0;

  factory Facture.fromDevis(Devis devis) {
    final now = DateTime.now();
    _factureSeq++;
    return Facture(
      id: const Uuid().v4(),
      numero: 'FAC-${now.year}-${_factureSeq.toString().padLeft(4, '0')}',
      devisId: devis.id,
      clientId: devis.client.contact,
      clientNom: devis.client.nomComplet,
      items: devis.lignes,
      sousTotal: devis.totalAchat.toDouble(),
      montantTva: 0,
      total: devis.netAPayer.toDouble(),
      dateEmission: now,
      dateEcheance: now.add(const Duration(days: 30)),
      updatedAt: now,
    );
  }

  factory Facture.create({
    required String clientId,
    required String clientNom,
    required List<LigneDevis> items,
    double remise = 0,
    double tva = 18.0,
    String? notes,
    String? devisId,
  }) {
    final now = DateTime.now();
    _factureSeq++;
    final sousTotal = items.fold<int>(0, (sum, item) => sum + item.prixTotal).toDouble();
    final montantTva = sousTotal * (tva / 100);
    final total = sousTotal - remise + montantTva;

    return Facture(
      id: const Uuid().v4(),
      numero: 'FAC-${now.year}-${_factureSeq.toString().padLeft(4, '0')}',
      devisId: devisId,
      clientId: clientId,
      clientNom: clientNom,
      items: items,
      remise: remise,
      tva: tva,
      sousTotal: sousTotal,
      montantTva: montantTva,
      total: total,
      dateEmission: now,
      dateEcheance: now.add(const Duration(days: 30)),
      notes: notes,
      updatedAt: now,
    );
  }

  Facture copyWith({
    double? montantPaye,
    FactureStatus? statut,
    PaiementMode? modePaiement,
    DateTime? datePaiement,
    String? notes,
    DateTime? dateEcheance,
  }) {
    return Facture(
      id: id,
      numero: numero,
      devisId: devisId,
      clientId: clientId,
      clientNom: clientNom,
      items: items,
      remise: remise,
      tva: tva,
      sousTotal: sousTotal,
      montantTva: montantTva,
      total: total,
      montantPaye: montantPaye ?? this.montantPaye,
      statut: statut ?? this.statut,
      modePaiement: modePaiement ?? this.modePaiement,
      dateEmission: dateEmission,
      dateEcheance: dateEcheance ?? this.dateEcheance,
      datePaiement: datePaiement ?? this.datePaiement,
      notes: notes ?? this.notes,
      updatedAt: DateTime.now(),
    );
  }

  double get restantDu => total - montantPaye;

  Map<String, dynamic> toJson() => {
        'id': id,
        'numero': numero,
        'devisId': devisId,
        'clientId': clientId,
        'clientNom': clientNom,
        'items': items.map((i) => i.toJson()).toList(),
        'remise': remise,
        'tva': tva,
        'sousTotal': sousTotal,
        'montantTva': montantTva,
        'total': total,
        'montantPaye': montantPaye,
        'statut': statut.index,
        'modePaiement': modePaiement?.index,
        'dateEmission': dateEmission.toIso8601String(),
        'dateEcheance': dateEcheance.toIso8601String(),
        'datePaiement': datePaiement?.toIso8601String(),
        'notes': notes,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Facture.fromJson(Map<String, dynamic> json) => Facture(
        id: json['id'] as String,
        numero: json['numero'] as String,
        devisId: json['devisId'] as String?,
        clientId: json['clientId'] as String,
        clientNom: json['clientNom'] as String,
        items: (json['items'] as List)
            .map((i) =>
                LigneDevis.fromJson(Map<String, dynamic>.from(i)))
            .toList(),
        remise: (json['remise'] as num).toDouble(),
        tva: (json['tva'] as num).toDouble(),
        sousTotal: (json['sousTotal'] as num).toDouble(),
        montantTva: (json['montantTva'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        montantPaye: (json['montantPaye'] as num?)?.toDouble() ?? 0,
        statut: FactureStatus.values[json['statut'] as int? ?? 0],
        modePaiement: json['modePaiement'] != null
            ? PaiementMode.values[json['modePaiement'] as int]
            : null,
        dateEmission: DateTime.parse(json['dateEmission'] as String),
        dateEcheance: DateTime.parse(json['dateEcheance'] as String),
        datePaiement: json['datePaiement'] != null
            ? DateTime.parse(json['datePaiement'] as String)
            : null,
        notes: json['notes'] as String?,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  @override
  List<Object?> get props => [
        id, numero, devisId, clientId, clientNom, items, remise, tva,
        sousTotal, montantTva, total, montantPaye, statut, modePaiement,
        dateEmission, dateEcheance, datePaiement, notes, updatedAt,
      ];
}
