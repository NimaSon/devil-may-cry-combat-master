import 'package:flutter/material.dart';
import 'app_background.dart';

class RateManagementScreen extends StatefulWidget {
  final List<Map<String, String>> currentRates;

  const RateManagementScreen({super.key, required this.currentRates});

  @override
  State<RateManagementScreen> createState() => _RateManagementScreenState();
}

class _RateManagementScreenState extends State<RateManagementScreen> {
  late List<Map<String, TextEditingController>> controllers;

  @override
  void initState() {
    super.initState();
    controllers = widget.currentRates.map((rate) {
      return {
        'flag': TextEditingController(text: rate['flag']),
        'buy': TextEditingController(text: rate['buy']),
        'sell': TextEditingController(text: rate['sell']),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Управление курсами', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            TextButton(
              onPressed: () {
                final updatedRates = controllers.map((controller) {
                  return {
                    'flag': controller['flag']!.text,
                    'buy': controller['buy']!.text,
                    'sell': controller['sell']!.text,
                  };
                }).toList();
                Navigator.pop(context, updatedRates);
              },
              child: const Text('Сохранить', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controllers.length,
          itemBuilder: (context, index) {
            final controller = controllers[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(controller['flag']!.text, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 16),
                      Text(
                        _getCurrencyName(controller['flag']!.text),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller['buy'],
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Покупка',
                            labelStyle: const TextStyle(color: Colors.white70),
                            suffixText: '₸',
                            suffixStyle: const TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: controller['sell'],
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Продажа',
                            labelStyle: const TextStyle(color: Colors.white70),
                            suffixText: '₸',
                            suffixStyle: const TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getCurrencyName(String flag) {
    const names = {
      '🇺🇸': 'USD',
      '🇪🇺': 'EUR',
      '🇷🇺': 'RUB',
    };
    return names[flag] ?? '';
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller['flag']?.dispose();
      controller['buy']?.dispose();
      controller['sell']?.dispose();
    }
    super.dispose();
  }
}
