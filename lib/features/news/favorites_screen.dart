import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'news_providers.dart';
import 'article_detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(favoritesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Saved stories', style: TextStyle(fontWeight: FontWeight.w800))),
      body: articles.isEmpty
        ? const Center(child: Padding(
            padding: EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.bookmark_border_rounded, size: 46, color: Color(0xFF9AA3B1)),
              SizedBox(height: 14),
              Text('Keep the good ones close.', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              SizedBox(height: 7),
              Text('Stories you bookmark will appear here, even when you’re offline.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF7B8492))),
            ]),
          ))
        : ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: articles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final a = articles[i];
              return Card(child: ListTile(
                title: Text(a.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(a.source)),
                trailing: IconButton(icon: const Icon(Icons.bookmark_remove_outlined), onPressed: () => ref.read(favoritesProvider.notifier).toggle(a)),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: a))),
              ));
            },
          ),
    );
  }
}
