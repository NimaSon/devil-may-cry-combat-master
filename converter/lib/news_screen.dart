import 'package:flutter/material.dart';
import 'news_service.dart';

class NewsScreen extends StatefulWidget {
  final String selectedLanguage;

  const NewsScreen({super.key, required this.selectedLanguage});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<NewsArticle> _articles = [];
  bool _loading = true;
  bool _hasError = false;
  String _selectedCategory = 'Все';

  final List<Map<String, String>> _categories = [
    {'label': 'Все', 'query': 'economy finance currency oil gold'},
    {'label': '💰 Валюты', 'query': 'currency exchange dollar euro'},
    {'label': '🛢️ Нефть', 'query': 'oil crude brent wti'},
    {'label': '🥇 Металлы', 'query': 'gold silver platinum metals'},
    {'label': '📈 Рынки', 'query': 'stock market nasdaq sp500'},
    {'label': '🏦 Банки', 'query': 'bank banking finance federal reserve'},
  ];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews({String query = 'economy finance currency oil gold'}) async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    final articles = await NewsService.fetchEconomyNews(query: query);
    setState(() {
      _loading = false;
      _articles = articles;
      _hasError = articles.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новости экономики'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final cat = _categories.firstWhere((c) => c['label'] == _selectedCategory);
              _loadNews(query: cat['query']!);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Баннер
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF283593)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('📰', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Мировые новости',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(
                        _loading ? 'Загрузка...' : '${_articles.length} новостей',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('LIVE',
                      style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),
          // Категории
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final isSelected = _selectedCategory == cat['label'];
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = cat['label']!);
                    _loadNews(query: cat['query']!);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1A237E) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat['label']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Загружаем новости...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Не удалось загрузить новости', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _loadNews(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadNews(
        query: _categories.firstWhere((c) => c['label'] == _selectedCategory)['query']!,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _articles.length,
        itemBuilder: (context, i) => _buildNewsCard(_articles[i], i == 0),
      ),
    );
  }

  Widget _buildNewsCard(NewsArticle article, bool isTop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isTop ? Border.all(color: const Color(0xFF1A237E), width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isTop)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: const BoxDecoration(
                color: Color(0xFF1A237E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: const Text('🔥 Главная новость',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(article.source,
                          style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    Text(article.timeAgo,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
                const SizedBox(height: 8),
                Text(article.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, height: 1.3)),
                const SizedBox(height: 6),
                Text(
                  article.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
