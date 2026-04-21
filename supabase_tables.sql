-- SQL скрипты для создания таблиц в Supabase для приложения конвертера валют

-- Удаление существующих таблиц (для повторного запуска скрипта)
-- Сначала удаляем дочерние таблицы, затем родительские
DROP TABLE IF EXISTS wallet_transactions CASCADE;
DROP TABLE IF EXISTS wallets CASCADE;
DROP TABLE IF EXISTS p2p_deals CASCADE;
DROP TABLE IF EXISTS exchanger_rates CASCADE;
DROP TABLE IF EXISTS exchangers CASCADE;
DROP TABLE IF EXISTS risk_alerts CASCADE;
DROP TABLE IF EXISTS rate_history CASCADE;
DROP TABLE IF EXISTS competitors CASCADE;
DROP TABLE IF EXISTS forecasts CASCADE;
DROP TABLE IF EXISTS stocks CASCADE;
DROP TABLE IF EXISTS news CASCADE;
DROP TABLE IF EXISTS exchange_rates CASCADE;
DROP TABLE IF EXISTS currencies CASCADE;

-- Таблица валют
CREATE TABLE currencies (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    symbol VARCHAR(10),
    flag VARCHAR(10),
    type VARCHAR(20) DEFAULT 'fiat', -- 'fiat' или 'crypto'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Таблица курсов валют
CREATE TABLE exchange_rates (
    id SERIAL PRIMARY KEY,
    from_currency VARCHAR(10) NOT NULL,
    to_currency VARCHAR(10) NOT NULL,
    rate DECIMAL(20, 10) NOT NULL,
    source VARCHAR(50) DEFAULT 'api', -- 'api', 'manual', 'market'
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(from_currency, to_currency, timestamp)
);

-- Таблица новостей
CREATE TABLE news (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    source VARCHAR(100),
    url TEXT UNIQUE,
    published_at TIMESTAMP WITH TIME ZONE,
    url_to_image TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Таблица обменников
CREATE TABLE exchangers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    website TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Таблица ставок обменников
CREATE TABLE exchanger_rates (
    id SERIAL PRIMARY KEY,
    exchanger_id INTEGER REFERENCES exchangers(id) ON DELETE CASCADE,
    currency_code VARCHAR(10) NOT NULL,
    buy_rate DECIMAL(20, 10),
    sell_rate DECIMAL(20, 10),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Таблица P2P сделок
CREATE TABLE p2p_deals (
    id SERIAL PRIMARY KEY,
    seller_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    buyer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    from_currency VARCHAR(10) NOT NULL,
    to_currency VARCHAR(10) NOT NULL,
    amount DECIMAL(20, 10) NOT NULL,
    rate DECIMAL(20, 10) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'completed', 'cancelled'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Таблица рисков/уведомлений
CREATE TABLE risk_alerts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    currency_code VARCHAR(10),
    alert_type VARCHAR(50) DEFAULT 'warning', -- 'warning', 'error', 'info'
    is_active BOOLEAN DEFAULT TRUE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Таблица кошельков
CREATE TABLE wallets (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    currency_code VARCHAR(10) NOT NULL,
    balance DECIMAL(20, 10) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, currency_code)
);

-- Таблица истории ставок
CREATE TABLE rate_history (
    id SERIAL PRIMARY KEY,
    currency_code VARCHAR(10) NOT NULL,
    rate DECIMAL(20, 10) NOT NULL,
    change_amount DECIMAL(20, 10),
    change_percent DECIMAL(10, 4),
    is_up BOOLEAN,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Таблица транзакций кошелька
CREATE TABLE wallet_transactions (
    id SERIAL PRIMARY KEY,
    wallet_id INTEGER REFERENCES wallets(id) ON DELETE CASCADE,
    transaction_type VARCHAR(20) NOT NULL, -- 'deposit', 'withdraw', 'transfer', 'exchange'
    amount DECIMAL(20, 10) NOT NULL,
    description TEXT,
    related_transaction_id INTEGER, -- для связанных транзакций
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Таблица конкурентов (для competitor_rates_screen)
CREATE TABLE competitors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    currency_code VARCHAR(10) NOT NULL,
    buy_rate DECIMAL(20, 10),
    sell_rate DECIMAL(20, 10),
    location TEXT,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Таблица прогнозов
CREATE TABLE forecasts (
    id SERIAL PRIMARY KEY,
    currency_code VARCHAR(10) NOT NULL,
    forecast_type VARCHAR(50), -- 'short_term', 'long_term'
    prediction DECIMAL(20, 10),
    confidence DECIMAL(5, 4), -- 0.0000 to 1.0000
    timeframe VARCHAR(50), -- '1h', '24h', '7d', etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Таблица акций
CREATE TABLE stocks (
    id SERIAL PRIMARY KEY,
    symbol VARCHAR(10) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(20, 10),
    change_amount DECIMAL(20, 10),
    change_percent DECIMAL(10, 4),
    is_up BOOLEAN,
    market_cap DECIMAL(30, 2),
    volume DECIMAL(20, 2),
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Таблица избранных валют пользователей
CREATE TABLE user_favorites (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    currency_code VARCHAR(10) NOT NULL,
    currency_type VARCHAR(20) DEFAULT 'fiat', -- 'fiat' или 'crypto'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, currency_code, currency_type)
);

-- Индексы для производительности
CREATE INDEX idx_exchange_rates_from_currency ON exchange_rates(from_currency);
CREATE INDEX idx_exchange_rates_to_currency ON exchange_rates(to_currency);
CREATE INDEX idx_exchange_rates_timestamp ON exchange_rates(timestamp);
CREATE INDEX idx_news_published_at ON news(published_at);
CREATE INDEX idx_exchanger_rates_exchanger_id ON exchanger_rates(exchanger_id);
CREATE INDEX idx_exchanger_rates_currency ON exchanger_rates(currency_code);
CREATE INDEX idx_p2p_deals_seller ON p2p_deals(seller_id);
CREATE INDEX idx_p2p_deals_buyer ON p2p_deals(buyer_id);
CREATE INDEX idx_p2p_deals_status ON p2p_deals(status);
CREATE INDEX idx_wallets_user ON wallets(user_id);
CREATE INDEX idx_rate_history_currency ON rate_history(currency_code);
CREATE INDEX idx_wallet_transactions_wallet ON wallet_transactions(wallet_id);

-- Row Level Security (RLS) политики
ALTER TABLE currencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE exchange_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE news ENABLE ROW LEVEL SECURITY;
ALTER TABLE exchangers ENABLE ROW LEVEL SECURITY;
ALTER TABLE exchanger_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE p2p_deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE risk_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE rate_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE competitors ENABLE ROW LEVEL SECURITY;
ALTER TABLE forecasts ENABLE ROW LEVEL SECURITY;
ALTER TABLE stocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;

-- Политики для exchangers (пользователи могут видеть и редактировать только свои обменники)
CREATE POLICY "Users can view all exchangers" ON exchangers FOR SELECT USING (true);
CREATE POLICY "Users can insert their own exchangers" ON exchangers FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own exchangers" ON exchangers FOR UPDATE USING (auth.uid() = user_id);

-- Политики для exchanger_rates
CREATE POLICY "Users can view all exchanger rates" ON exchanger_rates FOR SELECT USING (true);
CREATE POLICY "Exchangers can insert their rates" ON exchanger_rates FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM exchangers WHERE id = exchanger_id AND user_id = auth.uid())
);
CREATE POLICY "Exchangers can update their rates" ON exchanger_rates FOR UPDATE USING (
    EXISTS (SELECT 1 FROM exchangers WHERE id = exchanger_id AND user_id = auth.uid())
);

-- Политики для p2p_deals
CREATE POLICY "Users can view their deals" ON p2p_deals FOR SELECT USING (
    auth.uid() = seller_id OR auth.uid() = buyer_id
);
CREATE POLICY "Users can insert deals" ON p2p_deals FOR INSERT WITH CHECK (auth.uid() = seller_id);
CREATE POLICY "Users can update their deals" ON p2p_deals FOR UPDATE USING (
    auth.uid() = seller_id OR auth.uid() = buyer_id
);

-- Политики для wallets
CREATE POLICY "Users can view their wallets" ON wallets FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their wallets" ON wallets FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their wallets" ON wallets FOR UPDATE USING (auth.uid() = user_id);

-- Политики для wallet_transactions
CREATE POLICY "Users can view their transactions" ON wallet_transactions FOR SELECT USING (
    EXISTS (SELECT 1 FROM wallets WHERE id = wallet_id AND user_id = auth.uid())
);
CREATE POLICY "Users can insert their transactions" ON wallet_transactions FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM wallets WHERE id = wallet_id AND user_id = auth.uid())
);

-- Политики для risk_alerts
CREATE POLICY "Users can view their alerts" ON risk_alerts FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "System can insert alerts" ON risk_alerts FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update their alerts" ON risk_alerts FOR UPDATE USING (auth.uid() = user_id);

-- Остальные таблицы доступны всем для чтения
CREATE POLICY "Public read currencies" ON currencies FOR SELECT USING (true);
CREATE POLICY "Public read exchange_rates" ON exchange_rates FOR SELECT USING (true);
CREATE POLICY "Public read news" ON news FOR SELECT USING (true);
CREATE POLICY "Public read rate_history" ON rate_history FOR SELECT USING (true);
CREATE POLICY "Public read competitors" ON competitors FOR SELECT USING (true);
CREATE POLICY "Public read forecasts" ON forecasts FOR SELECT USING (true);
CREATE POLICY "Public read stocks" ON stocks FOR SELECT USING (true);

-- Политики для user_favorites
CREATE POLICY "Users can view their favorites" ON user_favorites FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their favorites" ON user_favorites FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete their favorites" ON user_favorites FOR DELETE USING (auth.uid() = user_id);

-- Функции для обновления updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Триггеры для updated_at
CREATE TRIGGER update_currencies_updated_at BEFORE UPDATE ON currencies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_exchangers_updated_at BEFORE UPDATE ON exchangers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_wallets_updated_at BEFORE UPDATE ON wallets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();