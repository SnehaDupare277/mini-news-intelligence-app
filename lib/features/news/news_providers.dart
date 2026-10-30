import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/article.dart';
import '../../core/services/news_api.dart';
import '../../core/storage/local_storage.dart';

final newsApiProvider = Provider<NewsApi>((ref) => NewsApi());

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<Article>>(
  (ref) => FavoritesNotifier(),
);

class FavoritesNotifier extends StateNotifier<List<Article>> {
  FavoritesNotifier() : super(_readSaved());

  static List<Article> _readSaved() {
    return LocalStorage.favorites.values.map(Article.fromMap).toList();
  }

  bool contains(Article article) => state.any((item) => item.url == article.url);

  void toggle(Article article) {
    final box = LocalStorage.favorites;
    if (contains(article)) {
      final key = box.keys.firstWhere((key) => box.get(key)?['url'] == article.url);
      box.delete(key);
      state = state.where((item) => item.url != article.url).toList();
    } else {
      box.put(article.url, article.toMap());
      state = [...state, article];
    }
  }
}
