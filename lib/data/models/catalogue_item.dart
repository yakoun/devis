import 'package:equatable/equatable.dart';
import '../../core/utils/enums.dart';

class CatalogueItem extends Equatable {
  final String id;
  final String nom;
  final String? description;
  final double prixUnitaire;
  final String categorie;
  final Unite unite;
  final String? reference;
  final String? marque;
  final int stock;
  final String? imageUrl;
  final bool isActive;
  final double? tva;

  const CatalogueItem({
    required this.id,
    required this.nom,
    this.description,
    required this.prixUnitaire,
    required this.categorie,
    required this.unite,
    this.reference,
    this.marque,
    this.stock = 0,
    this.imageUrl,
    this.isActive = true,
    this.tva,
  });

  CatalogueItem copyWith({
    String? nom,
    String? description,
    double? prixUnitaire,
    String? categorie,
    Unite? unite,
    String? reference,
    String? marque,
    int? stock,
    String? imageUrl,
    bool? isActive,
    double? tva,
  }) {
    return CatalogueItem(
      id: id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      categorie: categorie ?? this.categorie,
      unite: unite ?? this.unite,
      reference: reference ?? this.reference,
      marque: marque ?? this.marque,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      tva: tva ?? this.tva,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'description': description,
        'prixUnitaire': prixUnitaire,
        'categorie': categorie,
        'unite': unite.index,
        'reference': reference,
        'marque': marque,
        'stock': stock,
        'imageUrl': imageUrl,
        'isActive': isActive,
        'tva': tva,
      };

  factory CatalogueItem.fromJson(Map<String, dynamic> json) => CatalogueItem(
        id: json['id'] as String,
        nom: json['nom'] as String,
        description: json['description'] as String?,
        prixUnitaire: (json['prixUnitaire'] as num).toDouble(),
        categorie: json['categorie'] as String,
        unite: Unite.values[json['unite'] as int? ?? 0],
        reference: json['reference'] as String?,
        marque: json['marque'] as String?,
        stock: json['stock'] as int? ?? 0,
        imageUrl: json['imageUrl'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        tva: (json['tva'] as num?)?.toDouble(),
      );

  @override
  List<Object?> get props => [
        id, nom, description, prixUnitaire, categorie, unite,
        reference, marque, stock, imageUrl, isActive, tva,
      ];
}
