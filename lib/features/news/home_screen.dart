import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/article.dart';
import '../../core/storage/local_storage.dart';
import '../auth/login_screen.dart';
import 'news_providers.dart';
import 'article_detail_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';

const categories = ['general', 'business', 'technology', 'science', 'health', 'sports'];

class _Palette {
  static const primary = Color(0xFF315CBA);
  static const ink = Color(0xFF17243A);
  static const muted = Color(0xFF6B7484);
  static const border = Color(0xFFDCE1EA);
  static const surface = Color(0xFFF6F8FC);
}

bool _hasImage(Article a) => a.imageUrl != null && a.imageUrl!.startsWith('http');

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _category = 'general';
  int _page = 1;
  int _requestId = 0; // ignores stale responses when the category changes quickly
  List<Article> _articles = [];
  bool _loading = true;
  bool _moreLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    final id = ++_requestId;
    setState(() {
      if (reset) {
        _loading = true;
        _moreLoading = false;
        _error = null;
        _page = 1;
      } else {
        _moreLoading = true;
      }
    });
    try {
      final result = await ref
          .read(newsApiProvider)
          .topHeadlines(category: _category, page: reset ? 1 : _page + 1);
      if (!mounted || id != _requestId) return;
      setState(() {
        _articles = reset ? result : [..._articles, ...result];
        _page = reset ? 1 : _page + 1;
        _error = null;
      });
    } catch (e) {
      if (!mounted || id != _requestId) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      if (reset || _articles.isEmpty) {
        setState(() => _error = message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
        );
      }
    } finally {
      if (mounted && id == _requestId) {
        setState(() {
          _loading = false;
          _moreLoading = false;
        });
      }
    }
  }

  void _selectCategory(String c) {
    if (c == _category) return;
    setState(() {
      _category = c;
      _articles = [];
    });
    _load(reset: true);
  }

  void _open(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Log out?'),
        content: const Text('You can sign back in at any time.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _Palette.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await ref.read(sharedPreferencesProvider).setBool('is_logged_in', false);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.read(sharedPreferencesProvider).getString('display_name') ?? 'Reader';
    final firstName = name.trim().isEmpty ? 'Reader' : name.trim().split(' ').first;

    return Scaffold(
      backgroundColor: _Palette.surface,
      appBar: AppBar(
        backgroundColor: _Palette.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Row(children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A78E0), _Palette.primary],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('Briefly',
              style: TextStyle(
                  fontWeight: FontWeight.w800, letterSpacing: -0.4, color: _Palette.ink)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () => _open(const SearchScreen()),
            icon: const Icon(Icons.search_rounded, color: _Palette.ink),
          ),
          IconButton(
            tooltip: 'Favorites',
            onPressed: () => _open(const FavoritesScreen()),
            icon: const Icon(Icons.bookmark_border_rounded, color: _Palette.ink),
          ),
          PopupMenuButton<String>(
            tooltip: 'Account',
            offset: const Offset(0, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (v) {
              if (v == 'logout') _confirmLogout();
            },
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: _Palette.ink)),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(children: [
                  Icon(Icons.logout_rounded, size: 20),
                  SizedBox(width: 10),
                  Text('Log out'),
                ]),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 16, 0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: _Palette.primary.withOpacity(0.12),
                child: Text(
                  firstName[0].toUpperCase(),
                  style: const TextStyle(
                      color: _Palette.primary, fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _Palette.primary,
        onRefresh: () => _load(reset: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(firstName)),
            ..._buildBody(),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String firstName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          '${_greeting()}, $firstName'.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w800,
              color: _Palette.primary),
        ),
        const SizedBox(height: 8),
        const Text('The bigger picture.',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                color: _Palette.ink)),
        const SizedBox(height: 6),
        const Text('A thoughtful read on what’s happening now.',
            style: TextStyle(color: _Palette.muted, fontSize: 15)),
        const SizedBox(height: 20),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final c = categories[i];
              final selected = c == _category;
              return ChoiceChip(
                label: Text(c[0].toUpperCase() + c.substring(1)),
                selected: selected,
                onSelected: (_) => _selectCategory(c),
                showCheckmark: false,
                selectedColor: _Palette.primary,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: selected ? _Palette.primary : _Palette.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : _Palette.muted,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  List<Widget> _buildBody() {
    if (_loading && _articles.isEmpty) {
      return const [SliverToBoxAdapter(child: _SkeletonList())];
    }
    if (_error != null && _articles.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _StatePanel(
            icon: Icons.wifi_off_rounded,
            title: 'Stories aren’t available yet',
            message: _error!,
            actionLabel: 'Try again',
            onAction: () => _load(reset: true),
          ),
        ),
      ];
    }
    if (_articles.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _StatePanel(
            icon: Icons.newspaper_rounded,
            title: 'No stories found',
            message: 'There’s nothing in this category right now. Check back soon.',
            actionLabel: 'Refresh',
            onAction: () => _load(reset: true),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final a = _articles[index];
              void open() => _open(ArticleDetailScreen(article: a));
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: index == 0
                    ? _HeroCard(article: a, onTap: open)
                    : _ArticleCard(article: a, onTap: open),
              );
            },
            childCount: _articles.length,
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: _moreLoading ? null : () => _load(),
              style: OutlinedButton.styleFrom(
                foregroundColor: _Palette.primary,
                backgroundColor: Colors.white,
                side: const BorderSide(color: _Palette.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _moreLoading
                  ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.2))
                  : const Text('Load more stories',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    ];
  }
}

// ───────────────────────── Cards ─────────────────────────

class _ArticleImage extends StatelessWidget {
  const _ArticleImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) => Image.network(
    url,
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
    frameBuilder: (_, child, frame, __) => AnimatedOpacity(
      opacity: frame == null ? 0 : 1,
      duration: const Duration(milliseconds: 300),
      child: child,
    ),
    errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
  );
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();
  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFFE9EDF5),
    alignment: Alignment.center,
    child: const Icon(Icons.image_outlined, size: 32, color: Color(0xFF9AA4B5)),
  );
}

class _SourceLabel extends StatelessWidget {
  const _SourceLabel(this.text, {this.color = _Palette.primary});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
        color: color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1),
  );
}

/// Large lead story shown at the top of the feed.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.article, required this.onTap});
  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 300,
        child: Material(
          color: _Palette.ink,
          child: InkWell(
            onTap: onTap,
            child: Stack(fit: StackFit.expand, children: [
              if (_hasImage(article)) _ArticleImage(url: article.imageUrl!),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xE617243A)],
                    stops: [0.25, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _Palette.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('TOP STORY',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2)),
                    ),
                    const SizedBox(height: 10),
                    Text(article.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            height: 1.25,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3)),
                    const SizedBox(height: 8),
                    _SourceLabel(article.source, color: Colors.white70),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article, required this.onTap});
  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _Palette.border),
        boxShadow: [
          BoxShadow(
            color: _Palette.ink.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (_hasImage(article))
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _ArticleImage(url: article.imageUrl!),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _SourceLabel(article.source),
                const SizedBox(height: 8),
                Text(article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: _Palette.ink)),
                if (article.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(article.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          height: 1.45, fontSize: 14.5, color: _Palette.muted)),
                ],
                const SizedBox(height: 14),
                const Row(children: [
                  Text('Read story',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _Palette.primary)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: _Palette.primary),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ───────────────────────── States ─────────────────────────

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            color: _Palette.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 34, color: _Palette.primary),
        ),
        const SizedBox(height: 18),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: _Palette.ink)),
        const SizedBox(height: 8),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(height: 1.45, color: _Palette.muted)),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: onAction,
          style: FilledButton.styleFrom(
            backgroundColor: _Palette.primary,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ]),
    ),
  );
}

/// Pulsing placeholder cards shown while the first page loads.
class _SkeletonList extends StatefulWidget {
  const _SkeletonList();
  @override
  State<_SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<_SkeletonList> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _bar(double width, double height) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFFE3E8F1),
      borderRadius: BorderRadius.circular(6),
    ),
  );

  Widget _card() => Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _Palette.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AspectRatio(aspectRatio: 16 / 9, child: Container(color: const Color(0xFFE3E8F1))),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _bar(80, 10),
          const SizedBox(height: 12),
          _bar(double.infinity, 16),
          const SizedBox(height: 8),
          _bar(220, 16),
          const SizedBox(height: 14),
          _bar(140, 10),
        ]),
      ),
    ]),
  );

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeInOut),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(children: [_card(), _card()]),
    ),
  );
}