import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/favorite_route.dart';

/// In-memory storage service (consistent with the mock-data approach).
/// Persists across the app session. Replace with SharedPreferences/SQLite
/// when a real backend is added.
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final List<FavoriteRoute> _favorites = [];
  final List<TripHistoryEntry> _history = [];
  final List<CrowdReport> _crowdReports = [];
  final List<DelayReport> _delayReports = [];
  bool _darkMode = false;

  Future<void> init() async {
    // Reserved for future persistence layer (SharedPreferences/SQLite)
  }

  // Favorites
  List<FavoriteRoute> getFavorites() => List.unmodifiable(_favorites);

  void addFavorite(FavoriteRoute fav) {
    if (!_favorites.any(
        (f) => f.originId == fav.originId && f.destinationId == fav.destinationId)) {
      _favorites.add(fav);
    }
  }

  void removeFavorite(String id) {
    _favorites.removeWhere((f) => f.id == id);
  }

  bool isFavorited(String originId, String destinationId) {
    return _favorites.any(
        (f) => f.originId == originId && f.destinationId == destinationId);
  }

  // Trip history
  List<TripHistoryEntry> getTripHistory() => List.unmodifiable(_history);

  void addToHistory(TripHistoryEntry entry) {
    _history.insert(0, entry);
    if (_history.length > 50) _history.removeRange(50, _history.length);
  }

  // Crowd reports
  List<CrowdReport> getCrowdReports() => List.unmodifiable(_crowdReports);
  void addCrowdReport(CrowdReport report) => _crowdReports.add(report);

  // Delay reports
  List<DelayReport> getDelayReports() => List.unmodifiable(_delayReports);
  void addDelayReport(DelayReport report) => _delayReports.add(report);

  // Dark mode
  void setDarkMode(bool value) => _darkMode = value;
  bool getDarkMode() => _darkMode;
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final favoritesProvider = StateProvider<List<FavoriteRoute>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getFavorites();
});

final tripHistoryProvider = StateProvider<List<TripHistoryEntry>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getTripHistory();
});

final darkModeProvider = StateProvider<bool>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getDarkMode();
});
