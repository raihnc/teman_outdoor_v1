import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../theme/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final bool interactive;
  final ValueChanged<int>? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 20,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starValue = index + 1;
        final filled = rating >= starValue;
        final half = !filled && rating >= starValue - 0.5;

        return GestureDetector(
          onTap: interactive ? () => onRatingChanged?.call(starValue) : null,
          child: Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              filled
                  ? Ionicons.star
                  : half
                      ? Ionicons.star_half
                      : Ionicons.star_outline,
              size: size,
              color: filled || half
                  ? AppColors.warning
                  : AppColors.textHint,
            ),
          ),
        );
      }),
    );
  }
}
