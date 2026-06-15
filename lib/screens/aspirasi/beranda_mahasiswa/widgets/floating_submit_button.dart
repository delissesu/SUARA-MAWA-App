import 'package:flutter/material.dart';

class FloatingSubmitButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const FloatingSubmitButton({super.key, this.onPressed});

  @override
  State<FloatingSubmitButton> createState() => _FloatingSubmitButtonState();
}

class _FloatingSubmitButtonState extends State<FloatingSubmitButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _scaleEntrance;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleEntrance = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.elasticOut,
      ),
    );

    // Delay entrance slightly so it appears after content
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 20,
      child: ScaleTransition(
        scale: _scaleEntrance,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onPressed?.call();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.88 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeInOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2B5F),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A2B5F)
                        .withValues(alpha: _isPressed ? 0.15 : 0.35),
                    blurRadius: _isPressed ? 6 : 12,
                    offset: Offset(0, _isPressed ? 2 : 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.note_add_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
