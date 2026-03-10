import 'package:flutter/material.dart';
import 'currency_data.dart';
import 'converter_screen.dart';
import 'crypto_screen.dart';
import 'other_screen.dart';
import 'country_selection_screen.dart';
import 'currency_service.dart';
import 'translations.dart';
import 'exchangers_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Конвертер Валют',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainScreen(onThemeToggle: toggleTheme, isDarkMode: isDarkMode),
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const MainScreen({super.key, required this.onThemeToggle, required this.isDarkMode});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String selectedCountry = 'KZT';
  String selectedLanguage = 'ru';
  Map<String, double> exchangeRates = {};
  List<String> favoriteCurrencies = ['USD', 'EUR', 'RUB'];
  List<String> favoriteCrypto = ['BTC'];

  final allCurrencies = worldCurrencies;
  final allCrypto = worldCrypto;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    final rates = await CurrencyService.fetchRates(selectedCountry);
    setState(() {
      exchangeRates = rates;
    });
  }

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
      case 1:
        return ExchangersScreen(selectedLanguage: selectedLanguage);
      case 2:
        return const CryptoScreen();
      case 3:
        return ConverterScreen(selectedLanguage: selectedLanguage);
      case 4:
        return OtherScreen(
          selectedCountry: selectedCountry,
          selectedLanguage: selectedLanguage,
          onCountryChanged: (country) {
            setState(() {
              selectedCountry = country;
            });
            _loadRates();
          },
          onLanguageChanged: (language) {
            setState(() {
              selectedLanguage = language;
            });
          },
        );
      default:
        return Center(child: Text('Страница ${_selectedIndex + 1}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _getScreen()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: tr('home', selectedLanguage)),
          BottomNavigationBarItem(icon: const Icon(Icons.swap_horiz), label: tr('exchangers', selectedLanguage)),
          BottomNavigationBarItem(icon: const Icon(Icons.currency_bitcoin), label: tr('crypto', selectedLanguage)),
          BottomNavigationBarItem(icon: const Icon(Icons.calculate), label: tr('converter', selectedLanguage)),
          BottomNavigationBarItem(icon: const Icon(Icons.more_horiz), label: tr('other', selectedLanguage)),
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
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CountrySelectionScreen(selectedCountry: selectedCountry),
                  ),
                );
                if (result != null) {
                  setState(() {
                    selectedCountry = result;
                  });
                  _loadRates();
                }
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Color(0xFF00BFFF), Color(0xFF1E90FF)]),
                ),
                child: const Icon(Icons.flag, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(tr('home', selectedLanguage), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: widget.onThemeToggle,
            ),
            TextButton(onPressed: _openEditScreen, child: Text(tr('edit', selectedLanguage))),
          ],
        ),
        const SizedBox(height: 24),
        Text(tr('currencyRates', selectedLanguage), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...favoriteCurrencies.map((code) {
          final currency = allCurrencies[code]!;
          final rate = exchangeRates[code];
          final price = rate != null ? '${(1 / rate).toStringAsFixed(2)}' : currency['price'];
          return _buildCurrencyCard(currency['flag'], code, price, currency['change'], currency['isUp']);
        }),
        const SizedBox(height: 24),
        Text(tr('crypto', selectedLanguage), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
        color: Theme.of(context).cardColor,
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
        color: Theme.of(context).cardColor,
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
      appBar: AppBar(
        title: Text(tr('changeFavorites', 'ru')),
        leading: IconButton(
          icon: const Icon(Icons.close),
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
            child: Text(tr('done', 'ru'), style: const TextStyle(fontSize: 16)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: tr('favorites', 'ru')),
                  Tab(text: tr('all', 'ru')),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: tr('search', 'ru'),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(tr('currencyRates', 'ru'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          ..._favoriteCurrencies.map((code) {
            final currency = widget.allCurrencies[code]!;
            return _buildCurrencyItem(currency['flag'], code, currency['name'], true, false);
          }),
        ],
        if (_favoriteCrypto.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(tr('crypto', 'ru'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 32)),
      title: Text(name, style: const TextStyle(fontSize: 16)),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite ? Colors.blue : Colors.grey,
        ),
        onPressed: () => _toggleFavorite(code, isCrypto),
      ),
    );
  }

  Widget _buildCryptoItem(String symbol, String code, String name, bool isFavorite, bool isCrypto) {
    return ListTile(
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
    );
  }
}
