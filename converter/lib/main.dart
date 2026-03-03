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
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'MoneyMorph',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Покупка и продажа валют',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '💱',
                          style: TextStyle(fontSize: 50),
                        ),
                      ),
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
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TradingScreen()),
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
                              'Начать торговлю',
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

class TradingScreen extends StatefulWidget {
  const TradingScreen({super.key});

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, double> inventory = {'KZT': 100000.0};
  List<Map<String, dynamic>> marketListings = [];

  final List<Map<String, dynamic>> currencies = [
    {'flag': '🇺🇸', 'code': 'USD', 'name': 'Доллар США', 'buyPrice': 475.0, 'sellPrice': 465.0},
    {'flag': '🇪🇺', 'code': 'EUR', 'name': 'Евро', 'buyPrice': 515.0, 'sellPrice': 505.0},
    {'flag': '🇬🇧', 'code': 'GBP', 'name': 'Фунт', 'buyPrice': 600.0, 'sellPrice': 590.0},
    {'flag': '🇨🇳', 'code': 'CNY', 'name': 'Юань', 'buyPrice': 66.0, 'sellPrice': 63.0},
    {'flag': '🇷🇺', 'code': 'RUB', 'name': 'Рубль', 'buyPrice': 5.2, 'sellPrice': 5.0},
    {'flag': '🇯🇵', 'code': 'JPY', 'name': 'Иена', 'buyPrice': 3.2, 'sellPrice': 3.1},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _buyCurrency(String code, double price) {
    showDialog(
      context: context,
      builder: (context) => BuyDialog(
        code: code,
        price: price,
        balance: inventory['KZT'] ?? 0,
        onBuy: (amount) {
          setState(() {
            double cost = amount * price;
            inventory['KZT'] = (inventory['KZT'] ?? 0) - cost;
            inventory[code] = (inventory[code] ?? 0) + amount;
          });
        },
      ),
    );
  }

  void _sellCurrency(String code, double price) {
    double available = inventory[code] ?? 0;
    if (available <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('У вас нет $code для продажи')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => MarketSellDialog(
        code: code,
        available: available,
        onSell: (amount, customPrice) {
          setState(() {
            inventory[code] = (inventory[code] ?? 0) - amount;
            marketListings.add({
              'code': code,
              'amount': amount,
              'price': customPrice,
              'seller': 'Вы',
            });
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Торговля валютой', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF667eea),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF667eea),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF667eea),
          tabs: const [
            Tab(text: 'Рынок'),
            Tab(text: 'Инвентарь'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMarketTab(),
          _buildInventoryTab(),
        ],
      ),
    );
  }

  Widget _buildMarketTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Рынок валют',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Покупайте и продавайте валюту',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        const Text(
          'Купить валюту',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...currencies.map((currency) => _buildBuyCurrencyCard(currency)),
        const SizedBox(height: 24),
        const Text(
          'Продать валюту',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...currencies.map((currency) => _buildSellCurrencyCard(currency)),
        const SizedBox(height: 24),
        const Text(
          'Объявления пользователей',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (marketListings.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Нет объявлений',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          )
        else
          ...marketListings.map((listing) => _buildMarketListingCard(listing)),
      ],
    );
  }

  Widget _buildInventoryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Мой баланс',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    '${(inventory['KZT'] ?? 0).toStringAsFixed(2)} ₸',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Мои валюты',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...inventory.entries.where((e) => e.key != 'KZT' && e.value > 0).map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      entry.key.substring(0, 1),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF667eea),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Валюта',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  entry.value.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667eea),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBuyCurrencyCard(Map<String, dynamic> currency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(currency['flag'], style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currency['code'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currency['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Цена: ${currency['buyPrice']} ₸',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667eea),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _buyCurrency(currency['code'], currency['buyPrice']),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Купить'),
          ),
        ],
      ),
    );
  }

  Widget _buildSellCurrencyCard(Map<String, dynamic> currency) {
    double available = inventory[currency['code']] ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(currency['flag'], style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currency['code'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currency['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Цена: ${currency['sellPrice']} ₸',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  'В наличии: ${available.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: available > 0 ? () => _sellCurrency(currency['code'], currency['sellPrice']) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Выставить'),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketListingCard(Map<String, dynamic> listing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF667eea).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                listing['code'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667eea),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing['code'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Кол-во: ${listing['amount'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Цена: ${listing['price'].toStringAsFixed(2)} ₸',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667eea),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (listing['seller'] == 'Вы') {
                setState(() {
                  inventory[listing['code']] = (inventory[listing['code']] ?? 0) + listing['amount'];
                  marketListings.remove(listing);
                });
              } else {
                double totalCost = listing['amount'] * listing['price'];
                if ((inventory['KZT'] ?? 0) >= totalCost) {
                  setState(() {
                    inventory['KZT'] = (inventory['KZT'] ?? 0) - totalCost;
                    inventory[listing['code']] = (inventory[listing['code']] ?? 0) + listing['amount'];
                    marketListings.remove(listing);
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: listing['seller'] == 'Вы' ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(listing['seller'] == 'Вы' ? 'Снять' : 'Купить'),
          ),
        ],
      ),
    );
  }
}

class MarketSellDialog extends StatefulWidget {
  final String code;
  final double available;
  final Function(double, double) onSell;

  const MarketSellDialog({
    super.key,
    required this.code,
    required this.available,
    required this.onSell,
  });

  @override
  State<MarketSellDialog> createState() => _MarketSellDialogState();
}

class _MarketSellDialogState extends State<MarketSellDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Выставить ${widget.code}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Доступно: ${widget.available.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Количество',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Цена за 1 (₸)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            double amount = double.tryParse(_amountController.text) ?? 0;
            double price = double.tryParse(_priceController.text) ?? 0;
            if (amount > 0 && price > 0 && amount <= widget.available) {
              widget.onSell(amount, price);
              Navigator.pop(context);
            }
          },
          child: const Text('Выставить'),
        ),
      ],
    );
  }
}

class BuyDialog extends StatefulWidget {
  final String code;
  final double price;
  final double balance;
  final Function(double) onBuy;

  const BuyDialog({
    super.key,
    required this.code,
    required this.price,
    required this.balance,
    required this.onBuy,
  });

  @override
  State<BuyDialog> createState() => _BuyDialogState();
}

class _BuyDialogState extends State<BuyDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Купить ${widget.code}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Цена: ${widget.price} ₸'),
          Text('Баланс: ${widget.balance.toStringAsFixed(2)} ₸'),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Количество',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            double amount = double.tryParse(_controller.text) ?? 0;
            if (amount > 0 && amount * widget.price <= widget.balance) {
              widget.onBuy(amount);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Куплено ${amount.toStringAsFixed(2)} ${widget.code}')),
              );
            }
          },
          child: const Text('Купить'),
        ),
      ],
    );
  }
}

class SellDialog extends StatefulWidget {
  final String code;
  final double price;
  final double available;
  final Function(double) onSell;

  const SellDialog({
    super.key,
    required this.code,
    required this.price,
    required this.available,
    required this.onSell,
  });

  @override
  State<SellDialog> createState() => _SellDialogState();
}

class _SellDialogState extends State<SellDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Продать ${widget.code}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Цена: ${widget.price} ₸'),
          Text('Доступно: ${widget.available.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Количество',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            double amount = double.tryParse(_controller.text) ?? 0;
            if (amount > 0 && amount <= widget.available) {
              widget.onSell(amount);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Продано ${amount.toStringAsFixed(2)} ${widget.code}')),
              );
            }
          },
          child: const Text('Продать'),
        ),
      ],
    );
  }
}
