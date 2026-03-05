import 'package:flutter/material.dart';
import 'currency_data.dart';
import 'converter_screen.dart';
import 'crypto_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Конвертер Валют',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<String> favoriteCurrencies = ['USD', 'EUR', 'RUB'];
  List<String> favoriteCrypto = ['BTC'];

  final allCurrencies = worldCurrencies;
  final allCrypto = worldCrypto;

  void _openEditScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCurrenciesScreen(
          favoriteCurrencies: favoriteCurrencies,
          favoriteCrypto: favoriteCrypto,
          allCurrencies: allCurrencies,
          allCrypto: allCrypto,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        favoriteCurrencies = result['currencies'];
        favoriteCrypto = result['crypto'];
      });
    }
  }

  Widget _getScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeScreen();
      case 2:
        return const CryptoScreen();
      case 3:
        return const ConverterScreen();
      default:
        return Center(child: Text('Страница ${_selectedIndex + 1}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _getScreen()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Обменники'),
          BottomNavigationBarItem(icon: Icon(Icons.currency_bitcoin), label: 'Криптовалюта'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Конвертер'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Другое'),
        ],
      ),
    );
  }

  Widget _buildHomeScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFF00BFFF), Color(0xFF1E90FF)]),
              ),
              child: const Icon(Icons.flag, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text('Главная', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton(onPressed: _openEditScreen, child: const Text('Изменить')),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Курсы валют', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...favoriteCurrencies.map((code) {
          final currency = allCurrencies[code]!;
          return _buildCurrencyCard(currency['flag'], code, currency['price'], currency['change'], currency['isUp']);
        }),
        const SizedBox(height: 24),
        const Text('Криптовалюта', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...favoriteCrypto.map((code) {
          final crypto = allCrypto[code]!;
          return _buildCryptoCard(crypto['symbol'], code, crypto['price'], crypto['change'], crypto['isUp']);
        }),
      ],
    );
  }

  Widget _buildCurrencyCard(String flag, String code, String price, String change, bool isUp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Text(code, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(change, style: TextStyle(fontSize: 14, color: isUp ? Colors.green : Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoCard(String symbol, String code, String price, String change, bool isUp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(symbol, style: const TextStyle(fontSize: 24, color: Colors.white))),
          ),
          const SizedBox(width: 16),
          Text(code, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(change, style: TextStyle(fontSize: 14, color: isUp ? Colors.green : Colors.red)),
            ],
          ),
        ],
      ),
    );
  }
}

class EditCurrenciesScreen extends StatefulWidget {
  final List<String> favoriteCurrencies;
  final List<String> favoriteCrypto;
  final Map<String, Map<String, dynamic>> allCurrencies;
  final Map<String, Map<String, dynamic>> allCrypto;

  const EditCurrenciesScreen({
    super.key,
    required this.favoriteCurrencies,
    required this.favoriteCrypto,
    required this.allCurrencies,
    required this.allCrypto,
  });

  @override
  State<EditCurrenciesScreen> createState() => _EditCurrenciesScreenState();
}

class _EditCurrenciesScreenState extends State<EditCurrenciesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _favoriteCurrencies;
  late List<String> _favoriteCrypto;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _favoriteCurrencies = List.from(widget.favoriteCurrencies);
    _favoriteCrypto = List.from(widget.favoriteCrypto);
  }

  void _toggleFavorite(String code, bool isCrypto) {
    setState(() {
      if (isCrypto) {
        if (_favoriteCrypto.contains(code)) {
          _favoriteCrypto.remove(code);
        } else {
          _favoriteCrypto.add(code);
        }
      } else {
        if (_favoriteCurrencies.contains(code)) {
          _favoriteCurrencies.remove(code);
        } else {
          _favoriteCurrencies.add(code);
        }
      }
    });
  }

  List<MapEntry<String, Map<String, dynamic>>> _filterCurrencies() {
    return widget.allCurrencies.entries.where((entry) {
      return entry.value['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          entry.key.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<MapEntry<String, Map<String, dynamic>>> _filterCrypto() {
    return widget.allCrypto.entries.where((entry) {
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
              Navigator.pop(context, {
                'currencies': _favoriteCurrencies,
                'crypto': _favoriteCrypto,
              });
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
        if (_favoriteCurrencies.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Курсы валют', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          ..._favoriteCurrencies.map((code) {
            final currency = widget.allCurrencies[code]!;
            return _buildCurrencyItem(currency['flag'], code, currency['name'], true, false);
          }),
        ],
        if (_favoriteCrypto.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Криптовалюта', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          ..._favoriteCrypto.map((code) {
            final crypto = widget.allCrypto[code]!;
            return _buildCryptoItem(crypto['symbol'], code, crypto['name'], true, true);
          }),
        ],
      ],
    );
  }

  Widget _buildAllTab() {
    final filteredCurrencies = _filterCurrencies();
    final filteredCrypto = _filterCrypto();

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
          return _buildCurrencyItem(currency['flag'], code, currency['name'], isFavorite, false);
        }),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Криптовалюта', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        ...filteredCrypto.map((entry) {
          final code = entry.key;
          final crypto = entry.value;
          final isFavorite = _favoriteCrypto.contains(code);
          return _buildCryptoItem(crypto['symbol'], code, crypto['name'], isFavorite, true);
        }),
      ],
    );
  }

  Widget _buildCurrencyItem(String flag, String code, String name, bool isFavorite, bool isCrypto) {
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
          onPressed: () => _toggleFavorite(code, isCrypto),
        ),
      ),
    );
  }

  Widget _buildCryptoItem(String symbol, String code, String name, bool isFavorite, bool isCrypto) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 1),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(symbol, style: const TextStyle(fontSize: 20, color: Colors.white))),
        ),
        title: Text(name, style: const TextStyle(fontSize: 16)),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? Colors.blue : Colors.grey,
          ),
          onPressed: () => _toggleFavorite(code, isCrypto),
        ),
      ),
    );
  }
}
