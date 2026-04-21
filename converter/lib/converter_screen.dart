import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'currency_data.dart';
import 'translations.dart';
import 'app_background.dart';
import 'user_service.dart';
import 'l10n_service.dart';

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
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  String _voiceStatus = '';
  final TextEditingController _debugController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _initSpeech();
  }

  Future<void> _loadFavorites() async {
    final favorites = await UserService.getFavoriteCurrencies();
    setState(() {
      favoriteConverterCurrencies = favorites;
      for (var code in favoriteConverterCurrencies) {
        controllers[code] = TextEditingController(text: '0');
      }
    });
  }

  Future<void> _initSpeech() async {
    if (kIsWeb) {
      _speechAvailable = false;
      setState(() {});
      return;
    }
    try {
      _speechAvailable = await _speech.initialize();
    } catch (_) {
      _speechAvailable = false;
    }
    setState(() {});
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) return;
    setState(() {
      _isListening = true;
      _voiceStatus = 'Слушаю...';
    });
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _parseVoiceInput(result.recognizedWords);
          setState(() {
            _isListening = false;
            _voiceStatus = '';
          });
        }
      },
      localeId: 'ru_RU',
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _voiceStatus = '';
    });
  }

  void _parseVoiceInput(String text) async {
    text = text.toLowerCase().trim();

    // Ищем число
    final numberRegex = RegExp(r'(\d+(?:[.,]\d+)?)');
    final numberMatch = numberRegex.firstMatch(text);
    if (numberMatch == null) return;
    final amount = double.tryParse(numberMatch.group(1)!.replaceAll(',', '.'));
    if (amount == null) return;

    // Ищем валюту
    final currencyMap = {
      'доллар': 'USD', 'долларов': 'USD', 'доллара': 'USD', 'usd': 'USD',
      'евро': 'EUR', 'eur': 'EUR',
      'рубл': 'RUB', 'рублей': 'RUB', 'рубля': 'RUB', 'rub': 'RUB',
      'тенге': 'KZT', 'kzt': 'KZT',
      'юань': 'CNY', 'юаня': 'CNY', 'юаней': 'CNY',
      'фунт': 'GBP', 'фунтов': 'GBP',
      'иена': 'JPY', 'иен': 'JPY',
    };

    String? detectedCurrency;
    for (final entry in currencyMap.entries) {
      if (text.contains(entry.key)) {
        detectedCurrency = entry.value;
        break;
      }
    }

    // Если валюта не найдена — используем базовую
    final currency = detectedCurrency ?? baseCurrency;

    // Если валюта не в списке — добавляем
    if (!favoriteConverterCurrencies.contains(currency)) {
      setState(() {
        favoriteConverterCurrencies.add(currency);
        controllers[currency] = TextEditingController(text: '0');
      });
      await UserService.setFavoriteCurrencies(favoriteConverterCurrencies);
    }
    if (!controllers.containsKey(currency)) {
      controllers[currency] = TextEditingController(text: '0');
    }

    controllers[currency]?.text = amount.toString();
    _updateAllFields(currency, amount.toString());

    setState(() {
      _voiceStatus = 'Распознано: $amount ${currency}';
    });
  }

  void _openEditScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConverterEditScreen(
          favoriteCurrencies: favoriteConverterCurrencies,
          selectedLanguage: L10n.locale.languageCode,
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
      await UserService.setFavoriteCurrencies(favoriteConverterCurrencies);
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
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(tr('converter', L10n.locale.languageCode), style: const TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(icon: const Icon(Icons.edit), onPressed: _openEditScreen),
            IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          ],
        ),
        body: Column(
          children: [
            if (_voiceStatus.isNotEmpty)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _isListening
                      ? const Color(0xFF42A5F5).withValues(alpha: 0.15)
                      : Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isListening ? const Color(0xFF42A5F5) : Colors.green,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isListening ? Icons.mic : Icons.check_circle,
                      color: _isListening ? const Color(0xFF42A5F5) : Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _voiceStatus,
                      style: TextStyle(
                        color: _isListening ? const Color(0xFF42A5F5) : Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            // DEBUG: тестовое поле для веба
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _debugController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: tr('exampleInput', widget.selectedLanguage),
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (value) {
                        _parseVoiceInput(value);
                        _debugController.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _parseVoiceInput(_debugController.text);
                      _debugController.clear();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ...favoriteConverterCurrencies.map((code) {
                    final currency = worldCurrencies[code];
                    if (currency == null) return const SizedBox();
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        children: [
                          Text(currency['flag'], style: const TextStyle(fontSize: 40)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(code, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text(currency['name'], style: const TextStyle(fontSize: 14, color: Colors.white54)),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: TextField(
                              controller: controllers[code] ?? TextEditingController(text: '0'),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              decoration: const InputDecoration(border: InputBorder.none),
                              onChanged: (value) => _updateAllFields(code, value),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: _speechAvailable
            ? GestureDetector(
                onTap: _isListening ? _stopListening : _startListening,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isListening
                          ? [const Color(0xFFEF5350), const Color(0xFFE53935)]
                          : [const Color(0xFF42A5F5), const Color(0xFF1565C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? Colors.red : const Color(0xFF42A5F5)).withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class ConverterEditScreen extends StatefulWidget {
  final List<String> favoriteCurrencies;
  final String selectedLanguage;

  const ConverterEditScreen({
    super.key,
    required this.favoriteCurrencies,
    required this.selectedLanguage,
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
      appBar: AppBar(
        title: Text(tr('changeFavorites', L10n.locale.languageCode)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _favoriteCurrencies);
            },
            child: Text(tr('done', L10n.locale.languageCode), style: const TextStyle(fontSize: 16)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: tr('favorites', L10n.locale.languageCode)),
                  Tab(text: tr('all', L10n.locale.languageCode)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: tr('search', L10n.locale.languageCode),
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
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 32)),
      title: Text(name, style: const TextStyle(fontSize: 16)),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite ? Colors.blue : Colors.grey,
        ),
        onPressed: () => _toggleFavorite(code),
      ),
    );
  }
}
