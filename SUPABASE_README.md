# Supabase Database Schema для приложения конвертера валют

Этот репозиторий содержит SQL скрипты для настройки базы данных Supabase для Flutter приложения конвертера валют.

## Файлы

- `supabase_tables.sql` - Основные таблицы, индексы, RLS политики и триггеры
- `supabase_initial_data.sql` - Начальные данные для валют, курсов и акций

## Как использовать

### 1. Создание таблиц

1. Откройте ваш проект Supabase в браузере
2. Перейдите в раздел "SQL Editor"
3. Скопируйте содержимое файла `supabase_tables.sql`
4. Вставьте и выполните скрипт

### 2. Заполнение начальными данными

1. В SQL Editor Supabase
2. Скопируйте содержимое файла `supabase_initial_data.sql`
3. Вставьте и выполните скрипт

### 3. Настройка аутентификации

Убедитесь, что в Supabase включена аутентификация по email/password:
- В Dashboard → Authentication → Settings
- Включите "Enable email confirmations" если нужно
- Настройте URL для подтверждения email

## Структура таблиц

### Основные таблицы

- **currencies** - Валюты и криптовалюты
- **exchange_rates** - Курсы обмена валют
- **news** - Экономические новости
- **exchangers** - Обменники валют
- **exchanger_rates** - Ставки обменников
- **p2p_deals** - P2P сделки
- **risk_alerts** - Уведомления о рисках
- **wallets** - Кошельки пользователей
- **rate_history** - История изменения курсов
- **wallet_transactions** - Транзакции кошелька
- **competitors** - Конкуренты
- **forecasts** - Прогнозы валют
- **stocks** - Акции

### Безопасность

Все таблицы защищены Row Level Security (RLS) политиками:
- Пользователи могут видеть только свои данные
- Обменники могут управлять только своими ставками
- Публичные данные (валюты, курсы, новости) доступны всем

## API ключи

В коде приложения используются следующие API:
- **NewsAPI**: `9b1a0df9542f4868b9863b57659f4ec9` (нужно заменить на свой)
- **Exchange Rate API**: Бесплатный API для курсов валют

## Следующие шаги

1. Настройте API ключи в коде
2. Реализуйте сервисы для работы с Supabase
3. Добавьте логику для автоматического обновления курсов
4. Настройте push-уведомления для рисков

## Пример использования в Flutter

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// Получение курсов
final rates = await supabase
    .from('exchange_rates')
    .select()
    .eq('from_currency', 'USD')
    .eq('to_currency', 'KZT')
    .order('timestamp', ascending: false)
    .limit(1);

// Добавление ставки обменника
await supabase.from('exchanger_rates').insert({
    'exchanger_id': exchangerId,
    'currency_code': 'USD',
    'buy_rate': 485.50,
    'sell_rate': 492.00,
});
```