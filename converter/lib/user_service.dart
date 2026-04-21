import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final localFavorites = prefs.getStringList('favorite_currencies') ?? ['KZT', 'AED', 'INR', 'RUB', 'KRW'];

    final user = _supabase.auth.currentUser;
    if (user != null) {
      final profile = await getUserProfile();
      final serverFavorites = profile?['favorite_currencies'];
      if (serverFavorites is List && serverFavorites.isNotEmpty) {
        final serverList = List<String>.from(serverFavorites);
        // Синхронизировать локально
        await prefs.setStringList('favorite_currencies', serverList);
        return serverList;
      } else {
        // Если на сервере пусто, загрузить локальные на сервер
        await setFavoriteCurrencies(localFavorites);
        return localFavorites;
      }
    }
    return localFavorites;
  }

  // Установить избранные валюты
  static Future<void> setFavoriteCurrencies(List<String> currencies) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_currencies', currencies);

    final user = _supabase.auth.currentUser;
    if (user != null) {
      await updateUserProfile({'favorite_currencies': currencies});
    }
  }
    final prefs = await SharedPreferences.getInstance();
    final localFavorites = prefs.getStringList('favorite_crypto') ?? ['BTC'];

    final user = _supabase.auth.currentUser;
    if (user != null) {
      final profile = await getUserProfile();
      final serverFavorites = profile?['favorite_crypto'];
      if (serverFavorites is List && serverFavorites.isNotEmpty) {
        final serverList = List<String>.from(serverFavorites);
        await prefs.setStringList('favorite_crypto', serverList);
        return serverList;
      } else {
        await setFavoriteCrypto(localFavorites);
        return localFavorites;
      }
    }
    return localFavorites;
  }

  // Установить избранные криптовалюты
  static Future<void> setFavoriteCrypto(List<String> currencies) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_crypto', currencies);

    final user = _supabase.auth.currentUser;
    if (user != null) {
      await updateUserProfile({'favorite_crypto': currencies});
    }
  }
}