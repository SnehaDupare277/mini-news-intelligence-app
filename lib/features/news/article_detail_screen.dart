import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/article.dart';
import 'news_providers.dart';

class ArticleDetailScreen extends ConsumerWidget {
  const ArticleDetailScreen({super.key, required this.article});
  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(favoritesProvider).any((a) => a.url == article.url);
    return Scaffold(
      appBar: AppBar(
        title: const Text('The story', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [IconButton(
          tooltip: saved ? 'Remove favorite' : 'Save favorite',
          onPressed: () {
            ref.read(favoritesProvider.notifier).toggle(article);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(saved ? 'Removed from saved stories' : 'Saved for later')));
          },
          icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
        ), const SizedBox(width: 8)],
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 30), children: [
        if (article.imageUrl != null && article.imageUrl!.startsWith('http'))
          ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.network(article.imageUrl!, height: 230, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink())),
        const SizedBox(height: 22),
        Text(article.source.toUpperCase(), style: const TextStyle(color: Color(0xFF315CBA), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.3)),
        const SizedBox(height: 10),
        Text(article.title, style: const TextStyle(fontSize: 28, height: 1.2, fontWeight: FontWeight.w900, color: Color(0xFF17243A), letterSpacing: -0.6)),
        const SizedBox(height: 14),
        Text(article.description, style: const TextStyle(fontSize: 17, height: 1.5, color: Color(0xFF526075))),
        const SizedBox(height: 22),
        const Divider(),
        const SizedBox(height: 16),
        Text(article.content ?? 'The source has not provided additional article text. Use the original publisher link for the complete story.', style: const TextStyle(fontSize: 16, height: 1.7, color: Color(0xFF39465A))),
        const SizedBox(height: 26),
        OutlinedButton.icon(
          onPressed: article.url.isEmpty ? null : () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open the original story URL in your browser to read the publisher’s full article.'))),
          icon: const Icon(Icons.open_in_new_rounded), label: const Text('Original publisher link'),
        ),
        const SizedBox(height: 10),
        const Text('News summaries and article availability depend on the publisher and API plan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Color(0xFF7B8492))),
      ]),
    );
  }
}
