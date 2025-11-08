import 'package:flutter/material.dart';
import 'package:hisobla/core/services/analysis_history_service.dart';
import 'package:hisobla/features/presentation/pages/analysis_detail_page.dart';
import 'package:intl/intl.dart';

class AnalysisHistoryPage extends StatefulWidget {
  const AnalysisHistoryPage({super.key});

  @override
  State<AnalysisHistoryPage> createState() => _AnalysisHistoryPageState();
}

class _AnalysisHistoryPageState extends State<AnalysisHistoryPage> {
  final AnalysisHistoryService _historyService = AnalysisHistoryService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _analyses = [];
  List<Map<String, dynamic>> _filteredAnalyses = [];
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadAnalyses();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyses() async {
    setState(() => _isLoading = true);

    final analyses = await _historyService.getAllAnalysisSorted();

    if (mounted) {
      setState(() {
        _analyses = analyses;
        _filteredAnalyses = analyses;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _filteredAnalyses = _analyses;
        _isSearching = false;
      });
    } else {
      setState(() => _isSearching = true);
      _performSearch(query);
    }
  }

  Future<void> _performSearch(String query) async {
    final results = await _historyService.searchAnalysis(query);

    if (mounted) {
      setState(() {
        _filteredAnalyses = results;
        _isSearching = false;
      });
    }
  }

  Future<void> _deleteAnalysis(String dateKey, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('O\'chirish'),
          ],
        ),
        content: const Text(
          'Bu tahlilni o\'chirishni xohlaysizmi?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Yo\'q'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.deleteAnalysis(dateKey);
      await _loadAnalyses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Tahlil o\'chirildi'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _clearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Barcha tahlillarni o\'chirish'),
          ],
        ),
        content: const Text(
          'Bu barcha tahlil tarixini o\'chirib yuboradi. Davom etasizmi?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Yo\'q'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.clearHistory();
      await _loadAnalyses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Barcha tahlillar o\'chirildi'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  String _formatDate(String dateKey) {
    try {
      final parts = dateKey.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return DateFormat('dd MMMM yyyy', 'uz').format(date);
    } catch (e) {
      return dateKey;
    }
  }

  String _getDateDifference(String dateKey) {
    try {
      final parts = dateKey.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final difference = today.difference(date).inDays;

      if (difference == 0) return 'Bugun';
      if (difference == 1) return 'Kecha';
      if (difference < 7) return '$difference kun oldin';
      if (difference < 30) return '${(difference / 7).floor()} hafta oldin';
      if (difference < 365) return '${(difference / 30).floor()} oy oldin';
      return '${(difference / 365).floor()} yil oldin';
    } catch (e) {
      return '';
    }
  }

  Color _getRatingColor(String rating) {
    switch (rating) {
      case 'yaxshi':
        return Colors.green;
      case 'xavfli':
        return Colors.red.shade700;
      case 'ogohlantirish':
        return Colors.orange.shade700;
      default:
        return Colors.blue;
    }
  }

  String _getRatingEmoji(String rating) {
    switch (rating) {
      case 'yaxshi':
        return '🎉';
      case 'xavfli':
        return '⚠️';
      case 'ogohlantirish':
        return '⚠️';
      default:
        return '👍';
    }
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'AI Tahlillar tarixi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
        actions: [
          if (_analyses.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllHistory,
              tooltip: 'Barchasini o\'chirish',
            ),
        ],
      ),
      body: Column(
        children: [
          // Qidiruv qismi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Sanani kiriting (5 noyabr 2025, 05.11.2025...)',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Natijalar
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _filteredAnalyses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchController.text.isEmpty
                              ? Icons.history
                              : Icons.search_off,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Hali tahlil yo\'q'
                              : 'Tahlil topilmadi',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Birinchi tahlilni yaratish uchun\nxarajat qo\'shing'
                              : 'Boshqa sana bilan harakat qilib ko\'ring',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadAnalyses,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredAnalyses.length,
                      itemBuilder: (context, index) {
                        final analysis = _filteredAnalyses[index];
                        final dateKey = analysis['savedDate'] ?? '';
                        final rating = analysis['rating'] ?? 'o\'rtacha';
                        final todayTotal = (analysis['todayTotal'] ?? 0)
                            .toDouble();
                        final todayCount = analysis['todayCount'] ?? 0;
                        final unnecessaryTotal =
                            (analysis['unnecessaryTotal'] ?? 0).toDouble();

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AnalysisDetailPage(analysis: analysis),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Rating badge
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: _getRatingColor(
                                        rating,
                                      ).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getRatingColor(
                                          rating,
                                        ).withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getRatingEmoji(rating),
                                        style: const TextStyle(fontSize: 30),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Ma'lumotlar
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _formatDate(dateKey),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _getDateDifference(dateKey),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.payments,
                                              size: 16,
                                              color: Colors.blue.shade700,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${_formatCurrency(todayTotal)} so\'m',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              Icons.receipt,
                                              size: 16,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$todayCount ta',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (unnecessaryTotal > 0) ...[
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                size: 16,
                                                color: Colors.red.shade700,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Keraksiz: ${_formatCurrency(unnecessaryTotal)} so\'m',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.red.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // O'chirish tugmasi
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.shade400,
                                    ),
                                    onPressed: () =>
                                        _deleteAnalysis(dateKey, index),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
