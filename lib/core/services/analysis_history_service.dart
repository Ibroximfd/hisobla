import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AnalysisHistoryService {
  static const String _historyKey = 'analysis_history';

  // Tahlilni saqlash
  Future<void> saveAnalysis(
    DateTime date,
    Map<String, dynamic> analysis,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      // Sana string formatda (YYYY-MM-DD)
      final dateKey = _formatDate(date);

      // Tahlilga sana qo'shamiz
      analysis['savedDate'] = dateKey;
      analysis['timestamp'] = date.millisecondsSinceEpoch;

      // Tahlilni qo'shamiz yoki yangilaymiz
      history[dateKey] = analysis;

      // Saqlash
      await prefs.setString(_historyKey, jsonEncode(history));
      print('✅ Tahlil saqlandi: $dateKey');
    } catch (e) {
      print('❌ Tahlil saqlanmadi: $e');
    }
  }

  // Barcha tahlillar tarixi
  Future<Map<String, dynamic>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);

      if (historyJson == null || historyJson.isEmpty) {
        return {};
      }

      return Map<String, dynamic>.from(jsonDecode(historyJson));
    } catch (e) {
      print('❌ Tarix yuklanmadi: $e');
      return {};
    }
  }

  // Muayyan sanadagi tahlil
  Future<Map<String, dynamic>?> getAnalysisByDate(DateTime date) async {
    try {
      final history = await getHistory();
      final dateKey = _formatDate(date);
      return history[dateKey];
    } catch (e) {
      print('❌ Tahlil topilmadi: $e');
      return null;
    }
  }

  // Tahlillarni qidirish (moslashuvchan)
  Future<List<Map<String, dynamic>>> searchAnalysis(String query) async {
    try {
      final history = await getHistory();
      final results = <Map<String, dynamic>>[];

      // Query ni tozalash va kichik harflarga
      final cleanQuery = query.toLowerCase().trim();

      // Turli formatlarni sinash
      final possibleDates = _parseDateQuery(cleanQuery);

      for (var entry in history.entries) {
        final analysis = Map<String, dynamic>.from(entry.value);
        final savedDate = entry.key;

        // Sana bo'yicha qidirish
        for (var possibleDate in possibleDates) {
          if (savedDate == possibleDate) {
            results.add(analysis);
            break;
          }
        }

        // Agar aniq sana bo'lmasa, matn bo'yicha qidirish
        if (results.isEmpty) {
          if (savedDate.contains(cleanQuery) ||
              _getMonthName(
                _parseDate(savedDate),
              ).toLowerCase().contains(cleanQuery) ||
              analysis['summary']?.toString().toLowerCase().contains(
                    cleanQuery,
                  ) ==
                  true) {
            results.add(analysis);
          }
        }
      }

      // Sana bo'yicha tartiblash (yangilari birinchi)
      results.sort((a, b) {
        final timestampA = a['timestamp'] ?? 0;
        final timestampB = b['timestamp'] ?? 0;
        return timestampB.compareTo(timestampA);
      });

      return results;
    } catch (e) {
      print('❌ Qidiruv xatosi: $e');
      return [];
    }
  }

  // Barcha tahlillar (yangilari birinchi)
  Future<List<Map<String, dynamic>>> getAllAnalysisSorted() async {
    try {
      final history = await getHistory();
      final analyses = <Map<String, dynamic>>[];

      for (var entry in history.entries) {
        final analysis = Map<String, dynamic>.from(entry.value);
        analyses.add(analysis);
      }

      // Sana bo'yicha tartiblash
      analyses.sort((a, b) {
        final timestampA = a['timestamp'] ?? 0;
        final timestampB = b['timestamp'] ?? 0;
        return timestampB.compareTo(timestampA);
      });

      return analyses;
    } catch (e) {
      print('❌ Tahlillar yuklanmadi: $e');
      return [];
    }
  }

  // Tahlilni o'chirish
  Future<void> deleteAnalysis(String dateKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();
      history.remove(dateKey);
      await prefs.setString(_historyKey, jsonEncode(history));
      print('✅ Tahlil o\'chirildi: $dateKey');
    } catch (e) {
      print('❌ O\'chirishda xato: $e');
    }
  }

  // Barcha tahlillarni o'chirish
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      print('✅ Barcha tahlillar o\'chirildi');
    } catch (e) {
      print('❌ Tozalashda xato: $e');
    }
  }

  // Sana formatini YYYY-MM-DD ga o'zgartirish
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // String dan DateTime ga
  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  // Query dan turli sana formatlarini olish
  List<String> _parseDateQuery(String query) {
    final dates = <String>[];

    try {
      // Raqamlarni ajratib olish
      final numbers = RegExp(
        r'\d+',
      ).allMatches(query).map((m) => m.group(0)!).toList();

      if (numbers.isEmpty) return dates;

      final now = DateTime.now();

      // Format: DD MM YYYY yoki DD-MM-YYYY yoki DD.MM.YYYY yoki DD/MM/YYYY
      if (numbers.length >= 2) {
        final day = int.tryParse(numbers[0]);
        final month = int.tryParse(numbers[1]);
        final year = numbers.length >= 3 ? int.tryParse(numbers[2]) : now.year;

        if (day != null && month != null && year != null) {
          // To'liq yil (2025) yoki qisqa yil (25)
          final fullYear = year < 100 ? 2000 + year : year;

          if (day >= 1 && day <= 31 && month >= 1 && month <= 12) {
            dates.add(_formatDate(DateTime(fullYear, month, day)));
          }
        }
      }

      // Format: Faqat kun (joriy oy va yil)
      if (numbers.length == 1) {
        final day = int.tryParse(numbers[0]);
        if (day != null && day >= 1 && day <= 31) {
          dates.add(_formatDate(DateTime(now.year, now.month, day)));
        }
      }

      // Oy nomini qidirish
      final monthNumber = _getMonthNumber(query);
      if (monthNumber != null) {
        // Agar kun ham bo'lsa
        if (numbers.isNotEmpty) {
          final day = int.tryParse(numbers[0]);
          if (day != null && day >= 1 && day <= 31) {
            final year = numbers.length >= 2
                ? int.tryParse(numbers[1])
                : now.year;
            dates.add(
              _formatDate(DateTime(year ?? now.year, monthNumber, day)),
            );
          }
        }
      }
    } catch (e) {
      print('❌ Sana parse xatosi: $e');
    }

    return dates;
  }

  // Oy nomini olish
  String _getMonthName(DateTime date) {
    const months = [
      'yanvar',
      'fevral',
      'mart',
      'aprel',
      'may',
      'iyun',
      'iyul',
      'avgust',
      'sentabr',
      'oktabr',
      'noyabr',
      'dekabr',
    ];
    return months[date.month - 1];
  }

  // Oy nomidan raqamga
  int? _getMonthNumber(String query) {
    const months = {
      'yanvar': 1,
      'yan': 1,
      'fevral': 2,
      'fev': 2,
      'mart': 3,
      'mar': 3,
      'aprel': 4,
      'apr': 4,
      'may': 5,
      'iyun': 6,
      'iyul': 7,
      'avgust': 8,
      'avg': 8,
      'sentabr': 9,
      'sen': 9,
      'oktabr': 10,
      'okt': 10,
      'noyabr': 11,
      'noy': 11,
      'dekabr': 12,
      'dek': 12,
    };

    for (var entry in months.entries) {
      if (query.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }
}
