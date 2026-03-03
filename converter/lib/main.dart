import 'package:flutter/material.dart';

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
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildNewsSection(),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '💱',
                              style: TextStyle(fontSize: 35),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'MoneyMorph',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStocksSection(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Популярные валюты',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCurrencyCard('🇺🇸', 'USD', 'Доллар США', '470.00 ₸', '+0.5%', true),
                        _buildCurrencyCard('🇪🇺', 'EUR', 'Евро', '510.50 ₸', '+0.3%', true),
                        _buildCurrencyCard('🇬🇧', 'GBP', 'Фунт', '595.20 ₸', '-0.2%', false),
                        _buildCurrencyCard('🇨🇳', 'CNY', 'Юань', '64.80 ₸', '+0.1%', true),
                        _buildCurrencyCard('🇷🇺', 'RUB', 'Рубль', '5.10 ₸', '+0.8%', true),
                        _buildCurrencyCard('🇯🇵', 'JPY', 'Иена', '3.15 ₸', '-0.1%', false),
                        _buildCurrencyCard('🇨🇭', 'CHF', 'Франк', '534.00 ₸', '+0.4%', true),
                        _buildCurrencyCard('🇨🇦', 'CAD', 'Канадский доллар', '345.50 ₸', '+0.2%', true),
                        _buildCurrencyCard('🇦🇺', 'AUD', 'Австралийский доллар', '307.20 ₸', '-0.3%', false),
                        _buildCurrencyCard('🇰🇷', 'KRW', 'Вона', '0.36 ₸', '+0.1%', true),
                        _buildCurrencyCard('🇮🇳', 'INR', 'Рупия', '5.66 ₸', '+0.5%', true),
                        _buildCurrencyCard('🇧🇷', 'BRL', 'Реал', '94.60 ₸', '+1.2%', true),
                        _buildCurrencyCard('🇹🇷', 'TRY', 'Лира', '14.69 ₸', '-2.1%', false),
                        _buildCurrencyCard('🇲🇽', 'MXN', 'Песо', '27.65 ₸', '+0.3%', true),
                        _buildCurrencyCard('🇦🇪', 'AED', 'Дирхам', '128.00 ₸', '+0.2%', true),
                        const SizedBox(height: 24),
                        const Text(
                          'Криптовалюты',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCryptoCard('🟠', 'BTC', 'Bitcoin', '31,600,000 ₸', '+2.4%', true),
                        _buildCryptoCard('💎', 'ETH', 'Ethereum', '1,624,000 ₸', '+1.8%', true),
                        _buildCryptoCard('💵', 'USDT', 'Tether', '470 ₸', '+0.0%', true),
                        _buildCryptoCard('🟡', 'BNB', 'Binance Coin', '282,000 ₸', '+3.1%', true),
                        _buildCryptoCard('💠', 'XRP', 'Ripple', '235 ₸', '+5.2%', true),
                        _buildCryptoCard('🔵', 'ADA', 'Cardano', '188 ₸', '+1.5%', true),
                        _buildCryptoCard('⚪', 'DOGE', 'Dogecoin', '47 ₸', '+4.8%', true),
                        _buildCryptoCard('🟣', 'SOL', 'Solana', '47,000 ₸', '+6.3%', true),
                        _buildCryptoCard('🔷', 'DOT', 'Polkadot', '2,350 ₸', '+2.1%', true),
                        _buildCryptoCard('🟢', 'MATIC', 'Polygon', '376 ₸', '+3.7%', true),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ConverterScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Начать конвертацию',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Новости',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        _buildNewsItem('Доллар ускорил рост к евро и фунту, умеренно укрепляется к иене', '5 мин'),
        _buildNewsItem('Нефть ускорила рост, Brent приближается к \$84 за баррель', '1 ч'),
        _buildNewsItem('Средневзвешенный курс тенге на KASE во вторник вновь укрепляется', '2 ч'),
      ],
    );
  }

  Widget _buildStocksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'Акции',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        _buildStockItem('AAPL', '\$175.43', '+2.4%', true),
        _buildStockItem('TSLA', '\$248.50', '+5.1%', true),
        _buildStockItem('GOOGL', '\$139.20', '-0.8%', false),
        _buildStockItem('MSFT', '\$378.91', '+1.2%', true),
      ],
    );
  }

  Widget _buildNewsItem(String text, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time, size: 10, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockItem(String symbol, String price, String change, bool isUp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            symbol,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            change,
            style: TextStyle(
              fontSize: 11,
              color: isUp ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyCard(String flag, String code, String name, String price, String change, bool isUp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  color: isUp ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoCard(String symbol, String code, String name, String price, String change, bool isUp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667eea).withOpacity(0.1),
            const Color(0xFF764ba2).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF667eea).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                symbol,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667eea),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  color: isUp ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'RUB';
  double _result = 0;

  final Map<String, Map<String, dynamic>> _currencies = {
    'USD': {'rate': 1.0, 'symbol': '\$', 'name': 'Доллар США', 'flag': '🇺🇸'},
    'EUR': {'rate': 0.92, 'symbol': '€', 'name': 'Евро', 'flag': '🇪🇺'},
    'RUB': {'rate': 92.0, 'symbol': '₽', 'name': 'Российский рубль', 'flag': '🇷🇺'},
    'GBP': {'rate': 0.79, 'symbol': '£', 'name': 'Фунт стерлингов', 'flag': '🇬🇧'},
    'JPY': {'rate': 149.0, 'symbol': '¥', 'name': 'Японская иена', 'flag': '🇯🇵'},
    'CNY': {'rate': 7.24, 'symbol': '¥', 'name': 'Китайский юань', 'flag': '🇨🇳'},
    'CHF': {'rate': 0.88, 'symbol': '₣', 'name': 'Швейцарский франк', 'flag': '🇨🇭'},
    'CAD': {'rate': 1.36, 'symbol': '\$', 'name': 'Канадский доллар', 'flag': '🇨🇦'},
    'AUD': {'rate': 1.53, 'symbol': '\$', 'name': 'Австралийский доллар', 'flag': '🇦🇺'},
    'KRW': {'rate': 1320.0, 'symbol': '₩', 'name': 'Южнокорейская вона', 'flag': '🇰🇷'},
    'INR': {'rate': 83.0, 'symbol': '₹', 'name': 'Индийская рупия', 'flag': '🇮🇳'},
    'BRL': {'rate': 4.97, 'symbol': 'R\$', 'name': 'Бразильский реал', 'flag': '🇧🇷'},
    'TRY': {'rate': 32.0, 'symbol': '₺', 'name': 'Турецкая лира', 'flag': '🇹🇷'},
    'MXN': {'rate': 17.0, 'symbol': '\$', 'name': 'Мексиканское песо', 'flag': '🇲🇽'},
    'AED': {'rate': 3.67, 'symbol': 'د.إ', 'name': 'Дирхам ОАЭ', 'flag': '🇦🇪'},
    'SGD': {'rate': 1.34, 'symbol': '\$', 'name': 'Сингапурский доллар', 'flag': '🇸🇬'},
    'NZD': {'rate': 1.63, 'symbol': '\$', 'name': 'Новозеландский доллар', 'flag': '🇳🇿'},
    'SEK': {'rate': 10.5, 'symbol': 'kr', 'name': 'Шведская крона', 'flag': '🇸🇪'},
    'NOK': {'rate': 10.8, 'symbol': 'kr', 'name': 'Норвежская крона', 'flag': '🇳🇴'},
    'DKK': {'rate': 6.85, 'symbol': 'kr', 'name': 'Датская крона', 'flag': '🇩🇰'},
    'PLN': {'rate': 3.95, 'symbol': 'zł', 'name': 'Польский злотый', 'flag': '🇵🇱'},
    'THB': {'rate': 35.5, 'symbol': '฿', 'name': 'Тайский бат', 'flag': '🇹🇭'},
    'MYR': {'rate': 4.65, 'symbol': 'RM', 'name': 'Малайзийский ринггит', 'flag': '🇲🇾'},
    'IDR': {'rate': 15700.0, 'symbol': 'Rp', 'name': 'Индонезийская рупия', 'flag': '🇮🇩'},
    'PHP': {'rate': 56.0, 'symbol': '₱', 'name': 'Филиппинское песо', 'flag': '🇵🇭'},
    'ZAR': {'rate': 18.5, 'symbol': 'R', 'name': 'Южноафриканский рэнд', 'flag': '🇿🇦'},
    'HKD': {'rate': 7.82, 'symbol': '\$', 'name': 'Гонконгский доллар', 'flag': '🇭🇰'},
    'SAR': {'rate': 3.75, 'symbol': 'ر.س', 'name': 'Саудовский риял', 'flag': '🇸🇦'},
    'ILS': {'rate': 3.65, 'symbol': '₪', 'name': 'Израильский шекель', 'flag': '🇮🇱'},
    'CZK': {'rate': 22.5, 'symbol': 'Kč', 'name': 'Чешская крона', 'flag': '🇨🇿'},
    'HUF': {'rate': 355.0, 'symbol': 'Ft', 'name': 'Венгерский форинт', 'flag': '🇭🇺'},
    'ARS': {'rate': 850.0, 'symbol': '\$', 'name': 'Аргентинское песо', 'flag': '🇦🇷'},
    'CLP': {'rate': 920.0, 'symbol': '\$', 'name': 'Чилийское песо', 'flag': '🇨🇱'},
    'COP': {'rate': 4100.0, 'symbol': '\$', 'name': 'Колумбийское песо', 'flag': '🇨🇴'},
    'EGP': {'rate': 48.5, 'symbol': '£', 'name': 'Египетский фунт', 'flag': '🇪🇬'},
    'VND': {'rate': 24500.0, 'symbol': '₫', 'name': 'Вьетнамский донг', 'flag': '🇻🇳'},
    'UAH': {'rate': 41.0, 'symbol': '₴', 'name': 'Украинская гривна', 'flag': '🇺🇦'},
    'KZT': {'rate': 470.0, 'symbol': '₸', 'name': 'Казахстанский тенге', 'flag': '🇰🇿'},
    'BYN': {'rate': 3.25, 'symbol': 'Br', 'name': 'Белорусский рубль', 'flag': '🇧🇾'},
  };

  void _convert() {
    if (_amountController.text.isEmpty) return;
    double amount = double.tryParse(_amountController.text) ?? 0;
    double fromRate = _currencies[_fromCurrency]!['rate'];
    double toRate = _currencies[_toCurrency]!['rate'];
    setState(() {
      _result = (amount / fromRate) * toRate;
    });
  }

  void _swap() {
    setState(() {
      String temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _convert();
    });
  }

  void _showCurrencyPicker(bool isFrom) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencyPickerSheet(currencies: _currencies),
    );
    if (selected != null) {
      setState(() {
        if (isFrom) {
          _fromCurrency = selected;
        } else {
          _toCurrency = selected;
        }
        _convert();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Конвертер Валют', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF667eea))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF667eea), size: 28),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Сумма',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        border: InputBorder.none,
                        prefixText: '${_currencies[_fromCurrency]!['symbol']} ',
                        prefixStyle: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667eea),
                        ),
                      ),
                      onChanged: (value) => _convert(),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _showCurrencyPicker(true),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _currencies[_fromCurrency]!['flag'],
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _currencies[_fromCurrency]!['symbol'],
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_fromCurrency, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text(
                                    _currencies[_fromCurrency]!['name'],
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF667eea).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.search, color: Color(0xFF667eea), size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: _swap,
                    child: const Center(
                      child: Icon(Icons.swap_vert, color: Color(0xFF667eea), size: 32),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Результат',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          '${_currencies[_toCurrency]!['symbol']} ',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _result.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _showCurrencyPicker(false),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _currencies[_toCurrency]!['flag'],
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _currencies[_toCurrency]!['symbol'],
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_toCurrency, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                  Text(
                                    _currencies[_toCurrency]!['name'],
                                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.search, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),
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
}

class CurrencyPickerSheet extends StatefulWidget {
  final Map<String, Map<String, dynamic>> currencies;

  const CurrencyPickerSheet({super.key, required this.currencies});

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  String _searchQuery = '';
  
  List<String> get _filteredCurrencies {
    if (_searchQuery.isEmpty) {
      return widget.currencies.keys.toList();
    }
    return widget.currencies.keys.where((code) {
      final currency = widget.currencies[code]!;
      return code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             currency['name'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Поиск валюты...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF667eea)),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCurrencies.length,
              itemBuilder: (context, index) {
                final code = _filteredCurrencies[index];
                final currency = widget.currencies[code]!;
                return ListTile(
                  leading: Text(
                    currency['flag'],
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Row(
                    children: [
                      Text(
                        currency['symbol'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        code,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  subtitle: Text(currency['name']),
                  onTap: () {
                    Navigator.pop(context, code);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
