import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hisobla/features/presentation/pages/analysis_page.dart';
import 'package:hisobla/features/presentation/pages/analysis_history_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _openTelegramChannel(BuildContext context) async {
    final url = Uri.parse('https://t.me/only_flutter');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showSnackBar(context, 'Telegram kanalini ochib bo\'lmadi');
    }
  }

  Future<void> _sendEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'asdibroxim@gmail.com',
      queryParameters: {'subject': 'Hisobla ilovasi haqida'},
    );
    if (!await launchUrl(emailUri)) {
      _showSnackBar(context, 'Email ilovasini ochib bo\'lmadi');
    }
  }

  void _shareApp() {
    Share.share(
      'Hisobla – oson byudjet boshqaruvi ilovasi!\n'
      'Play Market: https://play.google.com/store/apps/details?id=uz.ibroxim_ku.hisobla\n'
      'Flutter bilan yaratilgan, tez va qulay!',
      subject: 'Hisobla ilovasini sinab ko\'ring!',
    );
  }

  void _openPrivacyPolicy(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()));
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey.shade900 : Colors.grey.shade50;
    final cardColor = isDark ? Colors.grey.shade800 : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Sozlamalar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDeveloperCard(context, cardColor),
          const SizedBox(height: 24),

          // AI Tahlillar bo'limi
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'AI Tahlillar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          _buildActionCard(
            context,
            icon: Icons.analytics,
            color: Colors.purple,
            title: 'Kunlik tahlil',
            subtitle: 'Bugungi xarajatlar tahlili',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalysisPage()),
              );
            },
            cardColor: cardColor,
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            context,
            icon: Icons.history,
            color: Colors.indigo,
            title: 'AI Tahlillar tarixi',
            subtitle: 'Barcha tahlillarni ko\'rish va qidirish',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalysisHistoryPage()),
              );
            },
            cardColor: cardColor,
          ),
          const SizedBox(height: 24),

          // Boshqalar bo'limi
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Boshqalar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          _buildActionCard(
            context,
            icon: Icons.telegram,
            color: const Color(0xFF0088CC),
            title: 'Flutter yangiliklari',
            subtitle: '@only_flutter – eng so\'nggi yangiliklar',
            onTap: () => _openTelegramChannel(context),
            cardColor: cardColor,
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            context,
            icon: Icons.email,
            color: Colors.green,
            title: 'Bog\'lanish',
            subtitle: 'asdibroxim@gmail.com',
            onTap: () => _sendEmail(context),
            cardColor: cardColor,
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            context,
            icon: Icons.share,
            color: Colors.orange,
            title: 'Ilovani ulashish',
            subtitle: 'Do\'stlaringizga tavsiya qiling',
            onTap: _shareApp,
            cardColor: cardColor,
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            context,
            icon: Icons.privacy_tip,
            color: Colors.purple,
            title: 'Maxfiylik siyosati',
            subtitle: 'Ma\'lumotlar qanday himoyalanadi',
            onTap: () => _openPrivacyPolicy(context),
            cardColor: cardColor,
          ),

          const SizedBox(height: 32),

          Center(
            child: Column(
              children: [
                Text(
                  'Hisobla',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2025 Ibroxim Umaraliyev',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard(BuildContext context, Color cardColor) {
    return Card(
      color: cardColor,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showAboutDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.code, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ibroxim Umaraliyev',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Flutter Developer',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'Hisobla muallifi',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color cardColor,
  }) {
    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.3), width: 1.5),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.calculate, color: Colors.blue, size: 32),
            SizedBox(width: 12),
            Text('Hisobla', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Salom! Men Ibroxim Umaraliyev – Flutter developer.\n\n'
          'Bu ilova sizga oylik byudjetingizni oson boshqarishga yordam beradi.\n\n'
          'Flutter yangiliklaridan boxabar bo\'lish uchun @only_flutter kanaliga obuna bo\'ling!\n\n'
          'Fikr va takliflaringizni asdibroxim@gmail.com ga yuboring.\n\n'
          'Rahmat ilovamizdan foydalanganingiz uchun!',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yopish', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maxfiylik siyosati'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade900],
            ),
          ),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maxfiylik siyosati',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Oxirgi yangilanish: 03.11.2025',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 20),
            _PolicySection(
              title: '1. Yig\'iladigan ma\'lumotlar',
              content:
                  'Hisobla ilovasi foydalanuvchidan hech qanday shaxsiy ma\'lumot yig\'maydi. '
                  'Barcha ma\'lumotlar faqat qurilmangizda saqlanadi.',
            ),
            _PolicySection(
              title: '2. AI Tahlil',
              content:
                  'Xarajatlar tahlili uchun Google Gemini AI dan foydalanamiz. '
                  'Faqat xarajat summasi va tavsifi yuboriladi, shaxsiy ma\'lumotlar yuborilmaydi.',
            ),
            _PolicySection(
              title: '3. Tahlillar tarixi',
              content:
                  'AI tahlillari qurilmangizda local saqlanadi. '
                  'Siz istalgan vaqt tahlillarni ko\'rish, qidirish yoki o\'chirish huquqiga egasiz.',
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;
  const _PolicySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 15, height: 1.6)),
        ],
      ),
    );
  }
}
