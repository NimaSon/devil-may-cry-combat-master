import 'package:flutter/material.dart';
import 'dart:math';
import 'app_background.dart';

class ForecastScreen extends StatefulWidget {
  final List<Map<String, dynamic>> rateHistory;

  const ForecastScreen({super.key, required this.rateHistory});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  String selectedCurrency = 'USD';

  final currencies = [
    {'code': 'USD', 'flag': '🇺🇸', 'index': 0},
    {'code': 'EUR', 'flag': '🇪🇺', 'index': 1},
    {'code': 'RUB', 'flag': '🇷🇺', 'index': 2},
  ];

  List<double> _getHistoricalData(int currencyIndex) {
    if (widget.rateHistory.isEmpty) return [];
    return widget.rateHistory.reversed.map((entry) {
      final rates = entry['rates'] as List<Map<String, String>>;
      return double.tryParse(rates[currencyIndex]['sell']!.replaceAll(',', '.')) ?? 0;
    }).toList();
  }

  Map<String, dynamic> _buildForecast(List<double> data) {
    if (data.length < 2) {
      return {
        'forecast': <double>[],
        'trend': 0.0,
        'confidence': 'low',
        'direction': 'neutral',
        'predictedChange': 0.0,
      };
    }

    // Линейная регрессия
    final n = data.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += data[i];
      sumXY += i * data[i];
      sumX2 += i * i;
    }
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    // Прогноз на 5 точек вперед
    final forecast = List.generate(5, (i) => intercept + slope * (n + i));

    // Уровень уверенности по количеству данных
    String confidence;
    if (n >= 10) confidence = 'high';
    else if (n >= 5) confidence = 'medium';
    else confidence = 'low';

    final predictedChange = forecast.last - data.last;
    final direction = slope > 0.01 ? 'up' : slope < -0.01 ? 'down' : 'neutral';

    return {
      'forecast': forecast,
      'trend': slope,
      'confidence': confidence,
      'direction': direction,
      'predictedChange': predictedChange,
    };
  }

  @override
  Widget build(BuildContext context) {
    final currencyInfo = currencies.firstWhere((c) => c['code'] == selectedCurrency);
    final idx = currencyInfo['index'] as int;
    final historical = _getHistoricalData(idx);
    final forecast = _buildForecast(historical);
    final direction = forecast['direction'] as String;
    final confidence = forecast['confidence'] as String;
    final predictedChange = forecast['predictedChange'] as double;
    final forecastPoints = forecast['forecast'] as List<double>;

    final isUp = direction == 'up';
    final isNeutral = direction == 'neutral';
    final mainColor = isNeutral
        ? const Color(0xFF42A5F5)
        : isUp
            ? const Color(0xFF00C853)
            : const Color(0xFFFF1744);

    final allPoints = [...historical, ...forecastPoints];

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Прогноз курса'),
        ),
        body: historical.length < 2
            ? _buildEmptyState()
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Выбор валюты
                  Row(
                    children: currencies.map((c) {
                      final isSelected = selectedCurrency == c['code'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => selectedCurrency = c['code'] as String),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(colors: [mainColor, mainColor.withOpacity(0.7)])
                                  : null,
                              color: isSelected ? null : Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? mainColor : Colors.white.withOpacity(0.15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(c['flag'] as String, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 6),
                                Text(
                                  c['code'] as String,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Карточка прогноза
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [mainColor.withOpacity(0.3), mainColor.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: mainColor.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isNeutral ? Icons.trending_flat : isUp ? Icons.trending_up : Icons.trending_down,
                              color: mainColor,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isNeutral ? 'Стабильный курс' : isUp ? 'Ожидается рост' : 'Ожидается падение',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                Text(
                                  selectedCurrency,
                                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildStatCard(
                              'Изменение',
                              '${predictedChange >= 0 ? '+' : ''}${predictedChange.toStringAsFixed(2)} ₸',
                              mainColor,
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              'Уверенность',
                              confidence == 'high' ? 'Высокая' : confidence == 'medium' ? 'Средняя' : 'Низкая',
                              confidence == 'high' ? Colors.green : confidence == 'medium' ? Colors.orange : Colors.red,
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              'Данных',
                              '${historical.length} точек',
                              Colors.white54,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // График
                  Container(
                    height: 220,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(width: 20, height: 3, color: mainColor),
                            const SizedBox(width: 6),
                            const Text('История', style: TextStyle(fontSize: 12, color: Colors.white54)),
                            const SizedBox(width: 16),
                            Container(
                              width: 20,
                              height: 3,
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: mainColor, width: 2, style: BorderStyle.solid)),
                              ),
                              child: CustomPaint(painter: _DashedLinePainter(color: mainColor)),
                            ),
                            const SizedBox(width: 6),
                            const Text('Прогноз', style: TextStyle(fontSize: 12, color: Colors.white54)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: CustomPaint(
                            painter: ForecastChartPainter(
                              historical: historical,
                              forecast: forecastPoints,
                              color: mainColor,
                            ),
                            child: Container(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Подсказка
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white38, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            confidence == 'low'
                                ? 'Недостаточно данных для точного прогноза. Прогноз улучшится по мере накопления истории изменений курсов.'
                                : 'Прогноз основан на линейной регрессии по ${historical.length} точкам истории изменений курсов Aiu Bank.',
                            style: const TextStyle(fontSize: 12, color: Colors.white38),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.white38)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 80, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text(
            'Нет данных для прогноза',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Прогноз появится после того,\nкак обменник изменит курсы хотя бы раз',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2), Offset(x + 4, size.height / 2), paint);
      x += 8;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ForecastChartPainter extends CustomPainter {
  final List<double> historical;
  final List<double> forecast;
  final Color color;

  ForecastChartPainter({required this.historical, required this.forecast, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (historical.isEmpty || historical.length < 2) return;

    final allData = [...historical, ...forecast];
    final maxVal = allData.reduce(max);
    final minVal = allData.reduce(min);
    final range = (maxVal - minVal).clamp(0.1, double.infinity);
    final total = allData.length;
    if (total < 2) return;

    double x(int i) => size.width / (total - 1) * i;
    double y(double v) => size.height - ((v - minVal) / range) * size.height * 0.85 - size.height * 0.05;

    // Grid
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..strokeWidth = 1;
    for (int i = 0; i <= 3; i++) {
      final gy = size.height / 3 * i;
      canvas.drawLine(Offset(0, gy), Offset(size.width, gy), gridPaint);
    }

    // Fill под историей
    final fillPath = Path();
    fillPath.moveTo(x(0), size.height);
    for (int i = 0; i < historical.length; i++) {
      fillPath.lineTo(x(i), y(historical[i]));
    }
    fillPath.lineTo(x(historical.length - 1), size.height);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.25), color.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Линия истории
    final histPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final histPath = Path();
    for (int i = 0; i < historical.length; i++) {
      i == 0 ? histPath.moveTo(x(i), y(historical[i])) : histPath.lineTo(x(i), y(historical[i]));
    }
    canvas.drawPath(histPath, histPaint);

    // Пунктирная линия прогноза
    final dashPaint = Paint()
      ..color = color.withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double startX = x(historical.length - 1);
    double startY = y(historical.last);
    for (int i = 0; i < forecast.length; i++) {
      final endX = x(historical.length + i);
      final endY = y(forecast[i]);
      _drawDashedLine(canvas, Offset(startX, startY), Offset(endX, endY), dashPaint);
      startX = endX;
      startY = endY;
    }

    // Точки истории
    final dotPaint = Paint()..color = color..style = PaintingStyle.fill;
    final dotBg = Paint()..color = Colors.black..style = PaintingStyle.fill;
    for (int i = 0; i < historical.length; i++) {
      canvas.drawCircle(Offset(x(i), y(historical[i])), 4, dotBg);
      canvas.drawCircle(Offset(x(i), y(historical[i])), 3, dotPaint);
    }

    // Точки прогноза (полупрозрачные)
    final forecastDot = Paint()..color = color.withOpacity(0.5)..style = PaintingStyle.fill;
    for (int i = 0; i < forecast.length; i++) {
      canvas.drawCircle(Offset(x(historical.length + i), y(forecast[i])), 3, forecastDot);
    }

    // Вертикальная разделительная линия
    final divPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(x(historical.length - 1), 0),
      Offset(x(historical.length - 1), size.height),
      divPaint,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final dist = sqrt(dx * dx + dy * dy);
    final steps = (dist / 8).floor();
    for (int i = 0; i < steps; i += 2) {
      final s = Offset(start.dx + dx * i / steps, start.dy + dy * i / steps);
      final e = Offset(start.dx + dx * (i + 1) / steps, start.dy + dy * (i + 1) / steps);
      canvas.drawLine(s, e, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
