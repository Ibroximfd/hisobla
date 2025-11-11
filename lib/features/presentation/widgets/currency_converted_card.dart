// currency_converter_card.dart
// Bu widgetni alohida faylga chiqaring yoki settings_page.dart oxiriga qo'shing

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyConverterCard extends StatefulWidget {
  final Color cardColor;
  const CurrencyConverterCard({super.key, required this.cardColor});

  @override
  State<CurrencyConverterCard> createState() => _CurrencyConverterCardState();
}

class _CurrencyConverterCardState extends State<CurrencyConverterCard> {
  Map<String, double> rates = {};
  bool isLoading = true;
  String? errorMessage;
  DateTime? lastUpdated;

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // CBU API dan kurslarni olish
      final response = await http.get(
        Uri.parse('https://cbu.uz/uz/arkhiv-kursov-valyut/json/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final usdData = data.firstWhere((item) => item['Ccy'] == 'USD');
        final rubData = data.firstWhere((item) => item['Ccy'] == 'RUB');
        final cnyData = data.firstWhere((item) => item['Ccy'] == 'CNY');

        setState(() {
          rates = {
            'USD': double.parse(usdData['Rate']),
            'RUB': double.parse(rubData['Rate']),
            'CNY': double.parse(cnyData['Rate']),
          };
          lastUpdated = DateTime.now();
          isLoading = false;
        });
      } else {
        throw Exception('Ma\'lumot yuklanmadi');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Internetga ulanishda xatolik';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.currency_exchange,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Valyuta kurslari',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (lastUpdated != null)
                        Text(
                          'Yangilangan: ${_formatTime(lastUpdated!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.green.shade700),
                  onPressed: isLoading ? null : _fetchRates,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage != null)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade400,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _fetchRates,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  _buildCurrencyRow(
                    'USD',
                    '🇺🇸',
                    'Dollar',
                    rates['USD']!,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildCurrencyRow(
                    'RUB',
                    '🇷🇺',
                    'Rubl',
                    rates['RUB']!,
                    Colors.red,
                  ),
                  const SizedBox(height: 12),
                  _buildCurrencyRow(
                    'CNY',
                    '🇨🇳',
                    "Yuan",
                    rates['CNY']!,
                    Colors.redAccent,
                  ),
                ],
              ),
            if (!isLoading && errorMessage == null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Markaziy Bank kurslari',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyRow(
    String code,
    String flag,
    String name,
    double rate,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(flag, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  name,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatNumber(rate),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'CNY',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number == 1.0) return '1.00';
    return number
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Hozir';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} daqiqa oldin';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} soat oldin';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
