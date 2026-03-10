import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static Future<Map<String, double>> fetchRates(String baseCurrency) async {
    try {
      final response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/$baseCurrency'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        return rates.map((key, value) => MapEntry(key, value.toDouble()));
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  static String getCurrencySymbol(String code) {
    const symbols = {
      'KZT': '₸', 'RUB': '₽', 'AZN': '₼', 'MDL': 'L', 'MNT': '₮',
      'KGS': 'с', 'RON': 'lei', 'UAH': '₴', 'PLN': 'zł', 'GEL': '₾', 'AMD': '֏'
    };
    return symbols[code] ?? code;
  }
}
