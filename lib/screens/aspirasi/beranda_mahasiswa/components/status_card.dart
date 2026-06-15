import 'package:flutter/material.dart';

class StatusCard extends StatefulWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final bool isWide;

  const StatusCard({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    this.isWide = false,
  });

  @override
  State<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _countAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _countAnimation = IntTween(begin: 0, end: widget.count).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant StatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _countAnimation = IntTween(
        begin: oldWidget.count,
        end: widget.count,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: widget.isWide ? _buildWideLayout() : _buildCompactLayout(),
    );
  }

  Widget _buildCompactLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(widget.icon, color: widget.iconColor, size: 22),
            AnimatedBuilder(
              animation: _countAnimation,
              builder: (context, child) {
                return Text(
                  '${_countAnimation.value}',
                  style: TextStyle(
                    fontFamily: 'PublicSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    color: widget.textColor,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'PublicSans',
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: widget.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.icon, color: widget.iconColor, size: 22),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: widget.textColor,
              ),
            ),
          ],
        ),
        AnimatedBuilder(
          animation: _countAnimation,
          builder: (context, child) {
            return Text(
              '${_countAnimation.value}',
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontWeight: FontWeight.w800,
                fontSize: 32,
                color: widget.textColor,
              ),
            );
          },
        ),
      ],
    );
  }
}
