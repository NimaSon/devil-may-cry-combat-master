import 'package:flutter/material.dart';
import 'app_background.dart';
import 'translations.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final String selectedLanguage;

  const LanguageSelectionScreen({super.key, required this.selectedLanguage});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late String _selectedLanguage;

  final List<Map<String, String>> languages = [
    {'code': 'ru', 'flag': '🇷🇺', 'name': 'Русский'},
    {'code': 'en', 'flag': '🇬🇧', 'name': 'English'},
    {'code': 'kk', 'flag': '🇰🇿', 'name': 'Қазақша'},
    {'code': 'es', 'flag': '🇪🇸', 'name': 'Español'},
    {'code': 'de', 'flag': '🇩🇪', 'name': 'Deutsch'},
    {'code': 'fr', 'flag': '🇫🇷', 'name': 'Français'},
    {'code': 'zh', 'flag': '🇨🇳', 'name': '中文'},
    {'code': 'ja', 'flag': '🇯🇵', 'name': '日本語'},
    {'code': 'ar', 'flag': '🇸🇦', 'name': 'العربية'},
    {'code': 'pt', 'flag': '🇵🇹', 'name': 'Português'},
    {'code': 'tr', 'flag': '🇹🇷', 'name': 'Türkçe'},
    {'code': 'it', 'flag': '🇮🇹', 'name': 'Italiano'},
    {'code': 'ko', 'flag': '🇰🇷', 'name': '한국어'},
    {'code': 'hi', 'flag': '🇮🇳', 'name': 'हिन्दी'},
    {'code': 'uk', 'flag': '🇺🇦', 'name': 'Українська'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.selectedLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          title: Text(tr('changeLanguage', widget.selectedLanguage)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, _selectedLanguage),
              child: Text(tr('done', widget.selectedLanguage), style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final language = languages[index];
            final isSelected = _selectedLanguage == language['code'];
            return ListTile(
              leading: Text(language['flag']!, style: const TextStyle(fontSize: 40)),
              title: Text(language['name']!, style: const TextStyle(fontSize: 18, color: Colors.white)),
              trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF42A5F5)) : null,
              onTap: () => setState(() => _selectedLanguage = language['code']!),
            );
          },
        ),
      ),
    );
  }
}
