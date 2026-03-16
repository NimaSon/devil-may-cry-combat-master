import 'package:flutter/material.dart';
import 'country_selection_screen.dart';
import 'language_selection_screen.dart';
import 'translations.dart';
import 'app_background.dart';

class SettingsScreen extends StatelessWidget {
  final String selectedCountry;
  final String selectedLanguage;
  final Function(String) onCountryChanged;
  final Function(String) onLanguageChanged;

  const SettingsScreen({
    super.key,
    required this.selectedCountry,
    required this.selectedLanguage,
    required this.onCountryChanged,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(tr('settings', selectedLanguage))),
        body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(tr('basics', selectedLanguage), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          _buildMenuItem(
            context,
            Icons.public,
            tr('country', selectedLanguage),
            _getCountryName(selectedCountry),
            () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CountrySelectionScreen(selectedCountry: selectedCountry),
                ),
              );
              if (result != null) {
                onCountryChanged(result);
              }
            },
          ),
          _buildMenuItem(
            context,
            Icons.star,
            tr('favorites', selectedLanguage),
            tr('changeFavorites', selectedLanguage),
            () {},
          ),
          _buildMenuItem(
            context,
            Icons.language,
            tr('language', selectedLanguage),
            _getLanguageName(selectedLanguage),
            () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LanguageSelectionScreen(selectedLanguage: selectedLanguage),
                ),
              );
              if (result != null) {
                onLanguageChanged(result);
              }
            },
          ),
          _buildMenuItem(
            context,
            Icons.notifications,
            tr('notifications', selectedLanguage),
            tr('enabled', selectedLanguage),
            () {},
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.white54)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: onTap,
    );
  }

  String _getCountryName(String code) {
    const countries = {
      'KZT': 'Казахстан',
      'RUB': 'Россия',
      'AZN': 'Азербайджан',
      'MDL': 'Молдова',
      'MNT': 'Монголия',
      'KGS': 'Киргизия',
      'RON': 'Румыния',
      'UAH': 'Украина',
      'PLN': 'Польша',
      'GEL': 'Грузия',
      'AMD': 'Армения',
    };
    return countries[code] ?? code;
  }

  String _getLanguageName(String code) {
    const languages = {
      'ru': 'Русский',
      'en': 'English',
      'kk': 'Қазақша',
      'es': 'Español',
      'de': 'Deutsch',
      'fr': 'Français',
      'zh': '中文',
      'ja': '日本語',
      'ar': 'العربية',
      'pt': 'Português',
      'tr': 'Türkçe',
      'it': 'Italiano',
      'ko': '한국어',
      'hi': 'हिन्दी',
      'uk': 'Українська',
    };
    return languages[code] ?? code;
  }
}
