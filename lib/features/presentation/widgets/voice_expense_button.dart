import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobla/core/services/voice_parse_service.dart';
import 'package:hisobla/core/services/voice_service.dart';
import 'package:hisobla/features/presentation/blocs/hisobla_bloc/hisobla_bloc.dart';
import 'package:hisobla/features/presentation/blocs/hisobla_bloc/hisobla_event.dart';
import 'package:hisobla/features/presentation/widgets/voice_expense_dialog.dart';

class VoiceExpenseButton extends StatefulWidget {
  final double height;
  final double width;
  final bool isCompact;

  const VoiceExpenseButton({
    super.key,
    this.height = 60,
    this.width = 68,
    this.isCompact = false,
  });

  @override
  State<VoiceExpenseButton> createState() => _VoiceExpenseButtonState();
}

class _VoiceExpenseButtonState extends State<VoiceExpenseButton>
    with SingleTickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();
  bool _isListening = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  Future<void> _startVoiceRecording() async {
    if (_isListening) return;

    setState(() => _isListening = true);
    _animationController.repeat();

    // Loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated mic icon
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_animationController.value * 0.2),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.red.shade400, Colors.red.shade600],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Eshitilmoqda...',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Xarajatingizni ayting\nMasalan: "Nonga 5000 so\'m sarfladim"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    _voiceService.stopListening();
                    Navigator.pop(context);
                    setState(() => _isListening = false);
                    _animationController.stop();
                  },
                  child: const Text(
                    'Bekor qilish',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Ovozni tinglash
    final recognizedText = await _voiceService.startListening();

    // Loading dialogni yopish
    if (mounted) Navigator.pop(context);

    setState(() => _isListening = false);
    _animationController.stop();

    // Natijani ko'rsatish
    if (recognizedText != null && recognizedText.isNotEmpty) {
      _showResultDialog(recognizedText);
    } else {
      _showErrorSnackBar('Ovoz aniqlanmadi. Qaytadan harakat qiling.');
    }
  }

  void _showResultDialog(String recognizedText) {
    final parsed = VoiceParserService.parseVoiceText(recognizedText);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VoiceExpenseDialog(
        originalText: parsed['originalText'],
        amount: parsed['amount'],
        description: parsed['description'],
        onConfirm: () {
          if (parsed['success']) {
            // Xarajatni qo'shish
            context.read<BudgetBloc>().add(
              AddExpenseEvent(parsed['amount'], parsed['description']),
            );

            Navigator.pop(context);
            _showSuccessSnackBar(
              'Xarajat qo\'shildi: ${parsed['description']}',
            );
          }
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = widget.isCompact ? 24.0 : 28.0;
    final borderRadius = widget.isCompact ? 10.0 : 12.0;

    return InkWell(
      onTap: _isListening ? null : _startVoiceRecording,
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isListening
                ? [Colors.red.shade400, Colors.red.shade600]
                : [Colors.purple.shade400, Colors.purple.shade600],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: (_isListening ? Colors.red : Colors.purple).withOpacity(
                0.4,
              ),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          size: iconSize,
          color: Colors.white,
        ),
      ),
    );
  }
}
