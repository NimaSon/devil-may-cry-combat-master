import 'package:flutter/material.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _stocks = [
    {'name': 'Tesla', 'ticker': 'TSLA', 'price': 248.42, 'change': 3.21, 'isUp': true, 'icon': '🚗', 'color': Color(0xFFE31937), 'sector': 'Авто'},
    {'name': 'Apple', 'ticker': 'AAPL', 'price': 189.30, 'change': 1.14, 'isUp': true, 'icon': '🍎', 'color': Color(0xFF555555), 'sector': 'Технологии'},
    {'name': 'Microsoft', 'ticker': 'MSFT', 'price': 415.26, 'change': 0.87, 'isUp': true, 'icon': '🪟', 'color': Color(0xFF00A4EF), 'sector': 'Технологии'},
    {'name': 'NVIDIA', 'ticker': 'NVDA', 'price': 875.40, 'change': 5.63, 'isUp': true, 'icon': '🎮', 'color': Color(0xFF76B900), 'sector': 'Технологии'},
    {'name': 'Amazon', 'ticker': 'AMZN', 'price': 186.57, 'change': 2.34, 'isUp': true, 'icon': '📦', 'color': Color(0xFFFF9900), 'sector': 'Ритейл'},
    {'name': 'Google', 'ticker': 'GOOGL', 'price': 172.63, 'change': 0.45, 'isUp': true, 'icon': '🔍', 'color': Color(0xFF4285F4), 'sector': 'Технологии'},
    {'name': 'Meta', 'ticker': 'META', 'price': 527.19, 'change': 1.92, 'isUp': true, 'icon': '👓', 'color': Color(0xFF0082FB), 'sector': 'Соцсети'},
    {'name': 'Netflix', 'ticker': 'NFLX', 'price': 634.81, 'change': -1.23, 'isUp': false, 'icon': '🎬', 'color': Color(0xFFE50914), 'sector': 'Медиа'},
    {'name': 'Spotify', 'ticker': 'SPOT', 'price': 312.44, 'change': -0.78, 'isUp': false, 'icon': '🎵', 'color': Color(0xFF1DB954), 'sector': 'Медиа'},
    {'name': 'Boeing', 'ticker': 'BA', 'price': 178.92, 'change': -2.15, 'isUp': false, 'icon': '✈️', 'color': Color(0xFF1D4F8C), 'sector': 'Авиация'},
    {'name': 'JPMorgan', 'ticker': 'JPM', 'price': 198.74, 'change': 0.63, 'isUp': true, 'icon': '🏦', 'color': Color(0xFF003087), 'sector': 'Финансы'},
    {'name': 'Visa', 'ticker': 'V', 'price': 276.38, 'change': 0.29, 'isUp': true, 'icon': '💳', 'color': Color(0xFF1A1F71), 'sector': 'Финансы'},
    {'name': 'ExxonMobil', 'ticker': 'XOM', 'price': 112.45, 'change': -0.94, 'isUp': false, 'icon': '⛽', 'color': Color(0xFFE01B22), 'sector': 'Энергетика'},
    {'name': 'Pfizer', 'ticker': 'PFE', 'price': 27.83, 'change': -1.47, 'isUp': false, 'icon': '💊', 'color': Color(0xFF0093D0), 'sector': 'Медицина'},
    {'name': 'Samsung', 'ticker': '005930', 'price': 68.20, 'change': 1.05, 'isUp': true, 'icon': '📱', 'color': Color(0xFF1428A0), 'sector': 'Технологии'},
  ];

  final List<String> _sectors = ['Все', 'Технологии', 'Финансы', 'Авто', 'Медиа', 'Энергетика', 'Медицина', 'Авиация', 'Ритейл', 'Соцсети'];
  String _selectedSector = 'Все';

  List<Map<String, dynamic>> get _filtered {
    return _stocks.where((s) {
      final matchSearch = s['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s['ticker'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchSector = _selectedSector == 'Все' || s['sector'] == _selectedSector;
      return matchSearch && matchSector;
    }).toList();
  }

  int get _gainers => _stocks.where((s) => s['isUp'] == true).length;
  int get _losers => _stocks.where((s) => s['isUp'] == false).length;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Акции'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Все акции'),
            Tab(text: 'Топ роста'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllStocks(),
          _buildTopGainers(),
        ],
      ),
    );
  }

  Widget _buildAllStocks() {
    final filtered = _filtered;
    return Column(
      children: [
        // Сводка рынка
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text('📈', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Рынок акций', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('${_stocks.length} компаний', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
              _buildMarketChip('↑ $_gainers', Colors.green),
              const SizedBox(width: 8),
              _buildMarketChip('↓ $_losers', Colors.red),
            ],
          ),
        ),
        // Поиск
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Поиск по названию или тикеру...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Фильтр по секторам
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _sectors.length,
            itemBuilder: (context, i) {
              final sector = _sectors[i];
              final isSelected = _selectedSector == sector;
              return GestureDetector(
                onTap: () => setState(() => _selectedSector = sector),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1565C0) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sector,
                    style: TextStyle(
                      fontSize: 13,
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
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            itemBuilder: (context, i) => _buildStockCard(filtered[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildTopGainers() {
    final gainers = List<Map<String, dynamic>>.from(_stocks.where((s) => s['isUp'] == true))
      ..sort((a, b) => (b['change'] as double).compareTo(a['change'] as double));
    final losers = List<Map<String, dynamic>>.from(_stocks.where((s) => s['isUp'] == false))
      ..sort((a, b) => (a['change'] as double).compareTo(b['change'] as double));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('🚀 Лидеры роста', Colors.green),
        const SizedBox(height: 8),
        ...gainers.map((s) => _buildStockCard(s)),
        const SizedBox(height: 16),
        _buildSectionHeader('📉 Лидеры падения', Colors.red),
        const SizedBox(height: 8),
        ...losers.map((s) => _buildStockCard(s)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildStockCard(Map<String, dynamic> stock) {
    final isUp = stock['isUp'] as bool;
    final change = stock['change'] as double;
    final color = stock['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(stock['icon'], style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stock['name'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text(stock['ticker'], style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(stock['sector'], style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${(stock['price'] as double).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isUp ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12, color: isUp ? Colors.green : Colors.red),
                    Text(
                      '${change.abs().toStringAsFixed(2)}%',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isUp ? Colors.green : Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
