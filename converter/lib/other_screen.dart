import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'translations.dart';
import 'login_screen.dart';
import 'my_exchanger_screen.dart';
import 'rate_history_screen.dart';

class OtherScreen extends StatelessWidget {
  final String selectedCountry;
  final String selectedLanguage;
  final bool isLoggedIn;
  final bool isLegalEntity;
  final Function(String) onCountryChanged;
  final Function(String) onLanguageChanged;
  final Function(bool) onLogin;
  final VoidCallback onLogout;
  final List<Map<String, String>> aiuBankRates;
  final Function(List<Map<String, String>>) onRatesUpdate;
  final List<Map<String, dynamic>> rateHistory;

  const OtherScreen({
    super.key,
    required this.selectedCountry,
    required this.selectedLanguage,
    required this.isLoggedIn,
    required this.isLegalEntity,
    required this.onCountryChanged,
    required this.onLanguageChanged,
    required this.onLogin,
    required this.onLogout,
    required this.aiuBankRates,
    required this.onRatesUpdate,
    required this.rateHistory,
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
          if (isLoggedIn && isLegalEntity)
            _buildMenuItem(Icons.store, 'Мой обменник', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyExchangerScreen(
                    aiuBankRates: aiuBankRates,
                    onRatesUpdate: onRatesUpdate,
                  ),
                ),
              );
            }),
          if (isLoggedIn && isLegalEntity)
            _buildMenuItem(Icons.history, 'История изменения курсов', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RateHistoryScreen(history: rateHistory),
                ),
              );
            }),
          if (isLoggedIn && isLegalEntity)
            _buildMenuItem(Icons.sell, 'Мои продажи', () {}),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () async {
                if (isLoggedIn) {
                  onLogout();
                } else {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                  if (result != null && result is bool) {
                    onLogin(result);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoggedIn ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isLoggedIn ? 'Выход' : 'Вход',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
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
