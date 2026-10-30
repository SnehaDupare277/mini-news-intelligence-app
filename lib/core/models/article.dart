class Article {
  const Article({
    required this.title,
    required this.description,
    required this.url,
    required this.source,
    required this.publishedAt,
    this.imageUrl,
    this.author,
    this.content,
  });

  final String title;
  final String description;
  final String url;
  final String source;
  final String publishedAt;
  final String? imageUrl;
  final String? author;
  final String? content;

  factory Article.fromJson(Map<String, dynamic> json) {
    final sourceJson = json['source'];
    return Article(
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String : 'Untitled story',
      description: json['description'] as String? ?? 'No summary is available for this story.',
      url: json['url'] as String? ?? '',
      source: sourceJson is Map ? (sourceJson['name'] as String? ?? 'Unknown source') : 'Unknown source',
      publishedAt: json['publishedAt'] as String? ?? '',
      imageUrl: json['urlToImage'] as String?,
      author: json['author'] as String?,
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title, 'description': description, 'url': url, 'source': source,
    'publishedAt': publishedAt, 'imageUrl': imageUrl, 'author': author, 'content': content,
  };

  factory Article.fromMap(Map map) => Article(
    title: map['title'] as String? ?? 'Untitled story',
    description: map['description'] as String? ?? '',
    url: map['url'] as String? ?? '',
    source: map['source'] as String? ?? 'Unknown source',
    publishedAt: map['publishedAt'] as String? ?? '',
    imageUrl: map['imageUrl'] as String?,
    author: map['author'] as String?,
    content: map['content'] as String?,
  );
}
