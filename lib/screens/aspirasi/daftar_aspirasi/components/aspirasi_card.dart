import 'package:flutter/material.dart';
import '../models/aspirasi_item.dart';
import 'status_badge.dart';
import 'category_chip.dart';

class AspirasiCard extends StatefulWidget {
  final AspirasiItem item;
  final VoidCallback? onViewDetails;
  final int index;

  const AspirasiCard({
    super.key,
    required this.item,
    this.onViewDetails,
    this.index = 0,
  });

  @override
  State<AspirasiCard> createState() => _AspirasiCardState();
}

class _AspirasiCardState extends State<AspirasiCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    // Stagger based on index (capped so deep items don't wait too long)
    final delayMs = (widget.index * 60).clamp(0, 300);
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _controller.forward();
    });

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                  color: widget.item.status.accentBorderColor, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onViewDetails,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge + date row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatusBadge(
                          status: widget.item.status,
                          reportId: widget.item.reportId,
                        ),
                        Text(
                          widget.item.dateLabel,
                          style: TextStyle(
                            fontFamily: 'PublicSans',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Title
                    Text(
                      widget.item.title,
                      style: const TextStyle(
                        fontFamily: 'PublicSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.3,
                        color: Color(0xFF0D1B2A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Description
                    Text(
                      widget.item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'PublicSans',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey.shade200, height: 1),
                    const SizedBox(height: 10),
                    // Category + View Details row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CategoryChip(label: widget.item.category),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Lihat Detail',
                              style: TextStyle(
                                fontFamily: 'PublicSans',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF1A2B5F),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: Color(0xFF1A2B5F),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
