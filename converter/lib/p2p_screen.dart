import 'package:flutter/material.dart';

class P2POffer {
  final String username;
  final int deals;
  final double rating;
  final double price;
  final double limitMin;
  final double limitMax;
  final double available;
  final List<String> payMethods;
  final bool isOnline;
  final bool isPromoted;

  const P2POffer({
    required this.username,
    required this.deals,
    required this.rating,
    required this.price,
    required this.limitMin,
    required this.limitMax,
    required this.available,
    required this.payMethods,
    this.isOnline = true,
    this.isPromoted = false,
  });
}

class P2PScreen extends StatefulWidget {
  const P2PScreen({super.key});

  @override
  State<P2PScreen> createState() => _P2PScreenState();
}

class _P2PScreenState extends State<P2PScreen> {
  bool _isBuy = true;
  String _currency = 'USD';

  static const _currencies = ['USD', 'EUR', 'RUB'];
  static const _flags = {'USD': '🇺🇸', 'EUR': '🇪🇺', 'RUB': '🇷🇺'};

  final _buyOffers = {
    'USD': [
      P2POffer(username: 'AiuTrader', deals: 621, rating: 98.3, price: 488.5, limitMin: 50000, limitMax: 3000000, available: 12489.4, payMethods: ['Kaspi', 'Halyk'], isPromoted: true),
      P2POffer(username: 'Vladw23', deals: 498, rating: 93.3, price: 487.0, limitMin: 66999, limitMax: 67000, available: 714.77, payMethods: ['Kaspi']),
      P2POffer(username: 'SaloCoin', deals: 482, rating: 99.2, price: 486.9, limitMin: 200000, limitMax: 500000, available: 420.57, payMethods: ['Jusan', 'ForteBank']),
      P2POffer(username: 'KZTExchange', deals: 310, rating: 97.1, price: 486.0, limitMin: 10000, limitMax: 200000, available: 1500.0, payMethods: ['Halyk', 'BCC']),
      P2POffer(username: 'MoneyFlow', deals: 155, rating: 91.5, price: 485.5, limitMin: 5000, limitMax: 100000, available: 800.0, payMethods: ['Kaspi'], isOnline: false),
    ],
    'EUR': [
      P2POffer(username: 'EuroDealer', deals: 340, rating: 96.5, price: 568.0, limitMin: 50000, limitMax: 2000000, available: 5000.0, payMethods: ['Halyk', 'Kaspi'], isPromoted: true),
      P2POffer(username: 'FxMaster', deals: 210, rating: 94.0, price: 566.5, limitMin: 30000, limitMax: 500000, available: 2300.0, payMethods: ['Jusan']),
      P2POffer(username: 'AlmatyFX', deals: 180, rating: 98.8, price: 565.0, limitMin: 10000, limitMax: 300000, available: 1100.0, payMethods: ['BCC', 'ForteBank']),
    ],
    'RUB': [
      P2POffer(username: 'RubTrader', deals: 890, rating: 99.1, price: 6.4, limitMin: 10000, limitMax: 500000, available: 250000.0, payMethods: ['Kaspi', 'Halyk'], isPromoted: true),
      P2POffer(username: 'SteppeEx', deals: 430, rating: 95.7, price: 6.35, limitMin: 5000, limitMax: 100000, available: 80000.0, payMethods: ['Jusan']),
      P2POffer(username: 'NordFX', deals: 275, rating: 92.3, price: 6.3, limitMin: 1000, limitMax: 50000, available: 30000.0, payMethods: ['ForteBank'], isOnline: false),
    ],
  };

  final _sellOffers = {
    'USD': [
      P2POffer(username: 'BuyerKZ', deals: 512, rating: 97.8, price: 484.0, limitMin: 50000, limitMax: 1000000, available: 8000.0, payMethods: ['Kaspi'], isPromoted: true),
      P2POffer(username: 'AlmaExch', deals: 320, rating: 95.2, price: 483.5, limitMin: 20000, limitMax: 300000, available: 3200.0, payMethods: ['Halyk', 'BCC']),
      P2POffer(username: 'TengeMart', deals: 198, rating: 90.0, price: 483.0, limitMin: 10000, limitMax: 150000, available: 1800.0, payMethods: ['Jusan'], isOnline: false),
    ],
    'EUR': [
      P2POffer(username: 'EuroBuyer', deals: 280, rating: 96.0, price: 562.0, limitMin: 30000, limitMax: 800000, available: 4000.0, payMethods: ['Kaspi'], isPromoted: true),
      P2POffer(username: 'CityFX', deals: 145, rating: 93.5, price: 561.0, limitMin: 10000, limitMax: 200000, available: 1500.0, payMethods: ['Halyk']),
    ],
    'RUB': [
      P2POffer(username: 'RubBuyer', deals: 760, rating: 98.5, price: 6.1, limitMin: 5000, limitMax: 200000, available: 150000.0, payMethods: ['Kaspi', 'Jusan'], isPromoted: true),
      P2POffer(username: 'StepBuy', deals: 390, rating: 94.1, price: 6.05, limitMin: 1000, limitMax: 80000, available: 60000.0, payMethods: ['Halyk']),
    ],
  };

  List<P2POffer> get _currentOffers =>
      (_isBuy ? _buyOffers[_currency] : _sellOffers[_currency]) ?? [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildFilters(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: _currentOffers.length,
            itemBuilder: (context, i) => _buildCard(_currentOffers[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          // Купить / Продать переключатель
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _modeBtn('Купить', true),
                _modeBtn('Продать', false),
              ],
            ),
          ),
          const Spacer(),
          // Кнопка создать объявление
          GestureDetector(
            onTap: () => _showCreateSheet(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00C853).withOpacity(0.4)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Color(0xFF00C853), size: 16),
                  SizedBox(width: 4),
                  Text('Объявление', style: TextStyle(fontSize: 13, color: Color(0xFF00C853), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeBtn(String label, bool isBuy) {
    final selected = _isBuy == isBuy;
    return GestureDetector(
      onTap: () => setState(() => _isBuy = isBuy),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? (isBuy ? const Color(0xFF00C853) : const Color(0xFFFF1744)) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _currencies.map((c) {
          final selected = _currency == c;
          return GestureDetector(
            onTap: () => setState(() => _currency = c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF00C853).withOpacity(0.15) : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? const Color(0xFF00C853) : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_flags[c]!, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(c, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? const Color(0xFF00C853) : Colors.white70)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCard(P2POffer offer) {
    final actionColor = _isBuy ? const Color(0xFF00C853) : const Color(0xFFFF1744);
    final actionLabel = _isBuy ? 'Купить' : 'Продать';

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: offer.isPromoted ? Colors.white.withOpacity(0.09) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: offer.isPromoted ? const Color(0xFF00C853).withOpacity(0.3) : Colors.white.withOpacity(0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (offer.isPromoted)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, size: 14, color: const Color(0xFF00C853).withOpacity(0.8)),
                    const SizedBox(width: 4),
                    Text('Продвигаемое объявление',
                        style: TextStyle(fontSize: 11, color: const Color(0xFF00C853).withOpacity(0.8), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Аватар
                Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [actionColor.withOpacity(0.8), actionColor.withOpacity(0.4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          offer.username[0].toUpperCase(),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: offer.isOnline ? const Color(0xFF00C853) : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0D1B2A), width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                // Имя и статистика
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(offer.username, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text('Сделки ${offer.deals}', style: const TextStyle(fontSize: 11, color: Colors.white38)),
                          const SizedBox(width: 8),
                          const Icon(Icons.thumb_up_outlined, size: 11, color: Colors.white38),
                          const SizedBox(width: 3),
                          Text('${offer.rating}%', style: const TextStyle(fontSize: 11, color: Colors.white38)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Методы оплаты
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: offer.payMethods.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: actionColor, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(m, style: const TextStyle(fontSize: 11, color: Colors.white54)),
                      ],
                    ),
                  )).toList(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Курс
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₸ ${_formatNum(offer.price)}',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text('/$_currency', style: const TextStyle(fontSize: 13, color: Colors.white38)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Лимит  ${_formatNum(offer.limitMin)} – ${_formatNum(offer.limitMax)} ₸',
                          style: const TextStyle(fontSize: 12, color: Colors.white54)),
                      const SizedBox(height: 2),
                      Text('Доступно  ${_formatNum(offer.available)} $_currency',
                          style: const TextStyle(fontSize: 12, color: Colors.white54)),
                    ],
                  ),
                ),
                // Кнопка
                GestureDetector(
                  onTap: () => _showDealSheet(offer),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    decoration: BoxDecoration(
                      color: actionColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(actionLabel,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatNum(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) {
      final s = v.toStringAsFixed(v == v.truncate() ? 0 : 2);
      final parts = s.split('.');
      final intPart = parts[0].replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ');
      return parts.length > 1 ? '$intPart,${parts[1]}' : intPart;
    }
    return v.toStringAsFixed(2);
  }

  void _showDealSheet(P2POffer offer) {
    final actionColor = _isBuy ? const Color(0xFF00C853) : const Color(0xFFFF1744);
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0D1B2A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(offer.username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Spacer(),
                  Text('₸ ${_formatNum(offer.price)} /$_currency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: actionColor)),
                ],
              ),
              const SizedBox(height: 6),
              Text('Лимит: ${_formatNum(offer.limitMin)} – ${_formatNum(offer.limitMax)} ₸',
                  style: const TextStyle(fontSize: 13, color: Colors.white38)),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Сумма в ₸',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.07),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  suffixText: '₸',
                  suffixStyle: const TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: actionColor,
                        content: Text('Заявка отправлена продавцу ${offer.username}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actionColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(_isBuy ? 'Купить $_currency' : 'Продать $_currency',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateSheet() {
    String currency = _currency;
    bool isSell = !_isBuy;
    final priceCtrl = TextEditingController();
    final minCtrl = TextEditingController();
    final maxCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0D1B2A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                const Text('Создать объявление', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 20),
                // Тип
                Row(
                  children: [
                    _sheetChip('Продаю', !isSell, const Color(0xFF00C853), () => setS(() => isSell = false)),
                    const SizedBox(width: 8),
                    _sheetChip('Покупаю', isSell, const Color(0xFFFF1744), () => setS(() => isSell = true)),
                  ],
                ),
                const SizedBox(height: 16),
                // Валюта
                Row(
                  children: _currencies.map((c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _sheetChip('${_flags[c]} $c', currency == c, const Color(0xFF42A5F5), () => setS(() => currency = c)),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                _field(priceCtrl, 'Курс (₸)', '₸'),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _field(minCtrl, 'Мин. лимит', '₸')),
                  const SizedBox(width: 12),
                  Expanded(child: _field(maxCtrl, 'Макс. лимит', '₸')),
                ]),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF00C853),
                          content: const Text('Объявление опубликовано!',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Опубликовать', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetChip(String label, bool selected, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : Colors.white.withOpacity(0.1)),
        ),
        child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? color : Colors.white54)),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, String suffix) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: Colors.white54),
      ),
    );
  }
}
