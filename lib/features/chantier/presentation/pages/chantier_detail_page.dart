import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/core/extensions/date_extensions.dart';
import 'package:devis/core/extensions/context_extensions.dart';
import 'package:devis/core/utils/enums.dart';
import 'package:devis/core/widgets/calendar_widget.dart';
import 'package:devis/data/models/chantier.dart';
import 'package:devis/data/providers/providers.dart';
import 'package:devis/data/repositories/hive_repository.dart';

class ChantierDetailPage extends ConsumerStatefulWidget {
  final String chantierId;
  const ChantierDetailPage({super.key, required this.chantierId});

  @override
  ConsumerState<ChantierDetailPage> createState() => _ChantierDetailPageState();
}

class _ChantierDetailPageState extends ConsumerState<ChantierDetailPage> {
  final _imagePicker = ImagePicker();
  Duration _elapsed = Duration.zero;
  bool _isTimerRunning = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimerIfNeeded();
  }

  void _startTimerIfNeeded() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isTimerRunning) {
        setState(() => _elapsed = _elapsed + const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chantierAsync = ref.watch(chantierProviderById(widget.chantierId));

    return chantierAsync.when(
      loading: () => Scaffold(
        appBar: PremiumAppBar(title: 'Chargement...', isDark: isDark),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: PremiumAppBar(title: 'Erreur', isDark: isDark),
        body: Center(child: Text('Erreur: $e')),
      ),
      data: (chantier) {
        if (chantier == null) {
          return Scaffold(
            appBar: PremiumAppBar(title: 'Chantier introuvable', isDark: isDark),
            body: const Center(child: Text('Chantier introuvable')),
          );
        }
        final c = chantier;
        return Scaffold(
          appBar: PremiumAppBar(
            title: c.nom,
            isDark: isDark,
            actions: [
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'photo', child: Text('Prendre photo')),
                  const PopupMenuItem(value: 'checklist', child: Text('Checklist')),
                  const PopupMenuItem(value: 'signature', child: Text('Signature')),
                  const PopupMenuItem(value: 'rapport', child: Text('Rapport PDF')),
                ],
                onSelected: (value) async {
                  if (value == 'photo') {
                    try {
                      final photo = await _imagePicker.pickImage(
                          source: ImageSource.camera);
                      if (photo != null) {
                        final repo = ref.read(hiveRepositoryProvider);
                        final updated = c.copyWith(
                          photos: [...c.photos, photo.path],
                        );
                        await repo.saveChantier(updated);
                        ref.invalidate(chantierProviderById(widget.chantierId));
                        ref.invalidate(chantiersProvider);
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      context.showSnackBar('Erreur photo: $e');
                    }
                  }
                  if (value == 'checklist') {
                    _showChecklistDialog(context, c, ref.read(hiveRepositoryProvider));
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(c, isDark),
                const SizedBox(height: 16),
                _buildCalendarSection(c, isDark),
                const SizedBox(height: 16),
                _buildTimerCard(c, isDark, ref.read(hiveRepositoryProvider)),
                const SizedBox(height: 16),
                _buildPhotosSection(c, isDark),
                const SizedBox(height: 16),
                _buildChecklistSection(c, isDark),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(Chantier c, bool isDark) {
    return ElectricCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Statut', style: AppTypography.caption),
              DropdownButton<ChantierStatus>(
                value: c.statut,
                underline: const SizedBox(),
                items: ChantierStatus.values.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: StatusBadge(label: s.name, color: AppColors.electricBlue),
                  );
                }).toList(),
                onChanged: (v) async {
                  if (v != null) {
                    try {
                      final repo = ref.read(hiveRepositoryProvider);
                      await repo.saveChantier(c.copyWith(statut: v));
                      ref.invalidate(chantierProviderById(widget.chantierId));
                      ref.invalidate(chantiersProvider);
                    } catch (e) {
                      if (!context.mounted) return;
                      context.showSnackBar('Erreur: $e');
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (c.description != null) ...[
            Text(c.description!, style: AppTypography.bodyMedium),
            const SizedBox(height: 8),
          ],
          _buildInfoRow(Icons.location_on_rounded, c.adresse ?? 'Non définie'),
          _buildInfoRow(Icons.calendar_today_rounded, c.dateDebut.formatted),
          if (c.clientNom != null)
            _buildInfoRow(Icons.person_rounded, c.clientNom!),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(Chantier c, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Calendrier',
          actionLabel: 'Planifier',
          onAction: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Planifier le chantier'),
                content: CalendarWidget(
                  selectedDate: c.dateDebut,
                  onDateSelected: (date) async {
                    final repo = ref.read(hiveRepositoryProvider);
                    await repo.saveChantier(c.copyWith(dateDebut: date));
                    ref.invalidate(chantierProviderById(widget.chantierId));
                    ref.invalidate(chantiersProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CalendarWidget(
            selectedDate: c.dateDebut,
            events: {
              c.dateDebut: [
                CalendarEvent(title: c.nom, date: c.dateDebut),
              ],
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimerCard(Chantier c, bool isDark, HiveRepository repo) {
    return ElectricCard(
      isDark: isDark,
      child: Column(
        children: [
          Text('Chronomètre',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 16),
          Text(
            '${_elapsed.inHours.toString().padLeft(2, '0')}:${(_elapsed.inMinutes % 60).toString().padLeft(2, '0')}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
            style: AppTypography.displaySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.electricBlue,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlowButton(
                label: _isTimerRunning ? 'PAUSE' : 'DÉMARRER',
                icon: _isTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                onPressed: () {
                  setState(() {
                    _isTimerRunning = !_isTimerRunning;
                  });
                },
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final updated = c.copyWith(tempsPasse: c.tempsPasse + _elapsed);
                    await repo.saveChantier(updated);
                    ref.invalidate(chantierProviderById(widget.chantierId));
                    ref.invalidate(chantiersProvider);
                    setState(() => _elapsed = Duration.zero);
                    context.showSnackBar('Temps enregistré');
                  } catch (e) {
                    context.showSnackBar('Erreur: $e');
                  }
                },
                icon: const Icon(Icons.save_rounded),
                label: const Text('Sauvegarder'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection(Chantier c, bool isDark) {
    if (c.photos.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Photos (${c.photos.length})'),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: c.photos.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(c.photos[index]),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 100,
                      color: AppColors.darkSurfaceLight,
                      child: const Icon(Icons.broken_image_rounded, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistSection(Chantier c, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Checklist',
          actionLabel: 'Ajouter',
          onAction: () => _showChecklistDialog(context, c, ref.read(hiveRepositoryProvider)),
        ),
        if (c.checklist.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Aucune tâche',
                style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary)),
          )
        else
          ...c.checklist.map((item) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Checkbox(
                      value: item.isDone,
                      onChanged: (v) async {
                        try {
                          final checklist = c.checklist.map((ci) {
                            return ci.id == item.id
                                ? ci.copyWith(isDone: v)
                                : ci;
                          }).toList();
                          final repo = ref.read(hiveRepositoryProvider);
                          await repo.saveChantier(c.copyWith(checklist: checklist));
                          ref.invalidate(chantierProviderById(widget.chantierId));
                          ref.invalidate(chantiersProvider);
                        } catch (e) {
                          if (!context.mounted) return;
                          context.showSnackBar('Erreur: $e');
                        }
                      },
                      activeColor: AppColors.electricGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.libelle,
                      style: AppTypography.bodyMedium.copyWith(
                        decoration:
                            item.isDone ? TextDecoration.lineThrough : null,
                        color: item.isDone
                            ? AppColors.textSecondary
                            : null,
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  void _showChecklistDialog(
      BuildContext context, Chantier c, HiveRepository repo) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter une tâche'),
        content: PremiumTextField(
          controller: ctrl,
          hint: 'Ex: Vérifier le câblage',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          GlowButton(
            label: 'AJOUTER',
            onPressed: () async {
              if (ctrl.text.isEmpty) return;
              try {
                final item = ChecklistItem.create(ctrl.text);
                final updated =
                    c.copyWith(checklist: [...c.checklist, item]);
                await repo.saveChantier(updated);
                ref.invalidate(chantierProviderById(widget.chantierId));
                ref.invalidate(chantiersProvider);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
              } catch (e) {
                if (!context.mounted) return;
                context.showSnackBar('Erreur: $e');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Semantics(
      label: text,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(text, style: AppTypography.bodySmall),
          ],
        ),
      ),
    );
  }
}
