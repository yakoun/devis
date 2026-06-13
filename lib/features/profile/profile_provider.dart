import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:devis/data/repositories/hive_repository.dart';
import 'package:devis/data/providers/providers.dart';

class UserProfile {
  final String id;
  final String nom;
  final String role;
  final String? avatar;
  final bool isActive;

  const UserProfile({
    required this.id,
    required this.nom,
    this.role = 'Technicien',
    this.avatar,
    this.isActive = false,
  });

  UserProfile copyWith({
    String? nom,
    String? role,
    String? avatar,
    bool? isActive,
  }) {
    return UserProfile(
      id: id,
      nom: nom ?? this.nom,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'role': role,
        'avatar': avatar,
        'isActive': isActive,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        nom: json['nom'] as String,
        role: json['role'] as String? ?? 'Technicien',
        avatar: json['avatar'] as String?,
        isActive: json['isActive'] as bool? ?? false,
      );
}

class ProfileNotifier extends StateNotifier<List<UserProfile>> {
  final HiveRepository _repo;

  ProfileNotifier(this._repo) : super([]) {
    _load();
  }

  Future<void> _load() async {
    try {
      final json = await _repo.getSetting('profiles');
      if (json != null && json.isNotEmpty) {
        final list = (jsonDecode(json) as List)
            .map((e) => UserProfile.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        state = list;
      } else {
        // Create default profile
        state = [
          const UserProfile(id: 'default', nom: 'Technicien', isActive: true),
        ];
        await _save();
      }
    } catch (_) {
      state = [
        const UserProfile(id: 'default', nom: 'Technicien', isActive: true),
      ];
    }
  }

  Future<void> _save() async {
    await _repo.setSetting('profiles', jsonEncode(state.map((p) => p.toJson()).toList()));
  }

  UserProfile? get activeProfile {
    try {
      return state.firstWhere((p) => p.isActive);
    } catch (_) {
      return null;
    }
  }

  Future<void> addProfile(String nom, {String role = 'Technicien'}) async {
    final profile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nom: nom,
      role: role,
    );
    state = [...state, profile];
    await _save();
  }

  Future<void> switchProfile(String id) async {
    state = state.map((p) => p.copyWith(isActive: p.id == id)).toList();
    await _save();
  }

  Future<void> deleteProfile(String id) async {
    if (state.length <= 1) return;
    state = state.where((p) => p.id != id).toList();
    if (activeProfile == null && state.isNotEmpty) {
      state = [state.first.copyWith(isActive: true)];
    }
    await _save();
  }

  Future<void> updateProfile(String id, {String? nom, String? role}) async {
    state = state.map((p) {
      if (p.id == id) return p.copyWith(nom: nom, role: role);
      return p;
    }).toList();
    await _save();
  }
}

final profilesProvider = StateNotifierProvider<ProfileNotifier, List<UserProfile>>((ref) {
  final repo = ref.read(hiveRepositoryProvider);
  return ProfileNotifier(repo);
});

final activeProfileProvider = Provider<UserProfile?>((ref) {
  final profiles = ref.watch(profilesProvider);
  try {
    return profiles.firstWhere((p) => p.isActive);
  } catch (_) {
    return null;
  }
});
