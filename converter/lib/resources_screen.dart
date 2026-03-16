import 'package:flutter/material.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final List<Map<String, dynamic>> _resources = [
    {
      'name': 'Золото',
      'symbol': 'XAU',
      'price': 2345.80,
      'unit': 'за тр. унцию',
      'change': 1.24,
      'isUp': true,
      'icon': '🥇',
      'color': Color(0xFFFFD700),
      'category': 'Металлы',
      'high': 2361.20,
      'low': 2318.40,
      'desc': 'Драгоценный металл, защитный актив',
    },
    {
      'name': 'Серебро',
      'symbol': 'XAG',
      'price': 29.47,
      'unit': 'за тр. унцию',
      'change': 2.13,
      'isUp': true,
      'icon': '🥈',
      'color': Color(0xFFAAAAAA),
      'category': 'Металлы',
      'high': 30.12,
      'low': 28.85,
      'desc': 'Промышленный и инвестиционный металл',
    },
    {
      'name': 'Платина',
      'symbol': 'XPT',
      'price': 978.50,
      'unit': 'за тр. унцию',
      'change': -0.63,
      'isUp': false,
      'icon': '💎',
      'color': Color(0xFF8E9EAB),
      'category': 'Металлы',
      'high': 992.00,
      'low': 971.30,
      'desc': 'Редкий металл платиновой группы',
    },
    {
      'name': 'Медь',
      'symbol': 'HG',
      'price': 4.52,
      'unit': 'за фунт',
      'change': 0.89,
      'isUp': true,
      'icon': '🔶',
      'color': Color(0xFFB87333),
      'category': 'Металлы',
      'high': 4.58,
      'low': 4.44,
      'desc': 'Промышленный металл, индикатор экономики',
    },
    {
      'name': 'Нефть Brent',
      'symbol': 'BRENT',
      'price': 84.32,
      'unit': 'за баррель',
      'change': -1.47,
      'isUp': false,
      'icon': '🛢️',
      'color': Color(0xFF212121),
      'category': 'Энергоносители',
      'high': 86.10,
      'low': 83.45,
      'desc': 'Эталонная марка нефти Северного моря',
    },
    {
      'name': 'Нефть WTI',
      'symbol': 'WTI',
      'price': 80.15,
      'unit': 'за баррель',
      'change': -1.82,
      'isUp': false,
      'icon': '⛽',
      'color': Color(0xFF37474F),
      'category': 'Энергоносители',
      'high': 82.30,
      'low': 79.60,
      'desc': 'Американская лёгкая нефть',
    },
    {
      'name': 'Природный газ',
      'symbol': 'NG',
      'price': 2.18,
      'unit': 'за MMBtu',
      'change': 3.42,
      'isUp': true,
      'icon': '🔥',
      'color': Color(0xFFFF7043),
      'category': 'Энергоносители',
      'high': 2.24,
      'low': 2.09,
      'desc': 'Природный газ, энергетическое сырьё',
    },
    {
      'name': 'Уголь',
      'symbol': 'COAL',
      'price': 136.75,
      'unit': 'за тонну',
      'change': -0.54,
      'isUp': false,
      'icon': '⚫',
      'color': Color(0xFF424242),
      'category': 'Энергоносители',
      'high': 139.20,
      'low': 135.10,
      'desc': 'Твёрдое топливо для электростанций',
    },
    {
      'name': 'Пшеница',
      'symbol': 'WHEAT',
      'price': 548.25,
      'unit': 'за бушель',
      'change': 1.67,
      'isUp': true,
      'icon': '🌾',
      'color': Color(0xFFFFB300),
      'category': 'Агро',
      'high': 556.00,
      'low': 539.50,
      'desc': 'Зерновая культура, продовольственный рынок',
    },
    {
      'name': 'Кукуруза',
      'symbol': 'CORN',
      'price': 432.50,
      'unit': 'за бушель',
      'change': 0.93,
      'isUp': true,
      'icon': '🌽',
      'color': Color(0xFFFDD835),
      'category': 'Агро',
      'high': 438.75,
      'low': 428.00,
      'desc': 'Зерновая культура и биотопливо',
    },
  ];

  String _selectedCategory = 'Все';
  final List<String> _categories = ['Все', 'Металлы', 'Энергоносители', 'Агро'];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedCategory == 'Все') return _resources;
    return _resources.where((r) => r['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final gainers = _resources.where((r) => r['isUp'] == true).length;
    final losers = _resources.where((r) => r['isUp'] == false).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ресурсы'),
      ),
      body: Column(
        children: [
          // Баннер
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF8F00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Сырьевые рынки',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('${_resources.length} инструментов',
                          style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                _buildChip('↑ $gainers', Colors.green),
                const SizedBox(width: 8),
                _buildChip('↓ $losers', Colors.red),
              ],
            ),
          ),
          // Фильтр категорий
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFF8F00) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
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
              itemBuilder: (context, i) => _buildResourceCard(filtered[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(Map<String, dynamic> res) {
    final isUp = res['isUp'] as bool;
    final change = res['change'] as double;
    final color = res['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text(res['icon'], style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(res['name'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(res['symbol'],
                              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Text(res['desc'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${(res['price'] as double).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
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
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isUp ? Colors.green : Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Мин/Макс за день
          Row(
            children: [
              Expanded(child: _buildMinMax('Мин. день', res['low'], Colors.red)),
              const SizedBox(width: 8),
              Expanded(child: _buildMinMax('Макс. день', res['high'], Colors.green)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text('Единица', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                      Text(res['unit'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMinMax(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          Text('\$${value.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
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
