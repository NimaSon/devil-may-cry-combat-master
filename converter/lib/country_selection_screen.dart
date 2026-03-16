import 'package:flutter/material.dart';
import 'app_background.dart';

class CountrySelectionScreen extends StatefulWidget {
  final String selectedCountry;

  const CountrySelectionScreen({super.key, required this.selectedCountry});

  @override
  State<CountrySelectionScreen> createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen> {
  late String _selectedCountry;

  final List<Map<String, String>> countries = [
    {'code': 'KZT', 'flag': '🇰🇿', 'name': 'Казахстан'},
    {'code': 'RUB', 'flag': '🇷🇺', 'name': 'Россия'},
    {'code': 'AZN', 'flag': '🇦🇿', 'name': 'Азербайджан'},
    {'code': 'MDL', 'flag': '🇲🇩', 'name': 'Молдова'},
    {'code': 'MNT', 'flag': '🇲🇳', 'name': 'Монголия'},
    {'code': 'KGS', 'flag': '🇰🇬', 'name': 'Киргизия'},
    {'code': 'RON', 'flag': '🇷🇴', 'name': 'Румыния'},
    {'code': 'UAH', 'flag': '🇺🇦', 'name': 'Украина'},
    {'code': 'PLN', 'flag': '🇵🇱', 'name': 'Польша'},
    {'code': 'GEL', 'flag': '🇬🇪', 'name': 'Грузия'},
    {'code': 'AMD', 'flag': '🇦🇲', 'name': 'Армения'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.selectedCountry;
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          title: const Text('Изменение страны'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, _selectedCountry),
              child: const Text('Готово', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: countries.length,
          itemBuilder: (context, index) {
            final country = countries[index];
            final isSelected = _selectedCountry == country['code'];
            return ListTile(
              leading: Text(country['flag']!, style: const TextStyle(fontSize: 40)),
              title: Text(country['name']!, style: const TextStyle(fontSize: 18, color: Colors.white)),
              trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF42A5F5)) : null,
              onTap: () => setState(() => _selectedCountry = country['code']!),
            );
          },
        ),
      ),
    );
  }
}
