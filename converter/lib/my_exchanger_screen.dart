import 'package:flutter/material.dart';
import 'rate_management_screen.dart';
import 'app_background.dart';

class MyExchangerScreen extends StatelessWidget {
  final List<Map<String, String>> aiuBankRates;
  final Function(List<Map<String, String>>) onRatesUpdate;
  final String selectedLanguage;

  const MyExchangerScreen({
    super.key,
    required this.aiuBankRates,
    required this.onRatesUpdate,
    required this.selectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Мой обменник', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00E676)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('🏛️', style: TextStyle(fontSize: 48)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aiu Bank',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ваш надежный партнер в обмене валют',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('О нас', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 12),
                Text(
                  '✓ Выгодные курсы обмена валют\n'
                  '✓ Быстрые и безопасные операции\n'
                  '✓ Работаем без выходных\n'
                  '✓ Минимальная комиссия\n'
                  '✓ Профессиональное обслуживание',
                  style: TextStyle(fontSize: 16, height: 1.8, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Текущие курсы', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('🏛️', style: TextStyle(fontSize: 28))),
                    ),
                    const SizedBox(width: 12),
                    const Text('Aiu Bank', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Text('Покупка', style: TextStyle(fontSize: 14, color: Colors.white54))),
                    const SizedBox(width: 40),
                    Expanded(child: Text('Продажа', style: TextStyle(fontSize: 14, color: Colors.white54), textAlign: TextAlign.right)),
                  ],
                ),
                const SizedBox(height: 8),
                ...aiuBankRates.map((rate) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(rate['flag']!, style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 8),
                              Text('${rate['buy']} ₸', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          child: Text('${rate['sell']} ₸', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.right),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RateManagementScreen(currentRates: aiuBankRates),
                      ),
                    );
                    if (result != null) {
                      onRatesUpdate(result);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Управление курсами',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}
