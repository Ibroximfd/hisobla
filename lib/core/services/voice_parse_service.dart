class VoiceParserService {
  // Ovozli matndan summa va tavsifni ajratib olish
  static Map<String, dynamic> parseVoiceText(String text) {
    try {
      final cleanText = text.toLowerCase().trim();

      // Summani topish
      double? amount = _extractAmount(cleanText);

      // Tavsifni topish (summadan oldingi qism)
      String description = _extractDescription(cleanText, amount);

      return {
        'amount': amount,
        'description': description,
        'originalText': text,
        'success': amount != null && amount > 0,
      };
    } catch (e) {
      print('❌ Parse error: $e');
      return {
        'amount': null,
        'description': '',
        'originalText': text,
        'success': false,
      };
    }
  }

  static double? _extractAmount(String text) {
    // So'm, sum, ruble yoki boshqa pul birliklari
    final patterns = [
      // "5000 so'm" yoki "5000 sum"
      RegExp(
        r"(\d+(?:\s?\d+)*)\s*(?:so\'?m|sum|rubl|dollar)",
        caseSensitive: false,
      ),
      // "5 ming", "10 ming", "100 ming"
      RegExp(r'(\d+)\s*(?:ming)', caseSensitive: false),
      // "5 million"
      RegExp(r'(\d+)\s*(?:million)', caseSensitive: false),
      // Faqat raqamlar (oxirida)
      RegExp(r'(\d+(?:\s?\d+)*)$'),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String numberStr = match.group(1)!.replaceAll(' ', '');
        double? number = double.tryParse(numberStr);

        if (number != null) {
          // "ming" bo'lsa, 1000 ga ko'paytirish
          if (text.contains('ming')) {
            number *= 1000;
          }
          // "million" bo'lsa, 1000000 ga ko'paytirish
          if (text.contains('million')) {
            number *= 1000000;
          }

          return number;
        }
      }
    }

    return null;
  }

  static String _extractDescription(String text, double? amount) {
    if (amount == null) return text;

    // Summani olib tashlash
    String description = text
        .replaceAll(RegExp(r'\d+(?:\s?\d+)*'), '')
        .replaceAll(
          RegExp(r"so\'?m|sum|rubl|dollar|ming|million", caseSensitive: false),
          '',
        )
        .trim();

    // "ga", "uchun", "dan", "sarfladim" kabi so'zlarni tozalash
    description = description
        .replaceAll(
          RegExp(
            r'\b(ga|uchun|dan|sarfladim|oldim|sotib oldim)\b',
            caseSensitive: false,
          ),
          '',
        )
        .trim();

    // Bo'sh bo'lsa, default qiymat
    if (description.isEmpty) {
      description = 'Ovozli xarajat';
    }

    // Birinchi harfni katta qilish
    if (description.isNotEmpty) {
      description = description[0].toUpperCase() + description.substring(1);
    }

    return description;
  }

  // Test funksiyasi
  static void test() {
    final testCases = [
      "nonga 5200 so'm sarfladim",
      "transport uchun 10 ming sum",
      "ovqat 15000",
      "kino 20 ming",
      "taksi 8000 so'm",
      "restoranga 50000 sum",
    ];

    print('🧪 Voice Parser Test:');
    for (var testCase in testCases) {
      final result = parseVoiceText(testCase);
      print('Input: "$testCase"');
      print('  Amount: ${result['amount']}');
      print('  Description: ${result['description']}');
      print('  Success: ${result['success']}\n');
    }
  }
}
