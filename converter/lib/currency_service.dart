import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String apiUrl = 'https://api.exchangerate-api.com/v4/latest/KZT';

  static Future<Map<String, double>> fetchRates() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        return rates.map((key, value) => MapEntry(key, value.toDouble()));
      }
      return {};
    } catch (e) {
      print('Error fetching rates: $e');
      return {};
    }
  }

  static String formatPrice(double rate) {
    if (rate >= 1) {
      return '${(1 / rate).toStringAsFixed(2)} ₸';
    } else {
      return '${(1 / rate).toStringAsFixed(2)} ₸';
    }
  }
}
