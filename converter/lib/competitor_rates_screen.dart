import 'package:flutter/material.dart';
import 'app_background.dart';

class CompetitorRatesScreen extends StatefulWidget {
  final List<Map<String, String>> aiuBankRates;
  final String selectedLanguage;

  const CompetitorRatesScreen({super.key, required this.aiuBankRates, required this.selectedLanguage});

  @override
  State<CompetitorRatesScreen> createState() => _CompetitorRatesScreenState();
}

class _CompetitorRatesScreenState extends State<CompetitorRatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCurrency = 'USD';

  final List<Map<String, dynamic>> _competitors = [
    {
      'name': 'Halyk Bank',
      'icon': '🏦',
      'color': Color(0xFF00A651),
      'rates': {'USD': {'buy': 482.8, 'sell': 489.8}, 'EUR': {'buy': 559.98, 'sell': 569.48}, 'RUB': {'buy': 5.93, 'sell': 6.43}},
    },
    {
      'name': 'Bank CenterCredit',
      'icon': '🏦',
      'color': Color(0xFFFF6B00),
      'rates': {'USD': {'buy': 484.9, 'sell': 490.2}, 'EUR': {'buy': 564.7, 'sell': 571.2}, 'RUB': {'buy': 6.0, 'sell': 6.4}},
    },
    {
      'name': 'ForteBank',
      'icon': '🏦',
      'color': Color(0xFFE30613),
      'rates': {'USD': {'buy': 485.0, 'sell': 493.0}, 'EUR': {'buy': 565.19, 'sell': 574.19}, 'RUB': {'buy': 6.06, 'sell': 6.36}},
    },
    {
      'name': 'Eurasian Bank',
      'icon': '🏦',
      'color': Color(0xFF0066CC),
      'rates': {'USD': {'buy': 483.5, 'sell': 491.5}, 'EUR': {'buy': 562.3, 'sell': 570.8}, 'RUB': {'buy': 5.95, 'sell': 6.45}},
    },
    {
      'name': 'Kaspi Bank',
      'icon': '🏦',
      'color': Color(0xFFFF0000),
      'rates': {'USD': {'buy': 486.0, 'sell': 492.0}, 'EUR': {'buy': 566.0, 'sell': 575.0}, 'RUB': {'buy': 6.1, 'sell': 6.5}},
    },
    {
      'name': 'Jusan Bank',
      'icon': '🏦',
      'color': Color(0xFF00B956),
      'rates': {'USD': {'buy': 484.0, 'sell': 490.0}, 'EUR': {'buy': 563.5, 'sell': 572.0}, 'RUB': {'buy': 5.98, 'sell': 6.42}},
    },
    {
      'name': 'Bereke Bank',
      'icon': '🏦',
      'color': Color(0xFF1E88E5),
      'rates': {'USD': {'buy': 485.5, 'sell': 493.5}, 'EUR': {'buy': 564.0, 'sell': 573.0}, 'RUB': {'buy': 6.05, 'sell': 6.48}},
    },
  ];

  static const _currencyFlags = {'USD': '🇺🇸', 'EUR': '🇪🇺', 'RUB': '🇷🇺'};
  static const _flagToCurrency = {'🇺🇸': 'USD', '🇪🇺': 'EUR', '🇷🇺': 'RUB'};

  double get _aiuBuy {
    for (final rate in widget.aiuBankRates) {
      if (_flagToCurrency[rate['flag']] == _selectedCurrency) {
        return double.tryParse(rate['buy']!.replaceAll(',', '.')) ?? 0;
      }
    }
    return 0;
  }

  double get _aiuSell {
    for (final rate in widget.aiuBankRates) {
      if (_flagToCurrency[rate['flag']] == _selectedCurrency) {
        return double.tryParse(rate['sell']!.replaceAll(',', '.')) ?? 0;
      }
    }
    return 0;
  }

  double get _avgMarketBuy {
    final values = _competitors
        .map((b) => (b['rates'][_selectedCurrency]['buy'] as double))
        .toList();
    return values.reduce((a, b) => a + b) / values.length;
  }

  double get _avgMarketSell {
    final values = _competitors
        .map((b) => (b['rates'][_selectedCurrency]['sell'] as double))
        .toList();
    return values.reduce((a, b) => a + b) / values.length;
  }

  // Позиция Aiu Bank по продаже среди всех (1 = лучший для клиента = самый низкий sell)
  int get _aiuRankBySell {
    final allSells = [
      _aiuSell,
      ..._competitors.map((b) => b['rates'][_selectedCurrency]['sell'] as double),
    ]..sort();
    return allSells.indexOf(_aiuSell) + 1;
  }

  int get _totalBanks => _competitors.length + 1;

  String get _positionLabel {
    final rank = _aiuRankBySell;
    final total = _totalBanks;
    if (rank == 1) return '🥇 Лучший курс на рынке';
    if (rank <= total ~/ 3) return '🟢 Выше среднего';
    if (rank <= (total * 2) ~/ 3) return '🟡 Средний уровень';
    return '🔴 Ниже среднего';
  }

  Color get _positionColor {
    final rank = _aiuRankBySell;
    final total = _totalBanks;
    if (rank == 1) return const Color(0xFF00C853);
    if (rank <= total ~/ 3) return const Color(0xFF00B956);
    if (rank <= (total * 2) ~/ 3) return const Color(0xFFFFB300);
    return const Color(0xFFE53935);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedCurrency = ['USD', 'EUR', 'RUB'][_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Курсы конкурентов', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: '🇺🇸 USD'),
              Tab(text: '🇪🇺 EUR'),
              Tab(text: '🇷🇺 RUB'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: ['USD', 'EUR', 'RUB'].map((currency) {
            return _buildCurrencyTab(currency);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCurrencyTab(String currency) {
    final aiuBuy = _aiuBuy;
    final aiuSell = _aiuSell;
    final avgBuy = _avgMarketBuy;
    final avgSell = _avgMarketSell;
    final buyDiff = aiuBuy - avgBuy;
    final sellDiff = aiuSell - avgSell;

    // Сортируем конкурентов по курсу продажи (лучший для клиента = меньше)
    final sorted = List<Map<String, dynamic>>.from(_competitors)
      ..sort((a, b) => (a['rates'][currency]['sell'] as double)
          .compareTo(b['rates'][currency]['sell'] as double));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Позиция Aiu Bank
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_positionColor, _positionColor.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🏛️', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Aiu Bank',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(_positionLabel,
                            style: const TextStyle(fontSize: 14, color: Colors.white70)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_aiuRankBySell / $_totalBanks',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildRateChip('Покупка', aiuBuy, buyDiff)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildRateChip('Продажа', aiuSell, sellDiff)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Среднее по рынку
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              const Icon(Icons.bar_chart, size: 28, color: Colors.white54),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Среднее по рынку',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white54)),
                    const SizedBox(height: 4),
                    Text(
                      'Покупка: ${avgBuy.toStringAsFixed(2)} ₸   •   Продажа: ${avgSell.toStringAsFixed(2)} ₸',
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text('Все банки', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('Отсортировано по курсу продажи',
            style: TextStyle(fontSize: 12, color: Colors.white38)),
        const SizedBox(height: 12),

        // Aiu Bank в списке
        _buildBankRow(
          icon: '🏛️',
          color: const Color(0xFF00C853),
          name: 'Aiu Bank',
          buy: aiuBuy,
          sell: aiuSell,
          avgSell: avgSell,
          isOwn: true,
          rank: _aiuRankBySell,
        ),

        // Конкуренты
        ...sorted.asMap().entries.map((entry) {
          final bank = entry.value;
          final rates = bank['rates'][currency];
          final buy = rates['buy'] as double;
          final sell = rates['sell'] as double;
          // Ранг в общем списке включая Aiu
          final allSells = [
            aiuSell,
            ..._competitors.map((b) => b['rates'][currency]['sell'] as double),
          ]..sort();
          final rank = allSells.indexOf(sell) + 1;
          return _buildBankRow(
            icon: bank['icon'],
            color: bank['color'],
            name: bank['name'],
            buy: buy,
            sell: sell,
            avgSell: avgSell,
            isOwn: false,
            rank: rank,
          );
        }),
      ],
    );
  }

  Widget _buildRateChip(String label, double value, double diff) {
    final isPositive = diff >= 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 4),
          Text('${value.toStringAsFixed(2)} ₸',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: Colors.white70,
              ),
              Text(
                '${diff.abs().toStringAsFixed(2)} vs рынок',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankRow({
    required String icon,
    required Color color,
    required String name,
    required double buy,
    required double sell,
    required double avgSell,
    required bool isOwn,
    required int rank,
  }) {
    final sellDiff = sell - avgSell;
    final isBetter = sellDiff <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isOwn
            ? const Color(0xFF00C853).withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: isOwn
            ? Border.all(color: const Color(0xFF00C853), width: 1.5)
            : Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: rank == 1 ? const Color(0xFF00C853) : Colors.white38,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isOwn ? FontWeight.bold : FontWeight.w500,
                      color: Colors.white,
                    )),
                if (isOwn)
                  const Text('Ваш банк',
                      style: TextStyle(fontSize: 11, color: Color(0xFF00C853))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${buy.toStringAsFixed(1)} ₸',
                  style: const TextStyle(fontSize: 13, color: Colors.white54)),
              const Text('покупка', style: TextStyle(fontSize: 10, color: Colors.white38)),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${sell.toStringAsFixed(1)} ₸',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              Row(
                children: [
                  Icon(
                    isBetter ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 10,
                    color: isBetter ? Colors.green : Colors.red,
                  ),
                  Text(
                    '${sellDiff.abs().toStringAsFixed(1)}',
                    style: TextStyle(fontSize: 10, color: isBetter ? Colors.green : Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
