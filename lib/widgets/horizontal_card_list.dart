import 'package:flutter/material.dart';

/// Horizontal scrolling card list with section header.
///
/// Good for album recommendations, artist discography, related content, etc.
class HorizontalCardList extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final double cardWidth;
  final double cardHeight;

  const HorizontalCardList({
    super.key,
    required this.title,
    this.onSeeAll,
    required this.itemCount,
    required this.itemBuilder,
    this.cardWidth = 150,
    this.cardHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < itemCount - 1 ? 12 : 0,
                ),
                child: SizedBox(
                  width: cardWidth,
                  child: itemBuilder(context, index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See All'),
            ),
        ],
      ),
    );
  }
}
