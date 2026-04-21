import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'translations.dart';
import 'login_screen.dart';
import 'my_exchanger_screen.dart';
import 'rate_history_screen.dart';
import 'risk_notifications_screen.dart';
import 'risk_service.dart';
import 'competitor_rates_screen.dart';
import 'stocks_screen.dart';
import 'resources_screen.dart';
import 'nearby_exchangers_screen.dart';
import 'news_screen.dart';
import 'forecast_screen.dart';
import 'wallet_screen.dart';
import 'p2p_deals_screen.dart';
import 'app_background.dart';
import 'l10n_service.dart';

class OtherScreen extends StatelessWidget {
  final String selectedCountry;
  final bool isLoggedIn;
  final bool isLegalEntity;
  final Function(String) onCountryChanged;
  final Function(bool) onLogin;
  final VoidCallback onLogout;
  final VoidCallback onNavigateToChart;
  final VoidCallback onNavigateToHome;
  final List<Map<String, String>> aiuBankRates;
  final Function(List<Map<String, String>>) onRatesUpdate;
  final List<Map<String, dynamic>> rateHistory;
  final List<RiskAlert> riskAlerts;
  final List<BankForecast> bankForecasts;
  final Function(List<BankForecast>) onForecastsUpdate;

  const OtherScreen({
    super.key,
    required this.selectedCountry,
    required this.isLoggedIn,
    required this.isLegalEntity,
    required this.onCountryChanged,
    required this.onLogin,
    required this.onLogout,
    required this.onNavigateToChart,
    required this.onNavigateToHome,
    required this.aiuBankRates,
    required this.onRatesUpdate,
    required this.rateHistory,
    required this.riskAlerts,
    required this.bankForecasts,
    required this.onForecastsUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          padding: const EdgeInsets.all(16),
        children: [
          Text(tr('other', L10n.locale.languageCode), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          _buildMenuItem(Icons.attach_money, tr('allRates', L10n.locale.languageCode), () {
            onNavigateToHome();
          }),
          if (!isLegalEntity)
            _buildMenuItem(Icons.account_balance_wallet, tr('wallet', L10n.locale.languageCode), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WalletScreen()));
            }),
          if (!isLegalEntity)
            _buildMenuItem(Icons.handshake_outlined, tr('myP2PDeals', L10n.locale.languageCode), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const P2PDealsScreen()));
            }),
          if (!isLegalEntity)
            _buildMenuItem(Icons.location_on, tr('nearbyExchangers', selectedLanguage), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NearbyExchangersScreen()));
            }),
          if (isLoggedIn && isLegalEntity)
            _buildMenuItem(Icons.show_chart, tr('tradingChart', selectedLanguage), () {
              onNavigateToChart();
            }),
          if (!isLegalEntity)
            _buildMenuItem(Icons.newspaper, tr('economicNews', selectedLanguage), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NewsScreen()));
            }),
          if (!isLegalEntity)
            _buildMenuItem(Icons.auto_graph, tr('forecastRate', selectedLanguage), () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ForecastViewScreen(forecasts: bankForecasts, aiuBankRates: aiuBankRates, rateHistory: rateHistory),
              ));
            }),
          if (isLoggedIn && isLegalEntity)
            _buildMenuItem(Icons.auto_graph, tr('forecastManage', selectedLanguage), () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ForecastManageScreen(
                  forecasts: bankForecasts,
                  onSave: onForecastsUpdate,
                ),
              ));
            }),
          _buildMenuItem(Icons.settings, tr('settings', selectedLanguage), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  selectedCountry: selectedCountry,
                  onCountryChanged: onCountryChanged,
                ),
              ),
            );
          }),
          if (isLoggedIn && isLegalEntity)
            _buildMenuItem(Icons.leaderboard, tr('competitorRates', selectedLanguage), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompetitorRatesScreen(aiuBankRates: aiuBankRates),
                ),
              );
            }),
          if (isLoggedIn && isLegalEntity)
            _buildMenuItem(Icons.store, tr('myExchanger', selectedLanguage), () {
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
            _buildMenuItem(Icons.history, tr('rateHistory', selectedLanguage), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RateHistoryScreen(history: rateHistory),
                ),
              );
            }),
          if (isLoggedIn && isLegalEntity)
            _buildMenuItem(Icons.sell, tr('mySales', selectedLanguage), () {}),
          if (isLoggedIn && isLegalEntity)
            _buildMenuItem(Icons.warning_amber_rounded, tr('riskNotifications', selectedLanguage), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RiskNotificationsScreen(alerts: riskAlerts),
                ),
              );
            }),
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
                isLoggedIn ? tr('logout', selectedLanguage) : tr('login', selectedLanguage),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 28, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }
}
