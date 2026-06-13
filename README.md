# YTech Pro

Application ERP complète offline-first pour artisans et PMEs. Gestion des devis, factures, clients, chantiers, catalogue, finances, avec templates PDF premium, impression Bluetooth, et partage WhatsApp.

## Stack

- **Flutter 3.44** — Dart 3.12
- **Riverpod** — State management (sans code generation)
- **GoRouter** — Navigation avec ShellRoute responsive (mobile/desktop)
- **Hive** — Stockage local offline-first
- **Material 3** — Design system premium SaaS
- **fl_chart** — Graphiques financiers
- **pdf / printing** — Génération PDF premium
- **share_plus** — Partage PDF
- **flutter_local_notifications + workmanager** — Notifications périodiques
- **local_auth** — Biométrie (empreinte/visage)
- **crypto** — SHA-256 pour code PIN

## Architecture

```
lib/
├── core/
│   ├── constants/        # AppConstants
│   ├── extensions/       # Date, num, context, responsive, accessibility
│   ├── router/           # GoRouter + MainShell responsive
│   ├── utils/            # Enums (FactureStatus, PaiementMode, etc.)
│   └── widgets/          # CalendarWidget, SearchableList, PaginatedListView, ExportImportDialog
├── data/
│   ├── models/           # Client, Devis, Facture, Chantier, Transaction, CatalogueItem,
│   │                     # TechnicienInfo, AppSettings (22 champs)
│   ├── providers/        # Riverpod providers + SettingsNotifier
│   └── repositories/     # HiveRepository singleton
├── design_system/
│   ├── tokens/           # Couleurs, typographie, espacements, ombres, dégradés
│   ├── widgets/          # PremiumAppBar, ElectricCard, GlowButton, PremiumTextField,
│   │                     # StatusBadge, QuantumBackground, AnimatedStepIndicator, etc.
│   └── theme.dart        # Thème dark/light premium
├── features/             # Feature First
│   ├── dashboard/        # Dashboard quantique (KPI, charts, timeline, insights IA)
│   ├── devis/            # CRUD + édition après enregistrement + PDF premium
│   ├── facture/          # Liste, détail, PDF premium, suivi paiement
│   ├── client/           # CRUD
│   ├── catalogue/        # 160+ items pré-seedés par catégorie
│   ├── chantier/         # Timer Pomodoro, checklist, photos, calendrier
│   ├── finance/          # Graphiques fl_chart
│   ├── parametres/       # 7 sections (Entreprise, Application, Modules, Devis&PDF,
│   │                     #   Sécurité, Notifications, Données)
│   ├── profile/          # Multi-utilisateur (ProfileNotifier)
│   ├── splash/           # Animé
│   ├── setup/            # Assistant 6 étapes
│   ├── activity/         # Journal d'activité
│   └── auth/             # Verrouillage PIN
├── services/
│   ├── invoice_pdf_template.dart  # Template PDF premium unifié (devis + facture)
│   ├── pdf_receipt_template.dart  # Template reçu de paiement
│   ├── pdf_service.dart           # Service PDF legacy
│   ├── bluetooth_service.dart     # Impression Bluetooth ESC/POS
│   ├── notification_service.dart  # Notifications enrichies
│   ├── backup_service.dart        # Export/Import JSON, CSV
│   └── auth_service.dart          # PIN hashé SHA-256, biométrie
└── main.dart
```

## Navigation

- **Barre inférieure mobile** : 2 onglets (Dashboard, Catalogue)
- **Desktop** : Rail latéral avec les mêmes 2 entrées
- **FAB central** : Menu d'actions rapides responsive (GridView 3-4 colonnes)
  - Nouveau devis, facture, client, chantier
  - Finance, paramètres, catalogue, activité

## Fonctionnalités

### Gestion commerciale
- ✅ Création/édition devis avec TVA, remise
- ✅ **Édition des devis après enregistrement** (menu → Modifier)
- ✅ Conversion devis → facture
- ✅ Factures avec suivi partiel/paiement
- ✅ 160+ items catalogue pré-seedés par catégorie
- ✅ Duplication de devis

### Templates PDF Premium
- ✅ **InvoicePdfTemplate** — Template unifié devis + facture
  - Header avec logo configurable
  - Badge statut coloré (accepté/refusé/brouillon)
  - Cartes client & technicien
  - Tableau alterné (lignes paires/grises)
  - Totaux avec fond sombre
  - Signature configurable
  - Footer coordonnées entreprise
  - Numéros de page
- ✅ **PdfReceiptTemplate** — Reçu de paiement
- ✅ Partage PDF (share_plus)
- ✅ Aperçu PDF (printing)
- ✅ Impression Bluetooth (ESC/POS)

### Paramètres (7 sections)
- **Entreprise** : Upload logo, nom, slogan, téléphone, email, adresse, N° fiscal
- **Application** : Thème (dark/light), sécurité PIN, notifications
- **Modules** : TVA activable
- **Devis & PDF** : Marges PDF, affichage logo/signature, devise
- **Données** : Export/Import JSON backup, Export CSV
- **À propos** : Version app

### Gestion terrain
- ✅ Chantiers avec chronomètre Pomodoro
- ✅ Checklist dynamique
- ✅ Photos chantier
- ✅ Calendrier de planification
- ✅ Statuts (planifié, en cours, pause, terminé)

### Interface quantique
- ✅ Dashboard premium (KPI animés, bar/line/pie charts, timeline)
- ✅ QuantumBackground (grille animée + particules)
- ✅ Thème dark/light premium
- ✅ Animations onboarding

### Qualité & Performance
- ✅ Recherche textuelle (SearchableList)
- ✅ Pagination infinie
- ✅ Lazy loading Hive
- ✅ Accessibilité (Semantics)
- ✅ BreakpointBuilder responsive (mobile/tablet/desktop)
- ✅ 24 tests unitaires (models, repository)
- ✅ **0 erreurs flutter analyze**

### Sécurité & Données
- ✅ Code PIN hashé (SHA-256)
- ✅ Biométrie (empreinte/visage)
- ✅ Export/Import JSON backup
- ✅ Export CSV (clients, devis, factures)
- ✅ Backup partageable
- ✅ Multi-profil utilisateur (ProfileNotifier)

### Notifications
- ✅ Devis en attente (>7 jours)
- ✅ Factures impayées/échéance
- ✅ Chantier sans activité (>3 jours)
- ✅ Devis expiré
- ✅ Notifications enrichies (payload, vibration, son)
- ✅ WorkManager périodique (1h)

## Installation

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
flutter test test/models/
flutter test test/repositories/
```

## Build

```bash
flutter build apk --release
flutter build apk --split-per-abi
```

## Analyse

```bash
flutter analyze
# 0 errors
```

## Licence

Propriétaire — YTech Pro
