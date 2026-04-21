import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_background.dart';

class NearbyExchanger {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String usdBuy;
  final String usdSell;
  final String eurBuy;
  final String eurSell;
  final String workingHours;
  final bool isOpen;

  const NearbyExchanger({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.usdBuy,
    required this.usdSell,
    required this.eurBuy,
    required this.eurSell,
    required this.workingHours,
    required this.isOpen,
  });
}

const _mockExchangers = [
  NearbyExchanger(
    name: 'Halyk Bank',
    address: 'пр. Туран 24, Астана',
    lat: 51.1694,
    lng: 71.4491,
    usdBuy: '479', usdSell: '485',
    eurBuy: '558', eurSell: '566',
    workingHours: '09:00 – 18:00',
    isOpen: true,
  ),
  NearbyExchanger(
    name: 'Kaspi Bank',
    address: 'пр. Кабанбай батыра 11, Астана',
    lat: 51.1801,
    lng: 71.4460,
    usdBuy: '477', usdSell: '487',
    eurBuy: '555', eurSell: '568',
    workingHours: '09:00 – 20:00',
    isOpen: true,
  ),
  NearbyExchanger(
    name: 'ForteBank',
    address: 'ул. Сыганак 14, Астана',
    lat: 51.1750,
    lng: 71.4150,
    usdBuy: '476', usdSell: '486',
    eurBuy: '554', eurSell: '565',
    workingHours: '09:00 – 17:00',
    isOpen: false,
  ),
  NearbyExchanger(
    name: 'BCC Bank',
    address: 'пр. Республики 13, Астана',
    lat: 51.1801,
    lng: 71.4460,
    usdBuy: '480', usdSell: '488',
    eurBuy: '560', eurSell: '570',
    workingHours: '08:00 – 21:00',
    isOpen: true,
  ),
  NearbyExchanger(
    name: 'Jusan Bank',
    address: 'ул. Достык 13, Астана',
    lat: 51.1720,
    lng: 71.4655,
    usdBuy: '478', usdSell: '486',
    eurBuy: '556', eurSell: '567',
    workingHours: '09:00 – 19:00',
    isOpen: true,
  ),
  NearbyExchanger(
    name: 'Bereke Bank',
    address: 'пр. Мәңгілік Ел 55, Астана',
    lat: 51.0908,
    lng: 71.4183,
    usdBuy: '478', usdSell: '487',
    eurBuy: '557', eurSell: '566',
    workingHours: '09:00 – 18:00',
    isOpen: true,
  ),
  NearbyExchanger(
    name: 'Евразийский банк',
    address: 'ул. Бейбітшілік 18, Астана',
    lat: 51.1804,
    lng: 71.4459,
    usdBuy: '479', usdSell: '486',
    eurBuy: '558', eurSell: '567',
    workingHours: '09:00 – 18:00',
    isOpen: false,
  ),
];

class NearbyExchangersScreen extends StatefulWidget {
  final String selectedLanguage;

  const NearbyExchangersScreen({super.key, required this.selectedLanguage});

  @override
  State<NearbyExchangersScreen> createState() => _NearbyExchangersScreenState();
}

class _NearbyExchangersScreenState extends State<NearbyExchangersScreen> {
  Position? _position;
  bool _loading = true;
  String? _error;
  String _sortBy = 'distance';
  bool _onlyOpen = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() { _loading = true; _error = null; });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { _error = 'Геолокация отключена'; _loading = false; });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        setState(() { _error = 'Нет разрешения на геолокацию'; _loading = false; });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() { _position = pos; _loading = false; });
    } catch (e) {
      // На вебе геолокация может не работать — показываем без расстояния
      setState(() { _loading = false; });
    }
  }

  double? _getDistance(NearbyExchanger ex) {
    if (_position == null) return null;
    return Geolocator.distanceBetween(
      _position!.latitude, _position!.longitude,
      ex.lat, ex.lng,
    ) / 1000;
  }

  List<NearbyExchanger> get _sorted {
    var list = List<NearbyExchanger>.from(_mockExchangers);
    if (_onlyOpen) list = list.where((e) => e.isOpen).toList();
    if (_sortBy == 'distance' && _position != null) {
      list.sort((a, b) => (_getDistance(a) ?? 999).compareTo(_getDistance(b) ?? 999));
    } else if (_sortBy == 'usdBuy') {
      list.sort((a, b) => int.parse(b.usdBuy).compareTo(int.parse(a.usdBuy)));
    } else if (_sortBy == 'usdSell') {
      list.sort((a, b) => int.parse(a.usdSell).compareTo(int.parse(b.usdSell)));
    }
    return list;
  }

  void _openInMaps(NearbyExchanger ex) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${ex.lat},${ex.lng}');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Ближайшие обменники'),
          actions: [
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _getLocation,
              tooltip: 'Обновить геолокацию',
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSortBar(),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(child: _buildError())
            else
              Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSortBar() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              _sortChip('distance', '📍 Рядом'),
              _sortChip('usdBuy', '💰 Выгодно купить'),
              _sortChip('usdSell', '💸 Выгодно продать'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _onlyOpen = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: !_onlyOpen
                        ? const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)])
                        : null,
                    color: _onlyOpen ? Colors.white.withValues(alpha: 0.08) : null,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Text('Все', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: !_onlyOpen ? Colors.white : Colors.white54)),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _onlyOpen = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _onlyOpen ? Colors.green.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _onlyOpen ? Colors.greenAccent : Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('Открыто сейчас', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _onlyOpen ? Colors.greenAccent : Colors.white54)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sortChip(String value, String label) {
    final isActive = _sortBy == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _sortBy = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)])
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 64, color: Colors.white38),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _getLocation, child: const Text('Повторить')),
        ],
      ),
    );
  }

  Widget _buildList() {
    final list = _sorted;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, i) => _buildCard(list[i]),
    );
  }

  Widget _buildCard(NearbyExchanger ex) {
    final dist = _getDistance(ex);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          // Заголовок
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance, color: Colors.white70, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ex.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(ex.address, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: ex.isOpen ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ex.isOpen ? 'Открыто' : 'Закрыто',
                        style: TextStyle(fontSize: 11, color: ex.isOpen ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (dist != null) ...[
                      const SizedBox(height: 4),
                      Text('${dist.toStringAsFixed(1)} км', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Курсы
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _rateCell('USD купить', ex.usdBuy, Colors.greenAccent),
                _divider(),
                _rateCell('USD продать', ex.usdSell, Colors.redAccent),
                _divider(),
                _rateCell('EUR купить', ex.eurBuy, Colors.greenAccent),
                _divider(),
                _rateCell('EUR продать', ex.eurSell, Colors.redAccent),
              ],
            ),
          ),
          // Нижняя строка
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.white38),
                const SizedBox(width: 4),
                Text(ex.workingHours, style: const TextStyle(fontSize: 12, color: Colors.white38)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _openInMaps(ex),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_outlined, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text('На карте', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rateCell(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.white38), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.1));
}
