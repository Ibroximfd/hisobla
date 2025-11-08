import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hisobla/features/domain/entities/expense.dart';

class AIAnalysisService {
  static const String _apiKey = 'AIzaSyAJgCUFoKlUZdhh4ARZ6Kd1fOzf8mCxUos';
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  Future<Map<String, dynamic>> analyzeExpenses(
    List<Expense> todayExpenses,
    List<Expense> allExpenses,
    double budget,
    double remaining,
  ) async {
    try {
      final todayTotal = todayExpenses.fold<double>(
        0,
        (sum, e) => sum + e.amount,
      );
      final todayCount = todayExpenses.length;

      final categories = _categorizeExpenses(todayExpenses);
      final categoriesText = categories.entries
          .map((e) => '${e.key}: ${e.value.toStringAsFixed(0)} so\'m')
          .join(', ');

      // Har bir xarajatni batafsil ro'yxati
      final expenseDetails = todayExpenses
          .map((e) => '${e.description}: ${e.amount.toStringAsFixed(0)} so\'m')
          .join(', ');

      final prompt =
          '''
Sen professional moliyaviy maslahatchi sun. Foydalanuvchining bugungi xarajatlarini chuqur tahlil qilib, o'zbek tilida ANIQ va FOYDALI maslahat ber.

BUGUNGI XARAJATLAR RO'YHATI:
$expenseDetails

UMUMIY MA'LUMOTLAR:
- Bugungi jami: ${todayTotal.toStringAsFixed(0)} so'm
- Xarajatlar soni: $todayCount ta
- Oylik byudjet: ${budget.toStringAsFixed(0)} so'm
- Qolgan byudjet: ${remaining.toStringAsFixed(0)} so'm
- Kategoriyalar: $categoriesText

VAZIFA:
1. Baholash: "yaxshi", "o'rtacha", "ogohlantirish" yoki "xavfli"
2. Keraksiz xarajatlarni aniq aniqlash (aniq summa bilan)
3. 3-4 ta ANIQ va SHAXSIY maslahat (har bir xarajatga qarab)
4. Qaysi kategoriyalarga kam pul sarflash kerakligini ko'rsatish
5. YANGI va ILHOMLOVCHI motivatsiya gap (har safar boshqacha)
6. Umumiy xulosa

JAVOB FORMATI (faqat JSON):
{
  "rating": "yaxshi",
  "unnecessaryExpenses": [
    {"description": "xarajat nomi", "amount": 50000, "reason": "nima uchun keraksiz"}
  ],
  "unnecessaryTotal": 50000,
  "advice": [
    "aniq maslahat 1 (xarajatga qarab)",
    "aniq maslahat 2",
    "aniq maslahat 3"
  ],
  "reduceCategories": [
    {"category": "kategoriya nomi", "suggestion": "qanday kamaytirish kerak"}
  ],
  "motivation": "har safar yangi motivatsiya gap",
  "summary": "umumiy xulosa"
}

MUHIM QOIDALAR:
- Har bir keraksiz xarajatni ANIQ ko'rsating (nomi va summasi bilan)
- Maslahatlar umumiy emas, ANIQ va SHAXSIY bo'lsin
- Motivatsiya har safar BOSHQACHA bo'lsin (takrorlanmasin)
- Agar keraksiz xarajat yo'q bo'lsa, unnecessaryExpenses bo'sh array bo'lsin
- Faqat JSON javob ber, boshqa hech narsa yozma!
''';

      final response = await http
          .post(
            Uri.parse('$_apiUrl?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
              'generationConfig': {
                'temperature': 0.9, // Har safar yangi javob uchun
                'topK': 40,
                'topP': 0.95,
                'maxOutputTokens': 2048,
              },
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);

        if (jsonMatch != null) {
          final aiResponse = jsonDecode(jsonMatch.group(0)!);
          return {
            'rating': aiResponse['rating'] ?? 'o\'rtacha',
            'unnecessaryExpenses': aiResponse['unnecessaryExpenses'] ?? [],
            'unnecessaryTotal': (aiResponse['unnecessaryTotal'] ?? 0)
                .toDouble(),
            'advice': List<String>.from(aiResponse['advice'] ?? []),
            'reduceCategories': aiResponse['reduceCategories'] ?? [],
            'motivation': aiResponse['motivation'] ?? _getRandomMotivation(),
            'summary': aiResponse['summary'] ?? '',
            'todayTotal': todayTotal,
            'todayCount': todayCount,
            'categories': categories,
          };
        }
      }

      return _getDefaultAnalysis(
        todayTotal,
        todayCount,
        categories,
        budget,
        remaining,
        todayExpenses,
      );
    } catch (e) {
      print('AI xatolik: $e');
      return _getDefaultAnalysis(
        todayExpenses.fold<double>(0, (sum, e) => sum + e.amount),
        todayExpenses.length,
        _categorizeExpenses(todayExpenses),
        budget,
        remaining,
        todayExpenses,
      );
    }
  }

  Map<String, double> _categorizeExpenses(List<Expense> expenses) {
    final categories = <String, double>{};
    for (var e in expenses) {
      final desc = e.description.toLowerCase();
      String category = '🛒 Boshqa';

      if (desc.contains('ovqat') ||
          desc.contains('taom') ||
          desc.contains('restoran') ||
          desc.contains('osh') ||
          desc.contains('non') ||
          desc.contains('fast food') ||
          desc.contains('kafe')) {
        category = '🍽️ Ovqat';
      } else if (desc.contains('transport') ||
          desc.contains('taksi') ||
          desc.contains('benzin') ||
          desc.contains('avtobus') ||
          desc.contains('metro') ||
          desc.contains('yoqilg\'i')) {
        category = '🚗 Transport';
      } else if (desc.contains('kiyim') ||
          desc.contains('ayiq') ||
          desc.contains('poyabzal') ||
          desc.contains('forma') ||
          desc.contains('moda')) {
        category = '👔 Kiyim';
      } else if (desc.contains('o\'yin') ||
          desc.contains('kino') ||
          desc.contains('dam olish') ||
          desc.contains('sayohat') ||
          desc.contains('o\'yin-kulgi') ||
          desc.contains('ko\'ngilochar')) {
        category = '🎮 Dam olish';
      } else if (desc.contains('telefon') ||
          desc.contains('internet') ||
          desc.contains('kompyuter') ||
          desc.contains('elektron') ||
          desc.contains('gadjet')) {
        category = '📱 Texnologiya';
      } else if (desc.contains('kommunal') ||
          desc.contains('tok') ||
          desc.contains('gaz') ||
          desc.contains('suv') ||
          desc.contains('uy-joy')) {
        category = '🏠 Kommunal';
      }

      categories[category] = (categories[category] ?? 0) + e.amount;
    }
    return categories;
  }

  String _getRandomMotivation() {
    final motivations = [
      'Har bir tejagan pul - kelajak uchun investitsiya! 💪',
      'Bugun tejasangiz, ertaga o\'zingiz uchun ishlaydi! 🚀',
      'Kichik tejashlar katta maqsadlarga olib boradi! ⭐',
      'Moliyaviy erkinlik tejashdan boshlanadi! 🎯',
      'Siz zo\'r ish qilyapsiz, davom eting! 🔥',
      'Har bir to\'g\'ri qaror kelajakni yaxshilaydi! 💎',
    ];
    return motivations[DateTime.now().millisecond % motivations.length];
  }

  Map<String, dynamic> _getDefaultAnalysis(
    double todayTotal,
    int todayCount,
    Map<String, double> categories,
    double budget,
    double remaining,
    List<Expense> expenses,
  ) {
    String rating = 'o\'rtacha';
    List<String> advice = [];
    List<Map<String, dynamic>> unnecessaryExpenses = [];
    double unnecessaryTotal = 0;

    final percentage = budget > 0 ? (todayTotal / budget) * 100 : 0;

    // Keraksiz xarajatlarni aniqlash (sodda logika)
    for (var expense in expenses) {
      if (expense.amount > 50000 &&
          (expense.description.toLowerCase().contains('o\'yin') ||
              expense.description.toLowerCase().contains('kino') ||
              expense.description.toLowerCase().contains('restoran'))) {
        unnecessaryExpenses.add({
          'description': expense.description,
          'amount': expense.amount,
          'reason': 'Bu xarajatni kamaytirsangiz yaxshi bo\'lardi',
        });
        unnecessaryTotal += expense.amount;
      }
    }

    if (percentage < 3) {
      rating = 'yaxshi';
      advice = [
        'Ajoyib! Bugun juda kam xarajat qildingiz',
        'Bu yo\'lda davom etsangiz, oylik maqsadga erishasiz',
        'Tejash mahoratingiz zo\'r darajada',
      ];
    } else if (percentage < 5) {
      rating = 'o\'rtacha';
      advice = [
        'Yaxshi natija, lekin yanada tejash mumkin',
        'Keraksiz xarajatlarni aniqlab, kamaytirishga harakat qiling',
        'Kunlik rejalashtirish muhim',
      ];
    } else if (percentage < 8) {
      rating = 'ogohlantirish';
      advice = [
        'Bugun ko\'p xarajat qildingiz, ehtiyot bo\'ling',
        'Ertadan rejalashtirgan holda pul sarflang',
        'Byudjetni qat\'iy nazorat qiling',
      ];
    } else {
      rating = 'xavfli';
      advice = [
        'DIQQAT! Juda ko\'p xarajat qildingiz',
        'Zudlik bilan tejash rejasini boshlang',
        'Faqat zarur xarajatlarni qiling',
      ];
    }

    return {
      'rating': rating,
      'unnecessaryExpenses': unnecessaryExpenses,
      'unnecessaryTotal': unnecessaryTotal,
      'advice': advice,
      'reduceCategories': [],
      'motivation': _getRandomMotivation(),
      'summary':
          'Bugun $todayCount ta xarajat, jami ${todayTotal.toStringAsFixed(0)} so\'m',
      'todayTotal': todayTotal,
      'todayCount': todayCount,
      'categories': categories,
    };
  }
}
