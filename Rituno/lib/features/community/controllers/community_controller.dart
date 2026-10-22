import 'package:flutter/foundation.dart';
import '../models/tournament_model.dart';
import '../../../core/services/storage_service.dart';

class CommunityFeedItem {
  final String author;
  final String action;
  final String habit;
  final String timeAgo;
  final int streak;

  const CommunityFeedItem({
    required this.author,
    required this.action,
    required this.habit,
    required this.timeAgo,
    required this.streak,
  });
}

class CommunityController {
  final StorageService _storageService;
  final ValueNotifier<List<TournamentModel>> tournamentsNotifier =
      ValueNotifier<List<TournamentModel>>([]);

  final List<CommunityFeedItem> feedItems = const [
    CommunityFeedItem(
      author: 'Ahmet Y.',
      action: '20. gün serisini tamamladı!',
      habit: '30 Gün Kodlama',
      timeAgo: '12 dk önce',
      streak: 20,
    ),
    CommunityFeedItem(
      author: 'Gamze T.',
      action: 'turnuvada 1. sıraya yükseldi 🏆',
      habit: 'Haftalık Su Challenge',
      timeAgo: '35 dk önce',
      streak: 7,
    ),
    CommunityFeedItem(
      author: 'Selin D.',
      action: 'yeni bir alışkanlık serisine başladı 🔥',
      habit: 'Sabah Meditasyonu',
      timeAgo: '1 saat önce',
      streak: 3,
    ),
    CommunityFeedItem(
      author: 'Caner K.',
      action: 'Gelişmiş Rozeti kazandı! 🎖️',
      habit: '20 Sayfa Kitap Oku',
      timeAgo: '3 saat önce',
      streak: 14,
    ),
  ];

  CommunityController(this._storageService) {
    _loadTournaments();
  }

  void _loadTournaments() {
    tournamentsNotifier.value = _storageService.loadTournaments();
  }

  Future<void> toggleJoinTournament(String tournamentId) async {
    final updated = tournamentsNotifier.value.map((t) {
      if (t.id == tournamentId) {
        final willJoin = !t.isJoined;
        return t.copyWith(
          isJoined: willJoin,
          participantCount: willJoin ? t.participantCount + 1 : t.participantCount - 1,
        );
      }
      return t;
    }).toList();

    tournamentsNotifier.value = updated;
    await _storageService.saveTournaments(updated);
  }

  void dispose() {
    tournamentsNotifier.dispose();
  }
}
