import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'currency_data.dart';
import 'converter_screen.dart';
import 'crypto_screen.dart';
import 'other_screen.dart';
import 'country_selection_screen.dart';
import 'currency_service.dart';
import 'translations.dart';
import 'exchangers_screen.dart';
import 'trading_chart_screen.dart';
import 'risk_service.dart';
import 'forecast_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://tfaghwznyvveoxpqbruo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRmYWdod3pueXZ2ZW94cHFicnVvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ5NDQxNTgsImV4cCI6MjA5MDUyMDE1OH0.M3uk1bTg1WUox2_9ZvS8SEPu6L1KD5_R16HgIoAx4b4',
  );
  runApp(const MyApp());
}

class _FadeScalePageTransition extends PageTransitionsBuilder {
  const _FadeScalePageTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        ),
        child: child,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Конвертер Валют',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        cardColor: Colors.white.withValues(alpha: 0.08),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _FadeScalePageTransition(),
            TargetPlatform.iOS: _FadeScalePageTransition(),
            TargetPlatform.windows: _FadeScalePageTransition(),
            TargetPlatform.linux: _FadeScalePageTransition(),
            TargetPlatform.macOS: _FadeScalePageTransition(),
          },
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black.withValues(alpha: 0.7),
          selectedItemColor: const Color(0xFF42A5F5),
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white70),
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
  String selectedCountry = 'KZT';
  String selectedLanguage = 'ru';
  bool isLoggedIn = false;
  bool isLegalEntity = false;
  Map<String, double> exchangeRates = {};
  List<String> favoriteCurrencies = ['USD', 'EUR', 'RUB'];
  List<String> favoriteCrypto = ['BTC'];
  
  List<Map<String, String>> aiuBankRates = [
    {'flag': '🇺🇸', 'buy': '480', 'sell': '488'},
    {'flag': '🇪🇺', 'buy': '558', 'sell': '568'},
    {'flag': '🇷🇺', 'buy': '5,9', 'sell': '6,4'},
  ];
  
  List<Map<String, dynamic>> rateHistory = [];
  List<RiskAlert> riskAlerts = [];
  List<BankForecast> bankForecasts = [];

  final allCurrencies = worldCurrencies;
  final allCrypto = worldCrypto;

  @override
  void initState() {
    super.initState();
    _loadRates();

    _testSupabaseConnection();
  }

  Future<void> _loadRates() async {
    final rates = await CurrencyService.fetchRates(selectedCountry);
    setState(() {
      exchangeRates = rates;
    });
  }

  Future<void> _testSupabaseConnection() async {
    try {
      // Пробуем просто обратиться к клиенту Supabase (чтобы инициализациялась)
      final response = Supabase.instance.client;
      if (response != null) {
        print("✅ Supabase успешно инициализирован");
      }
      // В Supabase 2.x URL доступен через options (если нужна трассировка): response.options.url
      // print("Supabase URL: ${response.options.url}");
    } catch (e) {
      print("❌ Ошибка подключения к Supabase: $e");
      print("Проверь файл .env и наличие интернета");
    }
  }

  void _onRatesUpdate(List<Map<String, String>> newRates) {
    final newAlerts = RiskService.analyzeRates(newRates);
    setState(() {
      aiuBankRates = newRates;
      rateHistory.insert(0, {
        'date': DateTime.now(),
        'rates': List<Map<String, String>>.from(newRates),
      });
      riskAlerts.insertAll(0, newAlerts);
    });
    if (newAlerts.isNotEmpty) {
      _showRiskBanner(newAlerts.first);
    }
  }

  void _showRiskBanner(RiskAlert alert) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: alert.isWarning ? const Color(0xFFFF6B00) : Colors.green,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 12),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      alert.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.description,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        return ExchangersScreen(
          selectedLanguage: selectedLanguage,
          isLoggedIn: isLoggedIn,
          isLegalEntity: isLegalEntity,
          aiuBankRates: aiuBankRates,
          onRatesUpdate: _onRatesUpdate,
        );
      case 2:
        return isLoggedIn && isLegalEntity
            ? TradingChartScreen(
                selectedLanguage: selectedLanguage,
                aiuBankRates: aiuBankRates,
                rateHistory: rateHistory,
              )
            : const CryptoScreen();
      case 3:
        return ConverterScreen(selectedLanguage: selectedLanguage);
      case 4:
        return OtherScreen(
          selectedCountry: selectedCountry,
          selectedLanguage: selectedLanguage,
          isLoggedIn: isLoggedIn,
          isLegalEntity: isLegalEntity,
          aiuBankRates: aiuBankRates,
          rateHistory: rateHistory,
          riskAlerts: riskAlerts,
          bankForecasts: bankForecasts,
          onForecastsUpdate: (forecasts) {
            setState(() => bankForecasts = forecasts);
          },
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
          onLogin: (bool isLegal) {
            setState(() {
              isLoggedIn = true;
              isLegalEntity = isLegal;
            });
          },
          onLogout: () {
            setState(() {
              isLoggedIn = false;
              isLegalEntity = false;
            });
          },
          onNavigateToChart: () {
            setState(() {
              _selectedIndex = 2;
            });
          },
          onNavigateToHome: () {
            setState(() {
              _selectedIndex = 0;
            });
          },
          onRatesUpdate: _onRatesUpdate,
        );
      default:
        return Center(child: Text('Страница ${_selectedIndex + 1}'));
    }
  }

  Widget _wrapWithBg(Widget child) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.45)),
        ),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      extendBody: true,
      body: _wrapWithBg(SafeArea(child: _getScreen())),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: tr('home', selectedLanguage)),
          BottomNavigationBarItem(icon: const Icon(Icons.swap_horiz), label: tr('exchangers', selectedLanguage)),
          BottomNavigationBarItem(
            icon: const Icon(Icons.currency_bitcoin),
            label: isLoggedIn && isLegalEntity ? 'График торгов' : tr('crypto', selectedLanguage),
          ),
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
        if (isLoggedIn && isLegalEntity)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00E676)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('🏛️', style: TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aiu Bank',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Юридическое лицо',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
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
            Text(tr('home', selectedLanguage), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const Spacer(),

            TextButton(onPressed: _openEditScreen, child: Text(tr('edit', selectedLanguage))),
          ],
        ),
        const SizedBox(height: 24),
        Text(tr('currencyRates', selectedLanguage), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        ...favoriteCurrencies.map((code) {
          final currency = allCurrencies[code]!;
          final rate = exchangeRates[code];
          final price = rate != null ? '${(1 / rate).toStringAsFixed(2)}' : currency['price'];
          return _buildCurrencyCard(currency['flag'], code, price, currency['change'], currency['isUp']);
        }),
        const SizedBox(height: 24),
        Text(tr('crypto', selectedLanguage), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Text(code, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(change, style: TextStyle(fontSize: 14, color: isUp ? const Color(0xFF4CAF50) : const Color(0xFFEF5350))),
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
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
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
          Text(code, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(change, style: TextStyle(fontSize: 14, color: isUp ? const Color(0xFF4CAF50) : const Color(0xFFEF5350))),
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
