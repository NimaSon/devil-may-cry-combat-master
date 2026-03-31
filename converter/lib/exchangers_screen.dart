import 'package:flutter/material.dart';
import 'translations.dart';
import 'rate_management_screen.dart';
import 'p2p_screen.dart';
import 'app_background.dart';

class ExchangersScreen extends StatefulWidget {
  final String selectedLanguage;
  final bool isLoggedIn;
  final bool isLegalEntity;
  final List<Map<String, String>> aiuBankRates;
  final Function(List<Map<String, String>>) onRatesUpdate;

  const ExchangersScreen({
    super.key,
    required this.selectedLanguage,
    required this.isLoggedIn,
    required this.isLegalEntity,
    required this.aiuBankRates,
    required this.onRatesUpdate,
  });

  @override
  State<ExchangersScreen> createState() => _ExchangersScreenState();
}

enum _FilterMode { none, bestBuy, bestSell }

class _ExchangersScreenState extends State<ExchangersScreen> with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  _FilterMode _filterMode = _FilterMode.none;
  late TabController _tabController;

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

  final List<Map<String, dynamic>> banks = [
    {
      'name': 'Aiu Bank',
      'logo': 'assets/images/aiu.jpg',
      'color': Color(0xFF00C853),
      'isOwn': true,
      'rates': [],
    },
    {
      'name': 'Halyk Bank',
      'logo': 'assets/images/halyk.jpeg',
      'color': Color(0xFF00A651),
      'rates': [
        {'flag': '🇺🇸', 'buy': '482,8', 'sell': '489,8'},
        {'flag': '🇪🇺', 'buy': '559,98', 'sell': '569,48'},
        {'flag': '🇷🇺', 'buy': '5,93', 'sell': '6,43'},
      ],
    },
    {
      'name': 'Bank CenterCredit',
      'logo': 'assets/images/bcc.webp',
      'color': Color(0xFFFF6B00),
      'rates': [
        {'flag': '🇺🇸', 'buy': '484,9', 'sell': '490,2'},
        {'flag': '🇪🇺', 'buy': '564,7', 'sell': '571,2'},
        {'flag': '🇷🇺', 'buy': '6', 'sell': '6,4'},
      ],
    },
    {
      'name': 'ForteBank',
      'logo': 'assets/images/forte.webp',
      'color': Color(0xFFE30613),
      'rates': [
        {'flag': '🇺🇸', 'buy': '485', 'sell': '493'},
        {'flag': '🇪🇺', 'buy': '565,19', 'sell': '574,19'},
        {'flag': '🇷🇺', 'buy': '6,06', 'sell': '6,36'},
      ],
    },
    {
      'name': 'Eurasian Bank',
      'logo': 'assets/images/eurasian.png',
      'color': Color(0xFF0066CC),
      'rates': [
        {'flag': '🇺🇸', 'buy': '483,5', 'sell': '491,5'},
        {'flag': '🇪🇺', 'buy': '562,3', 'sell': '570,8'},
        {'flag': '🇷🇺', 'buy': '5,95', 'sell': '6,45'},
      ],
    },
    {
      'name': 'Kaspi Bank',
      'logo': 'assets/images/kaspi.png',
      'color': Color(0xFFFF0000),
      'rates': [
        {'flag': '🇺🇸', 'buy': '486', 'sell': '492'},
        {'flag': '🇪🇺', 'buy': '566', 'sell': '575'},
        {'flag': '🇷🇺', 'buy': '6,1', 'sell': '6,5'},
      ],
    },
    {
      'name': 'Jusan Bank',
      'logo': null,
      'abbr': 'JB',
      'color': Color(0xFF00B956),
      'rates': [
        {'flag': '🇺🇸', 'buy': '484', 'sell': '490'},
        {'flag': '🇪🇺', 'buy': '563,5', 'sell': '572'},
        {'flag': '🇷🇺', 'buy': '5,98', 'sell': '6,42'},
      ],
    },
    {
      'name': 'Bereke Bank',
      'logo': 'assets/images/bereke.jpg',
      'color': Color(0xFF1E88E5),
      'rates': [
        {'flag': '🇺🇸', 'buy': '485,5', 'sell': '493,5'},
        {'flag': '🇪🇺', 'buy': '564', 'sell': '573'},
        {'flag': '🇷🇺', 'buy': '6,05', 'sell': '6,48'},
      ],
    },
  ];

  double _getUsdRate(Map<String, dynamic> bank, String type) {
    final List rates = bank['isOwn'] == true
        ? widget.aiuBankRates
        : List.from(bank['rates'] ?? []);
    if (rates.isEmpty) return 0;
    try {
      final usd = rates.firstWhere(
        (r) => r is Map && r['flag'] == '🇺🇸',
        orElse: () => rates[0],
      );
      if (usd is! Map) return 0;
      return double.tryParse(usd[type]?.toString().replaceAll(',', '.') ?? '0') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  List<Map<String, dynamic>> get filteredBanks {
    List<Map<String, dynamic>> result = banks.where((bank) {
      return bank['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (_filterMode == _FilterMode.bestBuy) {
      result.sort((a, b) => _getUsdRate(a, 'buy').compareTo(_getUsdRate(b, 'buy')));
    } else if (_filterMode == _FilterMode.bestSell) {
      result.sort((a, b) => _getUsdRate(b, 'sell').compareTo(_getUsdRate(a, 'sell')));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  tr('exchangers', widget.selectedLanguage),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF00C853),
                labelColor: const Color(0xFF00C853),
                unselectedLabelColor: Colors.white54,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [Tab(text: 'Банки'), Tab(text: 'P2P')],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Таб Банки
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (value) => setState(() => _searchQuery = value),
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: tr('search', widget.selectedLanguage),
                                    hintStyle: const TextStyle(color: Colors.white54),
                                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.08),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterButton(),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredBanks.length,
                            itemBuilder: (context, index) {
                              final bank = filteredBanks[index];
                              if (bank['isOwn'] == true) {
                                bank['rates'] = widget.aiuBankRates;
                              }
                              return _buildBankCard(bank);
                            },
                          ),
                        ),
                      ],
                    ),
                    // Таб P2P
                    const P2PScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    final isActive = _filterMode != _FilterMode.none;
    return GestureDetector(
      onTap: () => _showFilterSheet(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              isActive
                  ? (_filterMode == _FilterMode.bestBuy ? 'Купить' : 'Продать')
                  : 'Фильтр',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A2D42),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Сортировка',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              _buildFilterOption(
                icon: Icons.trending_down,
                iconColor: const Color(0xFF42A5F5),
                title: 'Выгодно купить',
                subtitle: 'Банки с лучшим курсом покупки',
                isSelected: _filterMode == _FilterMode.bestBuy,
                onTap: () {
                  setState(() => _filterMode = _FilterMode.bestBuy);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _buildFilterOption(
                icon: Icons.trending_up,
                iconColor: const Color(0xFF66BB6A),
                title: 'Выгодно продать',
                subtitle: 'Банки с лучшим курсом продажи',
                isSelected: _filterMode == _FilterMode.bestSell,
                onTap: () {
                  setState(() => _filterMode = _FilterMode.bestSell);
                  Navigator.pop(context);
                },
              ),
              if (_filterMode != _FilterMode.none) ...[
                const SizedBox(height: 12),
                _buildFilterOption(
                  icon: Icons.close,
                  iconColor: Colors.white54,
                  title: 'Сбросить фильтр',
                  subtitle: 'Вернуть исходный порядок',
                  isSelected: false,
                  onTap: () {
                    setState(() => _filterMode = _FilterMode.none);
                    Navigator.pop(context);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF42A5F5) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF42A5F5), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildBankCard(Map<String, dynamic> bank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: bank['color'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: bank['logo'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          bank['logo'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(bank['abbr'] ?? bank['name'][0], style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(bank['abbr'] ?? bank['icon'] ?? '🏛️', style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
              ),
              const SizedBox(width: 12),
              Text(
                bank['name'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Покупка',
                  style: const TextStyle(fontSize: 14, color: Colors.white54),
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Text(
                  'Продажа',
                  style: const TextStyle(fontSize: 14, color: Colors.white54),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...bank['rates'].map<Widget>((rate) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(rate['flag'], style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text(
                          '${rate['buy']} ₸',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      '${rate['sell']} ₸',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          if (bank['isOwn'] == true && widget.isLoggedIn && widget.isLegalEntity)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RateManagementScreen(currentRates: widget.aiuBankRates),
                    ),
                  );
                  if (result != null) {
                    widget.onRatesUpdate(result);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Управление курсами', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}
