import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_background.dart';

final _supabase = Supabase.instance.client;

class P2PScreen extends StatefulWidget {
  const P2PScreen({super.key});

  @override
  State<P2PScreen> createState() => _P2PScreenState();
}

class _P2PScreenState extends State<P2PScreen> {
  bool _isBuy = true;
  String _currency = 'USD';
  List<Map<String, dynamic>> _offers = [];
  bool _loading = true;

  static const _currencies = ['USD', 'EUR', 'RUB'];
  static const _flags = {'USD': '🇺🇸', 'EUR': '🇪🇺', 'RUB': '🇷🇺'};

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() => _loading = true);
    try {
      final type = _isBuy ? 'sell' : 'buy';
      final res = await _supabase
          .from('p2p_offers')
          .select()
          .eq('currency', _currency)
          .eq('type', type)
          .eq('is_active', true)
          .order('price', ascending: _isBuy);
      setState(() => _offers = List<Map<String, dynamic>>.from(res));
    } catch (_) {}
    setState(() => _loading = false);
  }

  String get _uid => _supabase.auth.currentUser?.id ?? '';
  String get _username => _supabase.auth.currentUser?.email?.split('@').first ?? 'user';

  void _showCreateOffer() {
    if (_uid.isEmpty) {
      _showSnack('Войдите в аккаунт чтобы создать объявление', const Color(0xFFFF1744));
      return;
    }
    String type = 'sell';
    String currency = _currency;
    final priceCtrl = TextEditingController();
    final minCtrl = TextEditingController();
    final maxCtrl = TextEditingController();
    final availCtrl = TextEditingController();
    List<String> selectedMethods = ['Kaspi'];

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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  const Text('Создать объявление', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  const Text('Тип', style: TextStyle(fontSize: 13, color: Colors.white54)),
                  const SizedBox(height: 8),
                  Row(children: [
                    _chip('Продаю', type == 'sell', const Color(0xFF00C853), () => setS(() => type = 'sell')),
                    const SizedBox(width: 8),
                    _chip('Покупаю', type == 'buy', const Color(0xFFFF1744), () => setS(() => type = 'buy')),
                  ]),
                  const SizedBox(height: 16),
                  const Text('Валюта', style: TextStyle(fontSize: 13, color: Colors.white54)),
                  const SizedBox(height: 8),
                  Row(children: _currencies.map((c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _chip('${_flags[c]} $c', currency == c, const Color(0xFF42A5F5), () => setS(() => currency = c)),
                  )).toList()),
                  const SizedBox(height: 16),
                  const Text('Методы оплаты', style: TextStyle(fontSize: 13, color: Colors.white54)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: ['Kaspi', 'Halyk', 'ForteBank', 'Jusan', 'BCC'].map((m) {
                      final sel = selectedMethods.contains(m);
                      return GestureDetector(
                        onTap: () => setS(() => sel ? selectedMethods.remove(m) : selectedMethods.add(m)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFF42A5F5).withOpacity(0.2) : Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: sel ? const Color(0xFF42A5F5) : Colors.white.withOpacity(0.1)),
                          ),
                          child: Text(m, style: TextStyle(fontSize: 13, color: sel ? const Color(0xFF42A5F5) : Colors.white54)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _field(priceCtrl, 'Курс (₸ за 1 $currency)'),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _field(minCtrl, 'Мин. лимит ₸')),
                    const SizedBox(width: 12),
                    Expanded(child: _field(maxCtrl, 'Макс. лимит ₸')),
                  ]),
                  const SizedBox(height: 12),
                  _field(availCtrl, 'Доступно $currency'),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final price = double.tryParse(priceCtrl.text.replaceAll(',', '.'));
                        final min = double.tryParse(minCtrl.text.replaceAll(',', '.'));
                        final max = double.tryParse(maxCtrl.text.replaceAll(',', '.'));
                        final avail = double.tryParse(availCtrl.text.replaceAll(',', '.'));
                        if (price == null || min == null || max == null || avail == null) {
                          _showSnack('Заполните все поля', const Color(0xFFFF1744));
                          return;
                        }
                        await _supabase.from('p2p_offers').insert({
                          'user_id': _uid,
                          'username': _username,
                          'type': type,
                          'currency': currency,
                          'price': price,
                          'limit_min': min,
                          'limit_max': max,
                          'available': avail,
                          'pay_methods': selectedMethods,
                        });
                        Navigator.pop(ctx);
                        _showSnack('Объявление опубликовано!', const Color(0xFF00C853));
                        _loadOffers();
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
      ),
    );
  }

  void _showBuySheet(Map<String, dynamic> offer) {
    if (_uid.isEmpty) {
      _showSnack('Войдите в аккаунт', const Color(0xFFFF1744));
      return;
    }
    if (offer['user_id'] == _uid) {
      _showSnack('Это ваше объявление', const Color(0xFFFF1744));
      return;
    }
    final amountCtrl = TextEditingController();
    final actionColor = _isBuy ? const Color(0xFF00C853) : const Color(0xFFFF1744);

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
                  Text(offer['username'] ?? 'user', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Spacer(),
                  Text('₸ ${offer['price']} /${offer['currency']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: actionColor)),
                ],
              ),
              const SizedBox(height: 6),
              Text('Лимит: ${offer['limit_min']} – ${offer['limit_max']} ₸', style: const TextStyle(fontSize: 13, color: Colors.white38)),
              Text('Доступно: ${offer['available']} ${offer['currency']}', style: const TextStyle(fontSize: 13, color: Colors.white38)),
              const SizedBox(height: 20),
              TextField(
                controller: amountCtrl,
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
                  onPressed: () async {
                    final amount = double.tryParse(amountCtrl.text.replaceAll(',', '.'));
                    if (amount == null || amount <= 0) return;
                    try {
                      await _supabase.from('p2p_deals').insert({
                        'offer_id': offer['id'],
                        'buyer_id': _uid,
                        'seller_id': offer['user_id'],
                        'buyer_username': _username,
                        'seller_username': offer['username'],
                        'amount': amount,
                        'currency': offer['currency'],
                        'price': offer['price'],
                        'status': 'pending',
                      });
                      Navigator.pop(ctx);
                      _showSnack('Заявка отправлена продавцу ${offer['username']}! Перейдите в "Мои сделки"', actionColor);
                    } catch (e) {
                      _showSnack('Ошибка: $e', const Color(0xFFFF1744));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actionColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(_isBuy ? 'Купить ${offer['currency']}' : 'Продать ${offer['currency']}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildFilters(),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)))
              : _offers.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _loadOffers,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: _offers.length,
                        itemBuilder: (ctx, i) => _buildCard(_offers[i]),
                      ),
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
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(30)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _modeBtn('Купить', true),
              _modeBtn('Продать', false),
            ]),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _showCreateOffer,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00C853).withOpacity(0.4)),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add, color: Color(0xFF00C853), size: 16),
                SizedBox(width: 4),
                Text('Объявление', style: TextStyle(fontSize: 13, color: Color(0xFF00C853), fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeBtn(String label, bool isBuy) {
    final selected = _isBuy == isBuy;
    return GestureDetector(
      onTap: () { setState(() => _isBuy = isBuy); _loadOffers(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? (isBuy ? const Color(0xFF00C853) : const Color(0xFFFF1744)) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: selected ? Colors.white : Colors.white54)),
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
            onTap: () { setState(() => _currency = c); _loadOffers(); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF00C853).withOpacity(0.15) : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? const Color(0xFF00C853) : Colors.white.withOpacity(0.1)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_flags[c]!, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(c, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? const Color(0xFF00C853) : Colors.white70)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> offer) {
    final actionColor = _isBuy ? const Color(0xFF00C853) : const Color(0xFFFF1744);
    final actionLabel = _isBuy ? 'Купить' : 'Продать';
    final methods = (offer['pay_methods'] as List?)?.cast<String>() ?? [];
    final isOwn = offer['user_id'] == _uid;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: isOwn ? Colors.white.withOpacity(0.09) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isOwn ? const Color(0xFF42A5F5).withOpacity(0.4) : Colors.white.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isOwn)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  const Icon(Icons.person, size: 13, color: Color(0xFF42A5F5)),
                  const SizedBox(width: 4),
                  const Text('Моё объявление', style: TextStyle(fontSize: 11, color: Color(0xFF42A5F5), fontWeight: FontWeight.w600)),
                ]),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [actionColor.withOpacity(0.8), actionColor.withOpacity(0.4)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text((offer['username'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                  ),
                  Positioned(bottom: 0, right: 0, child: Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(color: const Color(0xFF00C853), shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0D1B2A), width: 1.5)),
                  )),
                ]),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(offer['username'] ?? 'user', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('Активен', style: TextStyle(fontSize: 11, color: Colors.white38)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: methods.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: actionColor, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(m, style: const TextStyle(fontSize: 11, color: Colors.white54)),
                  ]),
                )).toList()),
              ],
            ),
            const SizedBox(height: 14),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('₸ ${offer['price']}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('/${offer['currency']}', style: const TextStyle(fontSize: 13, color: Colors.white38)),
              ),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Лимит  ${offer['limit_min']} – ${offer['limit_max']} ₸', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                const SizedBox(height: 2),
                Text('Доступно  ${offer['available']} ${offer['currency']}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
              ])),
              if (!isOwn)
                GestureDetector(
                  onTap: () => _showBuySheet(offer),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    decoration: BoxDecoration(color: actionColor, borderRadius: BorderRadius.circular(14)),
                    child: Text(actionLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.swap_horiz, size: 80, color: Colors.white.withOpacity(0.1)),
        const SizedBox(height: 16),
        const Text('Объявлений пока нет', style: TextStyle(fontSize: 18, color: Colors.white54)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showCreateOffer,
          child: const Text('Создать первое объявление', style: TextStyle(fontSize: 14, color: Color(0xFF00C853))),
        ),
      ]),
    );
  }

  Widget _chip(String label, bool selected, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : Colors.white.withOpacity(0.1)),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? color : Colors.white54)),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint) {
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
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }
}
