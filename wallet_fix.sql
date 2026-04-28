-- SQL код для исправления проблемы с пополнением кошелька
-- Проблема: при пополнении деньги не добавляются к балансу кошелька

-- 0. Пересоздаём p2p_offers и p2p_deals с UUID первичными ключами
DROP TABLE IF EXISTS p2p_deals CASCADE;
DROP TABLE IF EXISTS p2p_offers CASCADE;
CREATE TABLE p2p_offers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT,
    type VARCHAR(10) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    price DECIMAL(20, 10) NOT NULL,
    limit_min DECIMAL(20, 10),
    limit_max DECIMAL(20, 10),
    available DECIMAL(20, 10),
    pay_methods JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE p2p_offers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active offers" ON p2p_offers FOR SELECT USING (true);
CREATE POLICY "Users can insert own offers" ON p2p_offers FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own offers" ON p2p_offers FOR UPDATE USING (auth.uid() = user_id);
CREATE TABLE p2p_deals (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    offer_id UUID,
    seller_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    buyer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    seller_username TEXT,
    buyer_username TEXT,
    currency VARCHAR(10),
    price DECIMAL(20, 10),
    amount DECIMAL(20, 10) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE p2p_deals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their deals" ON p2p_deals FOR SELECT USING (auth.uid() = seller_id OR auth.uid() = buyer_id);
CREATE POLICY "Users can insert deals" ON p2p_deals FOR INSERT WITH CHECK (auth.uid() = buyer_id);
CREATE POLICY "Users can update their deals" ON p2p_deals FOR UPDATE USING (auth.uid() = seller_id OR auth.uid() = buyer_id);

-- 1. Создаём функцию для обновления баланса кошелька при транзакциях
CREATE OR REPLACE FUNCTION update_wallet_balance()
RETURNS TRIGGER AS $$
BEGIN
    -- Находим кошелёк пользователя для данной валюты
    -- Если кошелька нет, создаём его
    INSERT INTO wallets (user_id, currency_code, balance)
    VALUES (NEW.user_id, NEW.currency, 0)
    ON CONFLICT (user_id, currency_code) DO NOTHING;

    -- Обновляем баланс в зависимости от типа транзакции
    IF NEW.type = 'deposit' THEN
        UPDATE wallets
        SET balance = balance + NEW.amount,
            updated_at = NOW()
        WHERE user_id = NEW.user_id AND currency_code = NEW.currency;
    ELSIF NEW.type = 'withdraw' THEN
        UPDATE wallets
        SET balance = balance - NEW.amount,
            updated_at = NOW()
        WHERE user_id = NEW.user_id AND currency_code = NEW.currency;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Создаём триггер, который будет вызывать функцию при вставке транзакции
DROP TRIGGER IF EXISTS trigger_update_wallet_balance ON transactions;
CREATE TRIGGER trigger_update_wallet_balance
    AFTER INSERT ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_wallet_balance();

-- 3. Исправляем структуру таблицы transactions (если она существует)
-- Убеждаемся, что таблица transactions имеет правильную структуру
CREATE TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL, -- 'deposit', 'withdraw', 'transfer', 'exchange'
    amount DECIMAL(20, 10) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    method VARCHAR(100), -- способ оплаты (Kaspi, карта и т.д.)
    status VARCHAR(20) DEFAULT 'completed', -- 'pending', 'completed', 'failed'
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Создаём индексы для производительности
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_currency ON transactions(currency);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at);

-- 5. Row Level Security для таблицы transactions
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- Политика: пользователи могут видеть только свои транзакции
DROP POLICY IF EXISTS "Users can view own transactions" ON transactions;
CREATE POLICY "Users can view own transactions" ON transactions
    FOR SELECT USING (auth.uid() = user_id);

-- Политика: пользователи могут вставлять только свои транзакции
DROP POLICY IF EXISTS "Users can insert own transactions" ON transactions;
CREATE POLICY "Users can insert own transactions" ON transactions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 6. Функция для получения баланса кошелька
DROP FUNCTION IF EXISTS get_wallet_balance(uuid, character varying);
CREATE OR REPLACE FUNCTION get_wallet_balance(p_user_uuid UUID, p_currency_code VARCHAR)
RETURNS DECIMAL AS $$
DECLARE
    balance DECIMAL(20, 10);
BEGIN
    SELECT w.balance INTO balance
    FROM wallets w
    WHERE w.user_id = p_user_uuid AND w.currency_code = p_currency_code;

    RETURN COALESCE(balance, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Функция для безопасного пополнения кошелька
DROP FUNCTION IF EXISTS deposit_wallet(uuid, numeric, character varying, character varying);
CREATE OR REPLACE FUNCTION deposit_wallet(
    p_user_uuid UUID,
    p_amount DECIMAL,
    p_currency_code VARCHAR,
    p_payment_method VARCHAR DEFAULT 'Kaspi'
) RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    -- Вставляем транзакцию (триггер автоматически обновит баланс)
    INSERT INTO transactions (user_id, type, amount, currency, method, status)
    VALUES (p_user_uuid, 'deposit', p_amount, p_currency_code, p_payment_method, 'completed');

    -- Возвращаем новый баланс
    SELECT json_build_object(
        'success', true,
        'new_balance', get_wallet_balance(p_user_uuid, p_currency_code),
        'message', 'Пополнение успешно выполнено'
    ) INTO result;

    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Ошибка при пополнении: ' || SQLERRM
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Функция для безопасного вывода средств
DROP FUNCTION IF EXISTS withdraw_wallet(uuid, numeric, character varying, character varying);
CREATE OR REPLACE FUNCTION withdraw_wallet(
    p_user_uuid UUID,
    p_amount DECIMAL,
    p_currency_code VARCHAR,
    p_payment_method VARCHAR DEFAULT 'Kaspi'
) RETURNS JSON AS $$
DECLARE
    current_balance DECIMAL;
    result JSON;
BEGIN
    -- Проверяем баланс
    SELECT get_wallet_balance(p_user_uuid, p_currency_code) INTO current_balance;

    IF current_balance < p_amount THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Недостаточно средств на балансе'
        );
    END IF;

    -- Вставляем транзакцию (триггер автоматически обновит баланс)
    INSERT INTO transactions (user_id, type, amount, currency, method, status)
    VALUES (p_user_uuid, 'withdraw', p_amount, p_currency_code, p_payment_method, 'completed');

    -- Возвращаем новый баланс
    SELECT json_build_object(
        'success', true,
        'new_balance', get_wallet_balance(p_user_uuid, p_currency_code),
        'message', 'Вывод успешно выполнен'
    ) INTO result;

    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Ошибка при выводе: ' || SQLERRM
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;