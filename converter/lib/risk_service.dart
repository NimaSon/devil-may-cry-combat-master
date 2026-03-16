class RiskAlert {
  final String title;
  final String description;
  final DateTime time;
  final bool isWarning;

  RiskAlert({
    required this.title,
    required this.description,
    required this.time,
    required this.isWarning,
  });
}

class RiskService {
  // Средние рыночные курсы по всем банкам (кроме Aiu Bank)
  static const _marketRates = {
    'USD': {'buy': 484.24, 'sell': 491.5},
    'EUR': {'buy': 563.74, 'sell': 572.24},
    'RUB': {'buy': 6.02, 'sell': 6.44},
  };

  static const _currencyNames = {
    '🇺🇸': 'USD',
    '🇪🇺': 'EUR',
    '🇷🇺': 'RUB',
  };

  // Порог отклонения в процентах
  static const double _threshold = 3.0;

  static List<RiskAlert> analyzeRates(List<Map<String, String>> aiuRates) {
    final alerts = <RiskAlert>[];

    for (final rate in aiuRates) {
      final code = _currencyNames[rate['flag']] ?? '';
      if (code.isEmpty) continue;

      final market = _marketRates[code];
      if (market == null) continue;

      final aiuBuy = double.tryParse(rate['buy']!.replaceAll(',', '.')) ?? 0;
      final aiuSell = double.tryParse(rate['sell']!.replaceAll(',', '.')) ?? 0;

      final marketBuy = market['buy']!;
      final marketSell = market['sell']!;

      // Покупка слишком низкая — банк теряет валюту
      final buyDiff = ((aiuBuy - marketBuy) / marketBuy * 100);
      if (buyDiff < -_threshold) {
        alerts.add(RiskAlert(
          title: '⚠️ Низкий курс покупки $code',
          description:
              'Курс покупки $code (${aiuBuy.toStringAsFixed(1)} ₸) на ${buyDiff.abs().toStringAsFixed(1)}% ниже рынка (${marketBuy.toStringAsFixed(1)} ₸). Клиенты продадут валюту конкурентам.',
          time: DateTime.now(),
          isWarning: true,
        ));
      }

      // Продажа слишком высокая — клиенты уйдут
      final sellDiff = ((aiuSell - marketSell) / marketSell * 100);
      if (sellDiff > _threshold) {
        alerts.add(RiskAlert(
          title: '🚨 Высокий курс продажи $code',
          description:
              'Курс продажи $code (${aiuSell.toStringAsFixed(1)} ₸) на ${sellDiff.toStringAsFixed(1)}% выше рынка (${marketSell.toStringAsFixed(1)} ₸). Риск потери клиентов и банкротства.',
          time: DateTime.now(),
          isWarning: true,
        ));
      }

      // Продажа ниже покупки — прямой убыток
      if (aiuSell < aiuBuy) {
        alerts.add(RiskAlert(
          title: '🔴 Критическая ошибка $code',
          description:
              'Курс продажи $code (${aiuSell.toStringAsFixed(1)} ₸) ниже курса покупки (${aiuBuy.toStringAsFixed(1)} ₸). Банк работает в убыток!',
          time: DateTime.now(),
          isWarning: true,
        ));
      }
    }

    return alerts;
  }
}
