import 'package:flutter/material.dart';
import '../models/aspirasi_item.dart';
import '../components/aspirasi_card.dart';

class AspirasiListSection extends StatelessWidget {
  final List<AspirasiItem> items;
  final ValueChanged<AspirasiItem>? onViewDetails;

  const AspirasiListSection({
    super.key,
    required this.items,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return AspirasiCard(
          item: item,
          onViewDetails: () => onViewDetails?.call(item),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Aspirasi tidak ditemukan',
            style: TextStyle(
              fontFamily: 'PublicSans',
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba gunakan kata kunci atau filter yang berbeda.',
            style: TextStyle(
              fontFamily: 'PublicSans',
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
