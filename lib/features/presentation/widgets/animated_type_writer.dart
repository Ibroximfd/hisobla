import 'package:flutter/material.dart';

class AnimatedTypewriter extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration delay;

  const AnimatedTypewriter({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 30),
    this.delay = const Duration(milliseconds: 0),
  });

  @override
  State<AnimatedTypewriter> createState() => _AnimatedTypewriterState();
}

class _AnimatedTypewriterState extends State<AnimatedTypewriter>
    with SingleTickerProviderStateMixin {
  String _displayedText = '';
  int _currentIndex = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didUpdateWidget(AnimatedTypewriter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _currentIndex = 0;
      _displayedText = '';
      _startAnimation();
    }
  }

  Future<void> _startAnimation() async {
    await Future.delayed(widget.delay);
    if (!mounted) return;

    setState(() => _isAnimating = true);

    while (_currentIndex < widget.text.length && mounted) {
      await Future.delayed(widget.duration);
      if (!mounted) break;

      setState(() {
        _currentIndex++;
        _displayedText = widget.text.substring(0, _currentIndex);
      });
    }

    if (mounted) {
      setState(() => _isAnimating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText + (_isAnimating ? '▊' : ''),
      style: widget.style,
    );
  }
}
