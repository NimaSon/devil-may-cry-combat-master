import 'package:flutter/material.dart';
import 'translations.dart';

class ExchangersScreen extends StatefulWidget {
  final String selectedLanguage;

  const ExchangersScreen({super.key, required this.selectedLanguage});

  @override
  State<ExchangersScreen> createState() => _ExchangersScreenState();
}

class _ExchangersScreenState extends State<ExchangersScreen> {
  String _searchQuery = '';

  final List<Map<String, dynamic>> banks = [
    {
      'name': 'Halyk Bank',
      'icon': '🏦',
      'color': Color(0xFF00A651),
      'rates': [
        {'flag': '🇺🇸', 'buy': '482,8', 'sell': '489,8'},
        {'flag': '🇪🇺', 'buy': '559,98', 'sell': '569,48'},
        {'flag': '🇷🇺', 'buy': '5,93', 'sell': '6,43'},
      ],
    },
    {
      'name': 'Bank CenterCredit',
      'icon': '🏦',
      'color': Color(0xFFFF6B00),
      'rates': [
        {'flag': '🇺🇸', 'buy': '484,9', 'sell': '490,2'},
        {'flag': '🇪🇺', 'buy': '564,7', 'sell': '571,2'},
        {'flag': '🇷🇺', 'buy': '6', 'sell': '6,4'},
      ],
    },
    {
      'name': 'ForteBank',
      'icon': '🏦',
      'color': Color(0xFFE30613),
      'rates': [
        {'flag': '🇺🇸', 'buy': '485', 'sell': '493'},
        {'flag': '🇪🇺', 'buy': '565,19', 'sell': '574,19'},
        {'flag': '🇷🇺', 'buy': '6,06', 'sell': '6,36'},
      ],
    },
    {
      'name': 'Eurasian Bank',
      'icon': '🏦',
      'color': Color(0xFF0066CC),
      'rates': [
        {'flag': '🇺🇸', 'buy': '483,5', 'sell': '491,5'},
        {'flag': '🇪🇺', 'buy': '562,3', 'sell': '570,8'},
        {'flag': '🇷🇺', 'buy': '5,95', 'sell': '6,45'},
      ],
    },
    {
      'name': 'Kaspi Bank',
      'icon': '🏦',
      'color': Color(0xFFFF0000),
      'rates': [
        {'flag': '🇺🇸', 'buy': '486', 'sell': '492'},
        {'flag': '🇪🇺', 'buy': '566', 'sell': '575'},
        {'flag': '🇷🇺', 'buy': '6,1', 'sell': '6,5'},
      ],
    },
    {
      'name': 'Jusan Bank',
      'icon': '🏦',
      'color': Color(0xFF00B956),
      'rates': [
        {'flag': '🇺🇸', 'buy': '484', 'sell': '490'},
        {'flag': '🇪🇺', 'buy': '563,5', 'sell': '572'},
        {'flag': '🇷🇺', 'buy': '5,98', 'sell': '6,42'},
      ],
    },
    {
      'name': 'Bereke Bank',
      'icon': '🏦',
      'color': Color(0xFF1E88E5),
      'rates': [
        {'flag': '🇺🇸', 'buy': '485,5', 'sell': '493,5'},
        {'flag': '🇪🇺', 'buy': '564', 'sell': '573'},
        {'flag': '🇷🇺', 'buy': '6,05', 'sell': '6,48'},
      ],
    },
  ];

  List<Map<String, dynamic>> get filteredBanks {
    if (_searchQuery.isEmpty) return banks;
    return banks.where((bank) {
      return bank['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                tr('exchangers', widget.selectedLanguage),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: tr('search', widget.selectedLanguage),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredBanks.length,
                itemBuilder: (context, index) {
                  final bank = filteredBanks[index];
                  return _buildBankCard(bank);
                },
              ),
            ),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                child: Center(
                  child: Text(
                    bank['icon'],
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                bank['name'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Покупка',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Text(
                  'Продажа',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      '${rate['sell']} ₸',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
