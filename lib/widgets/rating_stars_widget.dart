import 'package:flutter/material.dart';

class RatingStarsWidget extends StatelessWidget {
  final double rating;
  final double size;
  final int maxStars;

  const RatingStarsWidget({
    required this.rating,
    this.size = 24,
    this.maxStars = 5,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(Icons.star, color: Colors.amber, size: size));
    }


    if (hasHalfStar) {
      stars.add(Icon(Icons.star_half, color: Colors.amber, size: size));
    }

    int remainingStars = maxStars - stars.length;
    for (int i = 0; i < remainingStars; i++) {
      stars.add(
          Icon(Icons.star_border, color: Colors.amber.withOpacity(0.5), size: size));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
    );
  }
}
