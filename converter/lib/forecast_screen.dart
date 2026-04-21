import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_background.dart';

class BankForecast {
  final String currency;
  final String direction; // 'up' | 'down' | 'neutral'
  final double targetValue;
  final String period; // 'week' | 'month'
  final String comment;
  final DateTime createdAt;

  BankForecast({
    required this.currency,
    required this.direction,
    required this.targetValue,
    required this.period,
    required this.comment,
    required this.createdAt,
  });
}

// ─── Экран для ФИЗ ЛИЦА — просмотр прогноза банка ───────────────────────────

class ForecastViewScreen extends StatelessWidget {
  final List<BankForecast> forecasts;
  final List<Map<String, String>> aiuBankRates;
  final List<Map<String, dynamic>> rateHistory;
  final String selectedLanguage;

  const ForecastViewScreen({
    super.key,
    required this.forecasts,
    required this.aiuBankRates,
    required this.rateHistory,
    required this.selectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Прогноз курса'),
            bottom: TabBar(
              tabs: const [Tab(text: 'От банка'), Tab(text: 'График')],
              indicatorColor: const Color(0xFF00C853),
              labelColor: const Color(0xFF00C853),
              unselectedLabelColor: Colors.white54,
            ),
          ),
          body: TabBarView(
            children: [
              forecasts.isEmpty
                  ? _buildEmpty()
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 16),
                        ...forecasts.map((f) => _buildForecastCard(f)),
                      ],
                    ),
              _ForecastChartTab(forecasts: forecasts, aiuBankRates: aiuBankRates, rateHistory: rateHistory),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('🏛️', style: TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aiu Bank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Официальный прогноз курсов валют', style: TextStyle(fontSize: 12, color: Colors.white54)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF00C853).withOpacity(0.3)),
            ),
            child: const Text('Официально', style: TextStyle(fontSize: 11, color: Color(0xFF00C853), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard(BankForecast f) {
    final isUp = f.direction == 'up';
    final isNeutral = f.direction == 'neutral';
    final color = isNeutral ? const Color(0xFF42A5F5) : isUp ? const Color(0xFF00C853) : const Color(0xFFFF1744);
    final flag = f.currency == 'USD' ? '🇺🇸' : f.currency == 'EUR' ? '🇪🇺' : '🇷🇺';
    final dirText = isNeutral ? 'Стабильный курс' : isUp ? 'Ожидается рост' : 'Ожидается снижение';
    final periodText = f.period == 'week' ? 'на неделю' : 'на месяц';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
        ),
      ),
      child: Column(
        children: [
          // Заголовок карточки
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.currency, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(periodText, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isNeutral ? Icons.trending_flat : isUp ? Icons.trending_up : Icons.trending_down,
                        color: color,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(isNeutral ? '→' : isUp ? '↑' : '↓',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Прогнозируемое значение
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Прогноз', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
                      const SizedBox(height: 4),
                      Text(dirText, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Целевой курс', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
                    const SizedBox(height: 4),
                    Text(
                      '${f.targetValue.toStringAsFixed(1)} ₸',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Комментарий банка
          if (f.comment.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote, color: Colors.white24, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(f.comment, style: const TextStyle(fontSize: 13, color: Colors.white60, fontStyle: FontStyle.italic)),
                    ),
                  ],
                ),
              ),
            ),

          // Дата
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.white24),
                const SizedBox(width: 4),
                Text(
                  'Опубликовано ${DateFormat('dd.MM.yyyy HH:mm').format(f.createdAt)}',
                  style: const TextStyle(fontSize: 11, color: Colors.white24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 80, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 16),
          const Text('Прогнозов пока нет', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            'Банк ещё не опубликовал прогноз курсов',
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.35)),
          ),
        ],
      ),
    );
  }
}

// ─── Экран для ЮРИ ЛИЦА — управление прогнозом ──────────────────────────────

class ForecastManageScreen extends StatefulWidget {
  final List<BankForecast> forecasts;
  final Function(List<BankForecast>) onSave;
  final String selectedLanguage;

  const ForecastManageScreen({super.key, required this.forecasts, required this.onSave, required this.selectedLanguage});

  @override
  State<ForecastManageScreen> createState() => _ForecastManageScreenState();
}

class _ForecastManageScreenState extends State<ForecastManageScreen> {
  late List<BankForecast> _forecasts;

  @override
  void initState() {
    super.initState();
    _forecasts = List.from(widget.forecasts);
  }

  void _addOrEdit({BankForecast? existing}) async {
    final result = await showModalBottomSheet<BankForecast>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ForecastFormSheet(existing: existing),
    );
    if (result != null) {
      setState(() {
        if (existing != null) {
          final idx = _forecasts.indexOf(existing);
          _forecasts[idx] = result;
        } else {
          _forecasts.removeWhere((f) => f.currency == result.currency);
          _forecasts.add(result);
        }
      });
      widget.onSave(_forecasts);
    }
  }

  void _delete(BankForecast f) {
    setState(() => _forecasts.remove(f));
    widget.onSave(_forecasts);
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Управление прогнозом')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _addOrEdit(),
          backgroundColor: const Color(0xFF00C853),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Добавить', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: _forecasts.isEmpty
            ? _buildEmpty()
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF00C853).withOpacity(0.25)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF00C853), size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Ваши прогнозы видят все клиенты в разделе "Прогноз курса"',
                            style: TextStyle(fontSize: 13, color: Color(0xFF00C853)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._forecasts.map((f) => _buildManageCard(f)),
                ],
              ),
      ),
    );
  }

  Widget _buildManageCard(BankForecast f) {
    final isUp = f.direction == 'up';
    final isNeutral = f.direction == 'neutral';
    final color = isNeutral ? const Color(0xFF42A5F5) : isUp ? const Color(0xFF00C853) : const Color(0xFFFF1744);
    final flag = f.currency == 'USD' ? '🇺🇸' : f.currency == 'EUR' ? '🇪🇺' : '🇷🇺';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.currency, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(
                  '${f.targetValue.toStringAsFixed(1)} ₸ · ${f.period == 'week' ? 'Неделя' : 'Месяц'}',
                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5)),
                ),
              ],
            ),
          ),
          Icon(
            isNeutral ? Icons.trending_flat : isUp ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white54, size: 20),
            onPressed: () => _addOrEdit(existing: f),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: () => _delete(f),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_chart, size: 80, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 16),
          const Text('Нет прогнозов', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Нажмите + чтобы добавить прогноз', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.35))),
        ],
      ),
    );
  }
}

// ─── Таб с графиком прогноза ────────────────────────────────────────────────

class _ForecastChartTab extends StatelessWidget {
  final List<BankForecast> forecasts;
  final List<Map<String, String>> aiuBankRates;
  final List<Map<String, dynamic>> rateHistory;

  const _ForecastChartTab({
    required this.forecasts,
    required this.aiuBankRates,
    required this.rateHistory,
  });

  static const _currencies = ['USD', 'EUR', 'RUB'];
  static const _flags = {'USD': '🇺🇸', 'EUR': '🇪🇺', 'RUB': '🇷🇺'};

  double _currentRate(String currency) {
    final idx = _currencies.indexOf(currency);
    if (idx == -1) return 0;
    return double.tryParse((aiuBankRates[idx]['sell'] ?? '0').replaceAll(',', '.')) ?? 0;
  }

  // Автопрогноз по истории: считаем средний тренд и экстраполируем
  double _autoTarget(String currency, double current) {
    if (rateHistory.length < 2) return current;
    final idx = _currencies.indexOf(currency);
    if (idx == -1) return current;

    // Берём последние 5 записей истории
    final recent = rateHistory.take(5).toList();
    final values = recent.map((h) {
      final rates = h['rates'] as List<Map<String, String>>;
      return double.tryParse((rates[idx]['sell'] ?? '0').replaceAll(',', '.')) ?? 0.0;
    }).where((v) => v > 0).toList();

    if (values.length < 2) return current;

    // Средний шаг изменения
    double totalDelta = 0;
    for (int i = 0; i < values.length - 1; i++) {
      totalDelta += values[i] - values[i + 1]; // новые первые
    }
    final avgDelta = totalDelta / (values.length - 1);
    // Прогноз = текущий + тренд * 7 (неделя)
    return current + avgDelta * 7;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Плашка — источник данных
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(
                forecasts.isNotEmpty ? Icons.account_balance : Icons.auto_graph,
                size: 16,
                color: forecasts.isNotEmpty ? const Color(0xFF00C853) : const Color(0xFF42A5F5),
              ),
              const SizedBox(width: 8),
              Text(
                forecasts.isNotEmpty
                    ? 'Прогноз на основе данных банка'
                    : 'Автоматический прогноз по истории курсов',
                style: TextStyle(
                  fontSize: 12,
                  color: forecasts.isNotEmpty ? const Color(0xFF00C853) : const Color(0xFF42A5F5),
                ),
              ),
            ],
          ),
        ),
        ..._currencies.map((currency) {
          final current = _currentRate(currency);
          if (current == 0) return const SizedBox.shrink();

          // Если банк опубликовал прогноз для этой валюты — берём оттуда
          final bankForecast = forecasts.where((f) => f.currency == currency).firstOrNull;
          final target = bankForecast != null ? bankForecast.targetValue : _autoTarget(currency, current);
          final isUp = target >= current;
          final color = (target - current).abs() < 0.5
              ? const Color(0xFF42A5F5)
              : isUp ? const Color(0xFF00C853) : const Color(0xFFFF1744);
          final trendText = (target - current).abs() < 0.5
              ? 'Стабильно'
              : isUp ? 'Ожидается рост' : 'Ожидается снижение';
          final sourceText = bankForecast != null ? 'Прогноз банка' : 'Авто-анализ';

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_flags[currency]!, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currency, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(sourceText, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(trendText, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                        Text('${current.toStringAsFixed(1)} → ${target.toStringAsFixed(1)} ₸',
                            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 110,
                  child: CustomPaint(
                    painter: _ForecastCurvePainter(from: current, to: target, color: color),
                    size: Size.infinite,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Сейчас', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4))),
                    Text(
                      bankForecast != null
                          ? (bankForecast.period == 'week' ? 'Через неделю' : 'Через месяц')
                          : 'Прогноз на неделю',
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4)),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ForecastCurvePainter extends CustomPainter {
  final double from;
  final double to;
  final Color color;

  _ForecastCurvePainter({required this.from, required this.to, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (from == 0) return;
    final minVal = from < to ? from : to;
    final maxVal = from < to ? to : from;
    final range = (maxVal - minVal).abs();
    final padding = range == 0 ? 10.0 : range * 0.3;

    double toY(double v) {
      final total = (maxVal + padding) - (minVal - padding);
      return size.height - ((v - (minVal - padding)) / total) * size.height;
    }

    final points = List.generate(60, (i) {
      final t = i / 59;
      // плавная кривая Безье
      final val = from + (to - from) * t;
      return Offset(size.width * t, toY(val));
    });

    // Градиентная заливка
    final fillPath = Path();
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp = Offset((points[i - 1].dx + points[i].dx) / 2, (points[i - 1].dy + points[i].dy) / 2);
      fillPath.quadraticBezierTo(points[i - 1].dx, points[i - 1].dy, cp.dx, cp.dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.35), color.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Линия (сплошная до середины, пунктир после)
    final solidPath = Path();
    solidPath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < 30; i++) {
      final cp = Offset((points[i - 1].dx + points[i].dx) / 2, (points[i - 1].dy + points[i].dy) / 2);
      solidPath.quadraticBezierTo(points[i - 1].dx, points[i - 1].dy, cp.dx, cp.dy);
    }
    canvas.drawPath(solidPath, Paint()..color = color..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    // Пунктир
    final dashPaint = Paint()..color = color.withOpacity(0.5)..strokeWidth = 2..style = PaintingStyle.stroke;
    for (int i = 30; i < points.length - 1; i++) {
      if (i % 3 == 0) canvas.drawLine(points[i], points[i + 1], dashPaint);
    }

    // Точки: старт и цель
    canvas.drawCircle(points.first, 5, Paint()..color = Colors.white);
    canvas.drawCircle(points.last, 6, Paint()..color = color);
    canvas.drawCircle(points.last, 6, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_ForecastCurvePainter old) => old.from != from || old.to != to;
}

// ─── Форма добавления/редактирования прогноза ────────────────────────────────

class _ForecastFormSheet extends StatefulWidget {
  final BankForecast? existing;
  const _ForecastFormSheet({this.existing});

  @override
  State<_ForecastFormSheet> createState() => _ForecastFormSheetState();
}

class _ForecastFormSheetState extends State<_ForecastFormSheet> {
  String _currency = 'USD';
  String _direction = 'up';
  String _period = 'week';
  final _valueController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _currency = widget.existing!.currency;
      _direction = widget.existing!.direction;
      _period = widget.existing!.period;
      _valueController.text = widget.existing!.targetValue.toStringAsFixed(1);
      _commentController.text = widget.existing!.comment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Text('Прогноз курса', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),

            // Валюта
            const Text('Валюта', style: TextStyle(fontSize: 13, color: Colors.white54)),
            const SizedBox(height: 8),
            Row(
              children: [
                _chip('USD', '🇺🇸', _currency == 'USD', () => setState(() => _currency = 'USD')),
                const SizedBox(width: 8),
                _chip('EUR', '🇪🇺', _currency == 'EUR', () => setState(() => _currency = 'EUR')),
                const SizedBox(width: 8),
                _chip('RUB', '🇷🇺', _currency == 'RUB', () => setState(() => _currency = 'RUB')),
              ],
            ),
            const SizedBox(height: 16),

            // Направление
            const Text('Направление', style: TextStyle(fontSize: 13, color: Colors.white54)),
            const SizedBox(height: 8),
            Row(
              children: [
                _dirChip('up', '↑ Рост', const Color(0xFF00C853)),
                const SizedBox(width: 8),
                _dirChip('down', '↓ Падение', const Color(0xFFFF1744)),
                const SizedBox(width: 8),
                _dirChip('neutral', '→ Стабильно', const Color(0xFF42A5F5)),
              ],
            ),
            const SizedBox(height: 16),

            // Период
            const Text('Период', style: TextStyle(fontSize: 13, color: Colors.white54)),
            const SizedBox(height: 8),
            Row(
              children: [
                _chip('Неделя', null, _period == 'week', () => setState(() => _period = 'week')),
                const SizedBox(width: 8),
                _chip('Месяц', null, _period == 'month', () => setState(() => _period = 'month')),
              ],
            ),
            const SizedBox(height: 16),

            // Целевой курс
            const Text('Целевой курс (₸)', style: TextStyle(fontSize: 13, color: Colors.white54)),
            const SizedBox(height: 8),
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Например: 495.0',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.07),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                suffixText: '₸',
                suffixStyle: const TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 16),

            // Комментарий
            const Text('Комментарий банка (необязательно)', style: TextStyle(fontSize: 13, color: Colors.white54)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Например: Ожидаем укрепление доллара...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.07),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final val = double.tryParse(_valueController.text.replaceAll(',', '.'));
                  if (val == null) return;
                  Navigator.pop(context, BankForecast(
                    currency: _currency,
                    direction: _direction,
                    targetValue: val,
                    period: _period,
                    comment: _commentController.text.trim(),
                    createdAt: DateTime.now(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Опубликовать прогноз', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String? flag, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF00C853).withOpacity(0.2) : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? const Color(0xFF00C853) : Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (flag != null) ...[Text(flag, style: const TextStyle(fontSize: 16)), const SizedBox(width: 6)],
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? const Color(0xFF00C853) : Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _dirChip(String value, String label, Color color) {
    final selected = _direction == value;
    return GestureDetector(
      onTap: () => setState(() => _direction = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : Colors.white.withOpacity(0.1)),
        ),
        child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? color : Colors.white54)),
      ),
    );
  }
}
