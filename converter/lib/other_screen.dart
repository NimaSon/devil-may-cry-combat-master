import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'translations.dart';

class OtherScreen extends StatelessWidget {
  final String selectedCountry;
  final String selectedLanguage;
  final Function(String) onCountryChanged;
  final Function(String) onLanguageChanged;

  const OtherScreen({
    super.key,
    required this.selectedCountry,
    required this.selectedLanguage,
    required this.onCountryChanged,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(tr('other', selectedLanguage), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildMenuItem(Icons.attach_money, tr('allRates', selectedLanguage), () {}),
          _buildMenuItem(Icons.show_chart, tr('tradingChart', selectedLanguage), () {}),
          _buildMenuItem(Icons.language, tr('resources', selectedLanguage), () {}),
          _buildMenuItem(Icons.archive, tr('archive', selectedLanguage), () {}),
          _buildMenuItem(Icons.trending_up, tr('stocks', selectedLanguage), () {}),
          _buildMenuItem(Icons.settings, tr('settings', selectedLanguage), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  selectedCountry: selectedCountry,
                  selectedLanguage: selectedLanguage,
                  onCountryChanged: onCountryChanged,
                  onLanguageChanged: onLanguageChanged,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
