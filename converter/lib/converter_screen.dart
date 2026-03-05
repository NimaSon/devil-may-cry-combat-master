import 'package:flutter/material.dart';
import 'currency_data.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  List<String> favoriteConverterCurrencies = ['KZT', 'AED', 'INR', 'RUB', 'KRW'];
  Map<String, TextEditingController> controllers = {};
  String baseCurrency = 'KZT';
  double baseAmount = 0;

  @override
  void initState() {
    super.initState();
    for (var code in favoriteConverterCurrencies) {
      controllers[code] = TextEditingController(text: '0');
    }
  }

  void _openEditScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConverterEditScreen(
          favoriteCurrencies: favoriteConverterCurrencies,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        favoriteConverterCurrencies = result;
        for (var code in favoriteConverterCurrencies) {
          if (!controllers.containsKey(code)) {
            controllers[code] = TextEditingController(text: '0');
          }
        }
      });
    }
  }

  double _convertCurrency(String targetCode) {
    if (baseCurrency == targetCode) return baseAmount;
    
    final basePrice = worldCurrencies[baseCurrency]?['price'] ?? '1,00 ₸';
    final targetPrice = worldCurrencies[targetCode]?['price'] ?? '1,00 ₸';
    
    final baseValue = double.parse(basePrice.replaceAll(' ₸', '').replaceAll(',', '.'));
    final targetValue = double.parse(targetPrice.replaceAll(' ₸', '').replaceAll(',', '.'));
    
    return (baseAmount * baseValue) / targetValue;
  }

  void _updateAllFields(String changedCode, String value) {
    setState(() {
      baseCurrency = changedCode;
      baseAmount = double.tryParse(value) ?? 0;
      
      for (var code in favoriteConverterCurrencies) {
        if (code != changedCode) {
          final converted = _convertCurrency(code);
          controllers[code]?.text = converted.toStringAsFixed(code == 'KZT' ? 0 : 4);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Конвертер валют', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: _openEditScreen,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          ...favoriteConverterCurrencies.map((code) {
            final currency = worldCurrencies[code];
            if (currency == null) return const SizedBox();
            
            return Container(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(currency['flag'], style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(code, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(currency['name'], style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: controllers[code],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      onChanged: (value) => _updateAllFields(code, value),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class ConverterEditScreen extends StatefulWidget {
  final List<String> favoriteCurrencies;

  const ConverterEditScreen({
    super.key,
    required this.favoriteCurrencies,
  });

  @override
  State<ConverterEditScreen> createState() => _ConverterEditScreenState();
}

class _ConverterEditScreenState extends State<ConverterEditScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _favoriteCurrencies;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _favoriteCurrencies = List.from(widget.favoriteCurrencies);
  }

  void _toggleFavorite(String code) {
    setState(() {
      if (_favoriteCurrencies.contains(code)) {
        _favoriteCurrencies.remove(code);
      } else {
        _favoriteCurrencies.add(code);
      }
    });
  }

  List<MapEntry<String, Map<String, dynamic>>> _filterCurrencies() {
    return worldCurrencies.entries.where((entry) {
      return entry.value['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          entry.key.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Изменение избранного', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _favoriteCurrencies);
            },
            child: const Text('Готово', style: TextStyle(fontSize: 16)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: const [
                  Tab(text: 'Избранное'),
                  Tab(text: 'Все'),
                ],
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Поиск',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFavoriteTab(),
          _buildAllTab(),
        ],
      ),
    );
  }

  Widget _buildFavoriteTab() {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Курсы валют', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        ..._favoriteCurrencies.map((code) {
          final currency = worldCurrencies[code];
          if (currency == null) return const SizedBox();
          return _buildCurrencyItem(currency['flag'], code, currency['name'], true);
        }),
      ],
    );
  }

  Widget _buildAllTab() {
    final filteredCurrencies = _filterCurrencies();

    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Курсы валют', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        ...filteredCurrencies.map((entry) {
          final code = entry.key;
          final currency = entry.value;
          final isFavorite = _favoriteCurrencies.contains(code);
          return _buildCurrencyItem(currency['flag'], code, currency['name'], isFavorite);
        }),
      ],
    );
  }

  Widget _buildCurrencyItem(String flag, String code, String name, bool isFavorite) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 1),
      child: ListTile(
        leading: Text(flag, style: const TextStyle(fontSize: 32)),
        title: Text(name, style: const TextStyle(fontSize: 16)),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? Colors.blue : Colors.grey,
          ),
          onPressed: () => _toggleFavorite(code),
        ),
      ),
    );
  }
}
