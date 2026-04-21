import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static final _supabase = Supabase.instance.client;

  // Получить профиль пользователя
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('user_profiles')
        .select()
        .eq('user_id', user.id)
        .order('updated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return response;
  }

  // Обновить или создать профиль пользователя
  static Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('user_profiles').upsert({
      'user_id': user.id,
      ...data,
    });
  }

  // Получить язык пользователя
  static Future<String> getUserLanguage() async {
    final profile = await getUserProfile();
    return profile?['language'] ?? 'ru';
  }

  // Установить язык пользователя
  static Future<void> setUserLanguage(String language) async {
    await updateUserProfile({'language': language});
  }

  // Получить избранные валюты
  static Future<List<String>> getFavoriteCurrencies() async {
    final profile = await getUserProfile();
    final favorites = profile?['favorite_currencies'];
    if (favorites is List) {
      return List<String>.from(favorites);
    }
    return ['KZT', 'AED', 'INR', 'RUB', 'KRW']; // дефолт
  }

  // Установить избранные валюты
  static Future<void> setFavoriteCurrencies(List<String> currencies) async {
    await updateUserProfile({'favorite_currencies': currencies});
  }
}