import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_background.dart';
import 'wallet_screen.dart';
import 'currency_data.dart';
import 'translations.dart';

final _supabase = Supabase.instance.client;

class P2PScreen extends StatefulWidget {
  final List<String> favoriteCurrencies;
  final String selectedLanguage;

  const P2PScreen({super.key, this.favoriteCurrencies = const ['USD', 'EUR', 'RUB'], required this.selectedLanguage});

  @override
  State<P2PScreen> createState() => _P2PScreenState();
}

class _P2PScreenState extends State<P2PScreen> {
  bool _isBuy = true;
  String _currency = 'USD';
  String _filterMode = 'main'; // main | fav | all
  List<Map<String, dynamic>> _offers = [];
  bool _loading = true;

  static const _mainCurrencies = ['USD', 'EUR', 'RUB'];

  List<String> get _filterCurrencies {
    if (_filterMode == 'fav') return widget.favoriteCurrencies;
    if (_filterMode == 'all') return worldCurrencies.keys.toList();
    return _mainCurrencies;
  }

  String _flag(String code) => worldCurrencies[code]?['flag'] ?? '🏳️';

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

  Future<void> _deleteOffer(String id) async {
    await _supabase.from('p2p_offers').update({'is_active': false}).eq('id', id);
    _showSnack('Объявление удалено', const Color(0xFFFF1744));
    _loadOffers();
  }

  void _showCreateOffer({Map<String, dynamic>? existing}) {
    if (_uid.isEmpty) {
      _showSnack('Войдите в аккаунт чтобы создать объявление', const Color(0xFFFF1744));
      return;
    }
    String type = existing?['type'] ?? 'sell';
    String currency = existing?['currency'] ?? _currency;
    final priceCtrl = TextEditingController(text: existing?['price']?.toString() ?? '');
    final minCtrl = TextEditingController(text: existing?['limit_min']?.toString() ?? '');
    final maxCtrl = TextEditingController(text: existing?['limit_max']?.toString() ?? '');
    final availCtrl = TextEditingController(text: existing?['available']?.toString() ?? '');
    List<String> selectedMethods = existing != null
        ? List<String>.from(existing['pay_methods'] ?? ['Kaspi'])
        : ['Kaspi'];
    String searchQuery = '';

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
                  Text(tr('createAnnouncement', widget.selectedLanguage), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  Text(tr('type', widget.selectedLanguage), style: const TextStyle(fontSize: 13, color: Colors.white54)),
                  const SizedBox(height: 8),
                  Row(children: [
                    _chip(tr('sell', widget.selectedLanguage), type == 'sell', const Color(0xFF00C853), () => setS(() => type = 'sell')),
                    const SizedBox(width: 8),
                    _chip(tr('buy', widget.selectedLanguage), type == 'buy', const Color(0xFFFF1744), () => setS(() => type = 'buy')),
                  ]),
                  const SizedBox(height: 16),
                  Text(tr('currency', widget.selectedLanguage), style: const TextStyle(fontSize: 13, color: Colors.white54)),
                  const SizedBox(height: 8),
                  // Поиск валюты
                  TextField(
                    onChanged: (v) => setS(() => searchQuery = v.toUpperCase()),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: tr('searchCurrency', widget.selectedLanguage),
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 18),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.07),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: worldCurrencies.keys
                          .where((c) => searchQuery.isEmpty || c.contains(searchQuery))
                          .map((c) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _chip('${_flag(c)} $c', currency == c, const Color(0xFF42A5F5), () => setS(() => currency = c)),
                          )).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(tr('paymentMethods', widget.selectedLanguage), style: const TextStyle(fontSize: 13, color: Colors.white54)),
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
                  _field(priceCtrl, '${tr('rate', widget.selectedLanguage)} $currency)'),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _field(minCtrl, tr('minLimit', widget.selectedLanguage))),
                    const SizedBox(width: 12),
                    Expanded(child: _field(maxCtrl, tr('maxLimit', widget.selectedLanguage))),
                  ]),
                  const SizedBox(height: 12),
                  _field(availCtrl, '${tr('available', widget.selectedLanguage)} $currency'),
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
                          _showSnack(tr('fillAllFields', widget.selectedLanguage), const Color(0xFFFF1744));
                          return;
                        }
                        if (existing != null) {
                          await _supabase.from('p2p_offers').update({
                            'type': type, 'currency': currency, 'price': price,
                            'limit_min': min, 'limit_max': max, 'available': avail,
                            'pay_methods': selectedMethods,
                          }).eq('id', existing['id']);
                          _showSnack(tr('announcementUpdated', widget.selectedLanguage), const Color(0xFF42A5F5));
                        } else {
                          await _supabase.from('p2p_offers').insert({
                            'user_id': _uid, 'username': _username,
                            'type': type, 'currency': currency, 'price': price,
                            'limit_min': min, 'limit_max': max, 'available': avail,
                            'pay_methods': selectedMethods,
                          });
                          _showSnack(tr('announcementPublished', widget.selectedLanguage), const Color(0xFF00C853));
                        }
                        Navigator.pop(ctx);
                        _loadOffers();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(existing != null ? tr('save', widget.selectedLanguage) : tr('publish', widget.selectedLanguage), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
      _showSnack(tr('loginRequired', widget.selectedLanguage), const Color(0xFFFF1744));
      return;
    }
    if (offer['user_id'] == _uid) {
      _showSnack(tr('yourAnnouncement', widget.selectedLanguage), const Color(0xFFFF1744));
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
              Text('${tr('limit', widget.selectedLanguage)} ${offer['limit_min']} – ${offer['limit_max']} ₸', style: const TextStyle(fontSize: 13, color: Colors.white38)),
              Text('${tr('available', widget.selectedLanguage)} ${offer['available']} ${offer['currency']}', style: const TextStyle(fontSize: 13, color: Colors.white38)),
              const SizedBox(height: 20),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: tr('amountInKZT', widget.selectedLanguage),
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
                      _showSnack('${tr('requestSent', widget.selectedLanguage)} ${offer['username']}! ${tr('p2pDeals', widget.selectedLanguage)}', actionColor);
                    } catch (e) {
                      _showSnack('${tr('error', widget.selectedLanguage)}: $e', const Color(0xFFFF1744));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actionColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(_isBuy ? '${tr('buyCurrency', widget.selectedLanguage)} ${offer['currency']}' : '${tr('sellCurrency', widget.selectedLanguage)} ${offer['currency']}',
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
    return _loading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)))
        : RefreshIndicator(
            onRefresh: _loadOffers,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _offers.isEmpty ? 3 : _offers.length + 2,
              itemBuilder: (ctx, i) {
                if (i == 0) return _buildHeader();
                if (i == 1) return _buildFilters();
                if (_offers.isEmpty) return _buildEmpty();
                return _buildCard(_offers[i - 2]);
              },
            ),
          );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          // Строка 1: Купить/Продать
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(30)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  _modeBtn(tr('buy', widget.selectedLanguage), true),
                  _modeBtn(tr('sell', widget.selectedLanguage), false),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Строка 2: Кошелёк + Объявление
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF42A5F5).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF42A5F5).withOpacity(0.4)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF42A5F5), size: 16),
                      const SizedBox(width: 6),
                      Text(tr('wallet', widget.selectedLanguage), style: const TextStyle(fontSize: 13, color: Color(0xFF42A5F5), fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _showCreateOffer,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00C853).withOpacity(0.4)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.add, color: Color(0xFF00C853), size: 16),
                      const SizedBox(width: 6),
                      Text(tr('announcement', widget.selectedLanguage), style: const TextStyle(fontSize: 13, color: Color(0xFF00C853), fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ),
            ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showFilterSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF42A5F5).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF42A5F5).withOpacity(0.4)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.tune, color: Color(0xFF42A5F5), size: 16),
                const SizedBox(width: 6),
                Text(
                  '${_flag(_currency)} $_currency · ${_filterMode == 'main' ? tr('main', widget.selectedLanguage) : _filterMode == 'fav' ? tr('favorites', widget.selectedLanguage) : tr('all', widget.selectedLanguage)}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF42A5F5), fontWeight: FontWeight.w600),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
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
              Text(tr('filter', widget.selectedLanguage), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              Text(tr('category', widget.selectedLanguage), style: const TextStyle(fontSize: 13, color: Colors.white54)),
              const SizedBox(height: 8),
              Row(children: [
                _filterBtn(tr('main', widget.selectedLanguage), 'main', setS),
                const SizedBox(width: 8),
                _filterBtn(tr('favorites', widget.selectedLanguage), 'fav', setS),
                const SizedBox(width: 8),
                _filterBtn(tr('all', widget.selectedLanguage), 'all', setS),
              ]),
              const SizedBox(height: 16),
              Text(tr('currency', widget.selectedLanguage), style: const TextStyle(fontSize: 13, color: Colors.white54)),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _filterCurrencies.map((c) {
                    final selected = _currency == c;
                    return GestureDetector(
                      onTap: () => setS(() => _currency = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF00C853).withOpacity(0.15) : Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? const Color(0xFF00C853) : Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(_flag(c), style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(c, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? const Color(0xFF00C853) : Colors.white70)),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {});
                    _loadOffers();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(tr('apply', widget.selectedLanguage), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterBtn(String label, String mode, StateSetter setS) {
    final selected = _filterMode == mode;
    return GestureDetector(
      onTap: () => setS(() => _filterMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF42A5F5).withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? const Color(0xFF42A5F5) : Colors.white.withOpacity(0.08)),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? const Color(0xFF42A5F5) : Colors.white38)),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> offer) {
    final actionColor = _isBuy ? const Color(0xFF00C853) : const Color(0xFFFF1744);
    final actionLabel = _isBuy ? tr('buyCurrency', widget.selectedLanguage) : tr('sellCurrency', widget.selectedLanguage);
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
                  Expanded(child: Text(tr('myAnnouncement', widget.selectedLanguage), style: const TextStyle(fontSize: 11, color: Color(0xFF42A5F5), fontWeight: FontWeight.w600))),
                  GestureDetector(
                    onTap: () => _showCreateOffer(existing: offer),
                    child: const Icon(Icons.edit_outlined, size: 16, color: Colors.white38),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _deleteOffer(offer['id']),
                    child: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFFF1744)),
                  ),
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
                  Text(tr('active', widget.selectedLanguage), style: const TextStyle(fontSize: 11, color: Colors.white38)),
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
                Text('${tr('limit', widget.selectedLanguage)}  ${offer['limit_min']} – ${offer['limit_max']} ₸', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                const SizedBox(height: 2),
                Text('${tr('available', widget.selectedLanguage)}  ${offer['available']} ${offer['currency']}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
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
