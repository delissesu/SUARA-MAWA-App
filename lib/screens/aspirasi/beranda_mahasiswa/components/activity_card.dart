import 'package:flutter/material.dart';

class ActivityCard extends StatefulWidget {
  final Color iconBackgroundColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String timeAgo;
  final String description;
  final String statusLabel;
  final Color statusColor;
  final Color statusBgColor;
  final IconData statusIcon;
  final int index;
  final int? reportId;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.iconBackgroundColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.timeAgo,
    required this.description,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBgColor,
    required this.statusIcon,
    this.index = 0,
    this.reportId,
    this.onTap,
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    final delay = widget.index * 0.15;
    final startInterval = delay.clamp(0.0, 0.7);
    final endInterval = (startInterval + 0.5).clamp(startInterval, 1.0);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(startInterval, endInterval, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBadge = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: widget.statusBgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.statusIcon, color: widget.statusColor, size: 12),
          const SizedBox(width: 4),
          Text(
            widget.statusLabel,
            style: TextStyle(
              fontFamily: 'PublicSans',
              fontWeight: FontWeight.w500,
              fontSize: 11,
              color: widget.statusColor,
            ),
          ),
        ],
      ),
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.iconBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(widget.icon, color: widget.iconColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.title,
                                style: const TextStyle(
                                  fontFamily: 'PublicSans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF0D1B2A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.timeAgo,
                              style: TextStyle(
                                fontFamily: 'PublicSans',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontFamily: 'PublicSans',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        widget.reportId != null
                            ? Hero(
                                tag: 'status-badge-${widget.reportId}',
                                child: Material(
                                  color: Colors.transparent,
                                  child: statusBadge,
                                ),
                              )
                            : statusBadge,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
