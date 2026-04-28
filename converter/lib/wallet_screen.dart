import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'app_background.dart';

final _supabase = Supabase.instance.client;

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  Map<String, double> _balance = {'kzt': 0, 'usd': 0, 'eur': 0, 'rub': 0};
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _cards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await Future.wait([_loadWallet(), _loadTransactions(), _loadCards()]);
    setState(() => _loading = false);
  }

  Future<void> _loadWallet() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) {
      _balance = {'kzt': 0, 'usd': 0, 'eur': 0, 'rub': 0};
      return;
    }
    try {
      // Получаем балансы для всех валют
      final res = await _supabase.from('wallets').select('currency_code, balance').eq('user_id', uid);
      _balance = {'kzt': 0, 'usd': 0, 'eur': 0, 'rub': 0};
      for (final wallet in res) {
        final currency = wallet['currency_code'].toString().toLowerCase();
        if (_balance.containsKey(currency)) {
          _balance[currency] = (wallet['balance'] ?? 0).toDouble();
        }
      }
    } catch (e) {
      // Если таблица wallets не существует или ошибка, используем старый формат
      try {
        final res = await _supabase.from('wallets').select().eq('user_id', uid).maybeSingle();
        if (res == null) {
          await _supabase.from('wallets').insert({'user_id': uid});
        } else {
          _balance = {
            'kzt': (res['kzt'] ?? 0).toDouble(),
            'usd': (res['usd'] ?? 0).toDouble(),
            'eur': (res['eur'] ?? 0).toDouble(),
            'rub': (res['rub'] ?? 0).toDouble(),
          };
        }
      } catch (e2) {
        // Если ничего не работает, используем пустой баланс
        _balance = {'kzt': 0, 'usd': 0, 'eur': 0, 'rub': 0};
      }
    }
  }

  Future<void> _loadTransactions() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final res = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(50);
      _transactions = List<Map<String, dynamic>>.from(res);
    } catch (_) {}
  }

  Future<void> _loadCards() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final res = await _supabase.from('cards').select().eq('user_id', uid);
      _cards = List<Map<String, dynamic>>.from(res);
    } catch (_) {}
  }

  Future<void> _updateBalance(String currency, double delta) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;
    final newVal = (_balance[currency] ?? 0) + delta;
    await _supabase.from('wallets').update({currency: newVal}).eq('user_id', uid);
    setState(() => _balance[currency] = newVal);
  }

  Future<void> _addTransaction(String type, double amount, String currency, String method) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;

    try {
      // Используем функцию базы данных для безопасного обновления
      final result = await _supabase.rpc(
        type == 'deposit' ? 'deposit_wallet' : 'withdraw_wallet',
        params: {
          'p_user_uuid': uid,
          'p_amount': amount,
          'p_currency_code': currency,
          'p_payment_method': method,
        }
      );

      if (result['success'] == true) {
        // Обновляем локальный баланс
        setState(() {
          final currencyKey = currency.toLowerCase();
          if (_balance.containsKey(currencyKey)) {
            if (type == 'deposit') {
              _balance[currencyKey] = (_balance[currencyKey] ?? 0) + amount;
            } else {
              _balance[currencyKey] = (_balance[currencyKey] ?? 0) - amount;
            }
          }
        });

        // Перезагружаем транзакции
        await _loadTransactions();

        // Показываем сообщение об успехе
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Операция выполнена успешно'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Показываем ошибку
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Ошибка при выполнении операции'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Fallback: используем старый метод вставки напрямую
      try {
        final tx = {
          'user_id': uid,
          'type': type,
          'amount': amount,
          'currency': currency,
          'method': method,
          'status': 'completed',
        };
        final res = await _supabase.from('transactions').insert(tx).select().single();
        setState(() => _transactions.insert(0, res));

        // Обновляем баланс локально
        setState(() {
          final currencyKey = currency.toLowerCase();
          if (_balance.containsKey(currencyKey)) {
            if (type == 'deposit') {
              _balance[currencyKey] = (_balance[currencyKey] ?? 0) + amount;
            } else {
              _balance[currencyKey] = (_balance[currencyKey] ?? 0) - amount;
            }
          }
        });
      } catch (fallbackError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ошибка при выполнении операции'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showDeposit() {
    String currency = 'KZT';
    String method = 'Kaspi';
    final amountCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: _buildSheet(
            title: 'Пополнение',
            color: const Color(0xFF00C853),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Валюта', style: TextStyle(fontSize: 13, color: Colors.white54)),
                const SizedBox(height: 8),
                Row(children: ['KZT', 'USD', 'EUR', 'RUB'].map((c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _chip(c, currency == c, const Color(0xFF00C853), () => setS(() => currency = c)),
                )).toList()),
                const SizedBox(height: 16),
                const Text('Метод оплаты', style: TextStyle(fontSize: 13, color: Colors.white54)),
                const SizedBox(height: 8),
                Row(children: ['Kaspi', 'Halyk', 'ForteBank'].map((m) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _chip(m, method == m, const Color(0xFF42A5F5), () => setS(() => method = m)),
                )).toList()),
                const SizedBox(height: 16),
                _amountField(amountCtrl, currency),
                const SizedBox(height: 24),
                _actionBtn('Пополнить', const Color(0xFF00C853), () async {
                  final amount = double.tryParse(amountCtrl.text.replaceAll(',', '.'));
                  if (amount == null || amount <= 0) return;
                  Navigator.pop(ctx);
                  await _addTransaction('deposit', amount, currency, method);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWithdraw() {
    if (_cards.isEmpty) {
      _showAddCard();
      return;
    }
    String currency = 'KZT';
    String? selectedCardId = _cards.first['id'];
    final amountCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: _buildSheet(
            title: 'Вывод средств',
            color: const Color(0xFFFF1744),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Валюта', style: TextStyle(fontSize: 13, color: Colors.white54)),
                const SizedBox(height: 8),
                Row(children: ['KZT', 'USD', 'EUR', 'RUB'].map((c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _chip(c, currency == c, const Color(0xFFFF1744), () => setS(() => currency = c)),
                )).toList()),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Карта для вывода', style: TextStyle(fontSize: 13, color: Colors.white54)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () { Navigator.pop(ctx); _showAddCard(); },
                      child: const Text('+ Добавить', style: TextStyle(fontSize: 13, color: Color(0xFF42A5F5))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._cards.map((card) => GestureDetector(
                  onTap: () => setS(() => selectedCardId = card['id']),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selectedCardId == card['id']
                          ? const Color(0xFFFF1744).withOpacity(0.15)
                          : Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedCardId == card['id']
                            ? const Color(0xFFFF1744)
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(_bankIcon(card['bank']), style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(card['bank'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text(_maskCard(card['card_number']), style: const TextStyle(fontSize: 12, color: Colors.white54)),
                          ],
                        ),
                        const Spacer(),
                        Text(card['holder_name'], style: const TextStyle(fontSize: 12, color: Colors.white38)),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 8),
                _amountField(amountCtrl, currency),
                const SizedBox(height: 4),
                Text(
                  'Доступно: ${(_balance[currency.toLowerCase()] ?? 0).toStringAsFixed(2)} $currency',
                  style: const TextStyle(fontSize: 12, color: Colors.white38),
                ),
                const SizedBox(height: 24),
                _actionBtn('Вывести', const Color(0xFFFF1744), () async {
                  final amount = double.tryParse(amountCtrl.text.replaceAll(',', '.'));
                  if (amount == null || amount <= 0) return;
                  if (amount > (_balance[currency.toLowerCase()] ?? 0)) {
                    _showSnack('Недостаточно средств', const Color(0xFFFF1744));
                    return;
                  }
                  final card = _cards.firstWhere((c) => c['id'] == selectedCardId);
                  Navigator.pop(ctx);
                  await _addTransaction('withdraw', amount, currency, card['bank']);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCard() {
    final numberCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    String bank = 'Kaspi';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: _buildSheet(
            title: 'Добавить карту',
            color: const Color(0xFF42A5F5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Банк', style: TextStyle(fontSize: 13, color: Colors.white54)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Kaspi', 'Halyk', 'ForteBank', 'Jusan', 'BCC', 'Bereke'].map((b) =>
                    _chip(b, bank == b, const Color(0xFF42A5F5), () => setS(() => bank = b)),
                  ).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: numberCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  style: const TextStyle(color: Colors.white, letterSpacing: 2),
                  decoration: _inputDeco('Номер карты (16 цифр)', null),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  textCapitalization: TextCapitalization.characters,
                  decoration: _inputDeco('Имя держателя (IVAN IVANOV)', null),
                ),
                const SizedBox(height: 24),
                _actionBtn('Сохранить карту', const Color(0xFF42A5F5), () async {
                  if (numberCtrl.text.length < 16 || nameCtrl.text.isEmpty) {
                    _showSnack('Заполните все поля', const Color(0xFFFF1744));
                    return;
                  }
                  final uid = _supabase.auth.currentUser?.id;
                  if (uid == null) return;
                  final res = await _supabase.from('cards').insert({
                    'user_id': uid,
                    'card_number': numberCtrl.text,
                    'bank': bank,
                    'holder_name': nameCtrl.text.toUpperCase(),
                  }).select().single();
                  setState(() => _cards.add(res));
                  Navigator.pop(ctx);
                  _showSnack('Карта добавлена', const Color(0xFF42A5F5));
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)))
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    const Text('Кошелёк', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 20),
                    _buildBalanceCard(),
                    const SizedBox(height: 16),
                    _buildActions(),
                    const SizedBox(height: 24),
                    _buildCards(),
                    const SizedBox(height: 24),
                    _buildTransactions(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    final totalKzt = _balance['kzt']! +
        _balance['usd']! * 488 +
        _balance['eur']! * 568 +
        _balance['rub']! * 6.4;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3A2A), Color(0xFF0D2818)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00C853).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Общий баланс', style: TextStyle(fontSize: 13, color: Colors.white54)),
          const SizedBox(height: 8),
          Text(
            '${_formatNum(totalKzt)} ₸',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _balanceChip('USD', _balance['usd']!),
              const SizedBox(width: 8),
              _balanceChip('EUR', _balance['eur']!),
              const SizedBox(width: 8),
              _balanceChip('RUB', _balance['rub']!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceChip(String currency, double amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '${_formatNum(amount)} $currency',
        style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(child: _actionCard(Icons.add_circle_outline, 'Пополнить', const Color(0xFF00C853), _showDeposit)),
        const SizedBox(width: 12),
        Expanded(child: _actionCard(Icons.arrow_circle_up_outlined, 'Вывести', const Color(0xFFFF1744), _showWithdraw)),
        const SizedBox(width: 12),
        Expanded(child: _actionCard(Icons.credit_card, 'Карты', const Color(0xFF42A5F5), _showAddCard)),
      ],
    );
  }

  Widget _actionCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildCards() {
    if (_cards.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Мои карты', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const Spacer(),
            GestureDetector(
              onTap: _showAddCard,
              child: const Text('+ Добавить', style: TextStyle(fontSize: 13, color: Color(0xFF42A5F5))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _cards.length,
            itemBuilder: (ctx, i) {
              final card = _cards[i];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_bankColor(card['bank']).withOpacity(0.4), _bankColor(card['bank']).withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _bankColor(card['bank']).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(_bankIcon(card['bank']), style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 6),
                        Text(card['bank'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    Text(_maskCard(card['card_number']), style: const TextStyle(fontSize: 13, color: Colors.white70, letterSpacing: 2)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('История транзакций', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        if (_transactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('Транзакций пока нет', style: TextStyle(color: Colors.white38)),
            ),
          )
        else
          ..._transactions.map((tx) => _buildTxRow(tx)),
      ],
    );
  }

  Widget _buildTxRow(Map<String, dynamic> tx) {
    final isDeposit = tx['type'] == 'deposit';
    final color = isDeposit ? const Color(0xFF00C853) : const Color(0xFFFF1744);
    final icon = isDeposit ? Icons.arrow_circle_down : Icons.arrow_circle_up;
    final sign = isDeposit ? '+' : '-';
    final date = DateTime.tryParse(tx['created_at'] ?? '');
    final dateStr = date != null ? DateFormat('dd.MM.yyyy HH:mm').format(date) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDeposit ? 'Пополнение' : 'Вывод',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                Text(
                  '${tx['method'] ?? ''} · $dateStr',
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${_formatNum((tx['amount'] as num).toDouble())} ${tx['currency']}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Выполнено', style: TextStyle(fontSize: 10, color: Color(0xFF00C853))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSheet({required String title, required Color color, required Widget child}) {
    return Container(
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
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          child,
        ],
      ),
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

  Widget _amountField(TextEditingController ctrl, String currency) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white, fontSize: 18),
      decoration: _inputDeco('Сумма', currency),
    );
  }

  InputDecoration _inputDeco(String hint, String? suffix) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24),
      suffixText: suffix,
      suffixStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(0.07),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      counterText: '',
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  String _maskCard(String number) {
    if (number.length < 4) return number;
    return '**** **** **** ${number.substring(number.length - 4)}';
  }

  String _bankIcon(String bank) {
    switch (bank) {
      case 'Kaspi': return '🔴';
      case 'Halyk': return '🟢';
      case 'ForteBank': return '🔵';
      case 'Jusan': return '🟡';
      case 'BCC': return '🟠';
      default: return '🏦';
    }
  }

  Color _bankColor(String bank) {
    switch (bank) {
      case 'Kaspi': return const Color(0xFFFF1744);
      case 'Halyk': return const Color(0xFF00C853);
      case 'ForteBank': return const Color(0xFF42A5F5);
      case 'Jusan': return const Color(0xFFFFD600);
      case 'BCC': return const Color(0xFFFF6B00);
      default: return const Color(0xFF42A5F5);
    }
  }

  String _formatNum(double v) {
    if (v == 0) return '0';
    final f = NumberFormat('#,##0.##', 'ru');
    return f.format(v);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }
}
