import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'app_background.dart';
import 'l10n_service.dart';

final _supabase = Supabase.instance.client;

// ─── Экран всех сделок ───────────────────────────────────────────────────────

class P2PDealsScreen extends StatefulWidget {
  const P2PDealsScreen({super.key});

  @override
  State<P2PDealsScreen> createState() => _P2PDealsScreenState();
}

class _P2PDealsScreenState extends State<P2PDealsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _deals = [];
  bool _loading = true;

  String get _uid => _supabase.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDeals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDeals() async {
    if (_uid.isEmpty) { setState(() => _loading = false); return; }
    setState(() => _loading = true);
    try {
      final res = await _supabase
          .from('p2p_deals')
          .select()
          .or('buyer_id.eq.$_uid,seller_id.eq.$_uid')
          .order('created_at', ascending: false);
      setState(() => _deals = List<Map<String, dynamic>>.from(res));
    } catch (_) {}
    setState(() => _loading = false);
  }

  List<Map<String, dynamic>> get _incoming =>
      _deals.where((d) => d['seller_id'] == _uid && d['status'] == 'pending').toList();

  List<Map<String, dynamic>> get _active =>
      _deals.where((d) => d['status'] != 'pending' || d['buyer_id'] == _uid).toList();

  Future<void> _updateStatus(String dealId, String status) async {
    await _supabase.from('p2p_deals').update({'status': status}).eq('id', dealId);
    if (status == 'completed') {
      final deal = _deals.firstWhere((d) => d['id'] == dealId);
      final currency = (deal['currency'] as String).toLowerCase();
      final kztAmount = (deal['amount'] as num).toDouble(); // сумма в KZT которую платит покупатель
      final price = (deal['price'] as num).toDouble(); // курс за 1 единицу валюты
      final currencyAmount = kztAmount / price; // сколько валюты получает покупатель
      print('DEAL: kzt=$kztAmount price=$price currency=$currencyAmount');
      // Продавец: отдаёт валюту, получает KZT
      await _updateWallet(deal['seller_id'], currency, -currencyAmount);
      await _updateWallet(deal['seller_id'], 'kzt', kztAmount);
      // Покупатель: отдаёт KZT, получает валюту
      await _updateWallet(deal['buyer_id'], 'kzt', -kztAmount);
      await _updateWallet(deal['buyer_id'], currency, currencyAmount);
    }
    _loadDeals();
  }

  Future<void> _updateWallet(String userId, String currency, double delta) async {
    try {
      final res = await _supabase.from('wallets').select().eq('user_id', userId).maybeSingle();
      if (res == null) {
        await _supabase.from('wallets').upsert({'user_id': userId, 'kzt': 0, 'usd': 0, 'eur': 0, 'rub': 0});
        return;
      }
      final current = (res[currency] ?? 0).toDouble();
      final newVal = (current + delta).clamp(0.0, double.infinity);
      await _supabase.from('wallets').update({currency: newVal}).eq('user_id', userId);
      print('WALLET OK: userId=$userId $currency $current -> $newVal');
    } catch (e) {
      print('WALLET ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: L10n.localeNotifier,
      builder: (context, locale, _) => AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(t('deals_title')),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF00C853),
              labelColor: const Color(0xFF00C853),
              unselectedLabelColor: Colors.white54,
              tabs: [
                Tab(text: '${t('deals_inc')}${_incoming.isNotEmpty ? ' (${_incoming.length})' : ''}'),
                Tab(text: t('deals_all')),
              ],
            ),
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)))
              : _uid.isEmpty
                  ? _buildNotAuth()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildIncoming(),
                        _buildAll(),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildNotAuth() {
    return Center(
      child: Text(
        t('deals_not_auth'),
        style: const TextStyle(color: Colors.white54, fontSize: 16),
      ),
    );
  }

  Widget _buildIncoming() {
    if (_incoming.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.inbox, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(t('deals_empty_inc'), style: const TextStyle(fontSize: 18, color: Colors.white54)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadDeals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _incoming.length,
        itemBuilder: (ctx, i) => _buildDealCard(_incoming[i], showActions: true),
      ),
    );
  }

  Widget _buildAll() {
    if (_active.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.swap_horiz, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(t('deals_empty_all'), style: const TextStyle(fontSize: 18, color: Colors.white54)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadDeals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _active.length,
        itemBuilder: (ctx, i) => _buildDealCard(_active[i], showActions: false),
      ),
    );
  }

  Widget _buildDealCard(Map<String, dynamic> deal, {required bool showActions}) {
    final isBuyer = deal['buyer_id'] == _uid;
    final status = deal['status'] as String;
    final statusColor = status == 'completed'
        ? const Color(0xFF00C853)
        : status == 'cancelled'
            ? const Color(0xFFFF1744)
            : const Color(0xFFFFD600);
    final statusText = status == 'completed'
        ? t('deals_status_ok')
        : status == 'cancelled'
            ? t('deals_status_cancel')
            : t('deals_status_wait');
    final date = DateTime.tryParse(deal['created_at'] ?? '');
    final dateStr = date != null ? DateFormat('dd.MM HH:mm').format(date) : '';
    final counterpart = isBuyer ? deal['seller_username'] : deal['buyer_username'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text((counterpart ?? 'U')[0].toUpperCase(),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(counterpart ?? 'user', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(isBuyer ? t('deals_i_buy') : t('deals_i_sell'), style: const TextStyle(fontSize: 11, color: Colors.white38)),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(statusText, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 4),
                    Text(dateStr, style: const TextStyle(fontSize: 11, color: Colors.white24)),
                  ]),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(t('deals_sum'), style: const TextStyle(fontSize: 11, color: Colors.white38)),
                      Text('${deal['amount']} ₸', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ])),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Text(t('deals_rate'), style: const TextStyle(fontSize: 11, color: Colors.white38)),
                      Text('${deal['price']} ₸', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ])),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(t('p2p_curr'), style: const TextStyle(fontSize: 11, color: Colors.white38)),
                      Text(deal['currency'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ])),
                  ]),
                ),
              ],
            ),
          ),
          // Кнопки действий
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(children: [
              // Чат всегда доступен
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => P2PChatScreen(deal: deal),
                  )),
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: Text(t('deals_chat')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF42A5F5),
                    side: const BorderSide(color: Color(0xFF42A5F5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              if (showActions && status == 'pending') ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(deal['id'], 'completed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(t('deals_accept'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(deal['id'], 'cancelled'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF1744),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(t('deals_reject'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
              if (!showActions && status == 'pending' && isBuyer) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(deal['id'], 'cancelled'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF1744),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(t('deals_cancel_btn'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── Экран чата ──────────────────────────────────────────────────────────────

class P2PChatScreen extends StatefulWidget {
  final Map<String, dynamic> deal;
  const P2PChatScreen({super.key, required this.deal});

  @override
  State<P2PChatScreen> createState() => _P2PChatScreenState();
}

class _P2PChatScreenState extends State<P2PChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  RealtimeChannel? _channel;

  String get _uid => _supabase.auth.currentUser?.id ?? '';
  String get _username => _supabase.auth.currentUser?.email?.split('@').first ?? 'user';
  String get _dealId => widget.deal['id'];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final res = await _supabase
          .from('messages')
          .select()
          .eq('deal_id', _dealId)
          .order('created_at', ascending: true);
      setState(() => _messages = List<Map<String, dynamic>>.from(res));
      _scrollToBottom();
    } catch (_) {}
  }

  void _subscribeRealtime() {
    _channel = _supabase
        .channel('messages:$_dealId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'deal_id', value: _dealId),
          callback: (payload) {
            final newMsg = payload.newRecord;
            // Не добавляем если уже есть с таким id или это наше сообщение (уже добавлено локально)
            final alreadyExists = _messages.any((m) => m['id'] == newMsg['id']);
            final isOwnMsg = newMsg['sender_id'] == _uid;
            if (!alreadyExists && !isOwnMsg) {
              setState(() => _messages.add(newMsg));
              _scrollToBottom();
            } else if (!alreadyExists && isOwnMsg) {
              // Заменяем временное сообщение на реальное если ещё не заменено
              setState(() {
                final tempIdx = _messages.indexWhere((m) => m['id'].toString().startsWith('temp_') && m['text'] == newMsg['text']);
                if (tempIdx != -1) _messages[tempIdx] = newMsg;
              });
            }
          },
        )
        .subscribe();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    // Добавляем локально сразу
    final tempMsg = {
      'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
      'deal_id': _dealId,
      'sender_id': _uid,
      'sender_username': _username,
      'text': text,
      'created_at': DateTime.now().toIso8601String(),
    };
    setState(() => _messages.add(tempMsg));
    _scrollToBottom();
    try {
      final res = await _supabase.from('messages').insert({
        'deal_id': _dealId,
        'sender_id': _uid,
        'sender_username': _username,
        'text': text,
      }).select().single();
      // Заменяем временное на реальное
      setState(() {
        final idx = _messages.indexWhere((m) => m['id'] == tempMsg['id']);
        if (idx != -1) _messages[idx] = res;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isBuyer = widget.deal['buyer_id'] == _uid;
    final counterpart = isBuyer ? widget.deal['seller_username'] : widget.deal['buyer_username'];
    final status = widget.deal['status'] as String;
    final statusColor = status == 'completed'
        ? const Color(0xFF00C853)
        : status == 'cancelled'
            ? const Color(0xFFFF1744)
            : const Color(0xFFFFD600);
    final statusText = status == 'completed'
        ? t('deals_status_ok')
        : status == 'cancelled'
            ? t('deals_status_cancel')
            : t('deals_status_wait');

    return ValueListenableBuilder(
      valueListenable: L10n.localeNotifier,
      builder: (context, locale, _) => AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text((counterpart ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF00C853)))),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(counterpart ?? 'user', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${widget.deal['amount']} ₸ · ${widget.deal['currency']}',
                    style: const TextStyle(fontSize: 11, color: Colors.white54)),
              ]),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600),
                ),
              ),
            ]),
          ),
          body: Column(children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (ctx, i) => _buildMessage(_messages[i]),
              ),
            ),
            _buildInput(),
          ]),
        ),
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isMe = msg['sender_id'] == _uid;
    final date = DateTime.tryParse(msg['created_at'] ?? '');
    final timeStr = date != null ? DateFormat('HH:mm').format(date) : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF42A5F5).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text((msg['sender_username'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF42A5F5)))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF00C853).withOpacity(0.2) : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: Border.all(
                  color: isMe ? const Color(0xFF00C853).withOpacity(0.3) : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                Text(msg['text'] ?? '', style: const TextStyle(fontSize: 14, color: Colors.white)),
                const SizedBox(height: 4),
                Text(timeStr, style: const TextStyle(fontSize: 10, color: Colors.white38)),
              ]),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _msgCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: t('deals_msg_hint'),
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: Colors.white.withOpacity(0.07),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onSubmitted: (_) => _send(),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _send,
          child: Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(color: Color(0xFF00C853), shape: BoxShape.circle),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}
