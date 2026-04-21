import 'package:flutter/material.dart';
import 'dart:math';

class TradingChartScreen extends StatefulWidget {
  final List<Map<String, String>> aiuBankRates;
  final List<Map<String, dynamic>> rateHistory;

  const TradingChartScreen({
    super.key,
    required this.aiuBankRates,
    required this.rateHistory,
  });

  @override
  State<TradingChartScreen> createState() => _TradingChartScreenState();
}

class _TradingChartScreenState extends State<TradingChartScreen> {
  String selectedCurrency = 'USD';
  String selectedPeriod = '1Д';

  Map<String, bool> _getCurrencyTrends() {
    Map<String, bool> trends = {};
    
    final currencies = ['USD', 'EUR', 'RUB'];
    for (int i = 0; i < currencies.length; i++) {
      final currentBuy = double.tryParse(widget.aiuBankRates[i]['buy']!.replaceAll(',', '.')) ?? 0;
      final currentSell = double.tryParse(widget.aiuBankRates[i]['sell']!.replaceAll(',', '.')) ?? 0;
      
      trends[currencies[i]] = currentSell >= currentBuy;
    }
    
    return trends;
  }

  List<double> _generateChartData(String currency, bool isUp) {
    final index = currency == 'USD' ? 0 : currency == 'EUR' ? 1 : 2;
    final currentBuy = double.tryParse(widget.aiuBankRates[index]['buy']!.replaceAll(',', '.')) ?? 0;
    final currentSell = double.tryParse(widget.aiuBankRates[index]['sell']!.replaceAll(',', '.')) ?? 0;
    
    List<double> data = [];
    if (isUp) {
      for (int i = 0; i < 15; i++) {
        final progress = i / 14;
        data.add(currentBuy + (currentSell - currentBuy) * progress);
      }
    } else {
      for (int i = 0; i < 15; i++) {
        final progress = i / 14;
        data.add(currentBuy - (currentBuy - currentSell) * progress);
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final trends = _getCurrencyTrends();
    final isUp = trends[selectedCurrency] ?? true;
    final chartColor = isUp ? const Color(0xFF00C853) : const Color(0xFFFF1744);
    final chartDataForCurrency = _generateChartData(selectedCurrency, isUp);
    
    final index = selectedCurrency == 'USD' ? 0 : selectedCurrency == 'EUR' ? 1 : 2;
    final currentBuy = double.tryParse(widget.aiuBankRates[index]['buy']!.replaceAll(',', '.')) ?? 0;
    final currentSell = double.tryParse(widget.aiuBankRates[index]['sell']!.replaceAll(',', '.')) ?? 0;
    final changeValue = (currentSell - currentBuy).abs();
    final change = currentSell >= currentBuy ? '+' : '-';
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'График торгов',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCurrencyChip('USD', '🇺🇸'),
                  const SizedBox(width: 8),
                  _buildCurrencyChip('EUR', '🇪🇺'),
                  const SizedBox(width: 8),
                  _buildCurrencyChip('RUB', '🇷🇺'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isUp 
                      ? [const Color(0xFF00C853), const Color(0xFF00E676)]
                      : [const Color(0xFFFF1744), const Color(0xFFFF5252)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedCurrency,
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${currentSell.toStringAsFixed(1)} ₸',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white, size: 16),
                        Text(
                          '$change${changeValue.toStringAsFixed(2)} ₸',
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildPeriodChip('1Д'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('1Н'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('1М'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('1Г'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CustomPaint(
                  painter: ChartPainter(
                    data: chartDataForCurrency,
                    color: chartColor,
                  ),
                  child: Container(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyChip(String currency, String flag) {
    final trends = _getCurrencyTrends();
    final isUp = trends[currency] ?? true;
    final isSelected = selectedCurrency == currency;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCurrency = currency;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
            ? (isUp ? Colors.green : Colors.red) 
            : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              currency,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String period) {
    final isSelected = selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          period,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  ChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final maxValue = data.reduce(max);
    final minValue = data.reduce(min);
    final range = maxValue - minValue;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (size.width / (data.length - 1)) * i;
      final y = size.height - ((data[i] - minValue) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = (size.width / (data.length - 1)) * i;
      final y = size.height - ((data[i] - minValue) / range) * size.height;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
