import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_background.dart';

class RateHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const RateHistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('История изменения курсов', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: history.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.white38),
                    SizedBox(height: 16),
                    Text('История изменений пуста', style: TextStyle(fontSize: 18, color: Colors.white54)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  final date = item['date'] as DateTime;
                  final rates = item['rates'] as List<Map<String, String>>;
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
                            const Icon(Icons.access_time, size: 20, color: Colors.white54),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd.MM.yyyy HH:mm').format(date),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(color: Colors.white.withValues(alpha: 0.15)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: Text('Покупка', style: TextStyle(fontSize: 14, color: Colors.white54))),
                            const SizedBox(width: 40),
                            Expanded(child: Text('Продажа', style: TextStyle(fontSize: 14, color: Colors.white54), textAlign: TextAlign.right)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...rates.map((rate) {
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
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
