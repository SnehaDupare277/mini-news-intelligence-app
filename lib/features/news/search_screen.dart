import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/article.dart';
import 'news_providers.dart';
import 'article_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Article> _results = [];
  bool _loading = false;
  String? _error;

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      if (value.trim().length < 2) {
        if (mounted) setState(() { _results = []; _error = null; _loading = false; });
        return;
      }
      setState(() { _loading = true; _error = null; });
      try {
        final rows = await ref.read(newsApiProvider).search(value.trim());
        if (mounted) setState(() => _results = rows);
      } catch (e) { if (mounted) setState(() => _error = e.toString()); }
      finally { if (mounted) setState(() => _loading = false); }
    });
  }

  @override
  void dispose() { _debounce?.cancel(); _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Find a story', style: TextStyle(fontWeight: FontWeight.w800))),
    body: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(18, 8, 18, 14), child: TextField(
        controller: _controller, onChanged: _search,
        decoration: InputDecoration(hintText: 'Search business, tech, markets…', prefixIcon: const Icon(Icons.search_rounded), suffixIcon: IconButton(onPressed: () { _controller.clear(); _search(''); }, icon: const Icon(Icons.close_rounded))),
      )),
      if (_loading) const LinearProgressIndicator(minHeight: 2),
      if (_error != null) Padding(padding: const EdgeInsets.all(20), child: Text(_error!, textAlign: TextAlign.center)),
      Expanded(child: _results.isEmpty
        ? Center(child: Text(_loading ? 'Looking for stories…' : 'Search for a topic, company, or idea.', style: const TextStyle(color: Color(0xFF7B8492))))
        : ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: _results.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final a = _results[i];
            return Card(child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              title: Text(a.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Padding(padding: const EdgeInsets.only(top: 7), child: Text(a.source)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: a))),
            ));
          },
        )),
    ]),
  );
}
