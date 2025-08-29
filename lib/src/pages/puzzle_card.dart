import 'dart:ui';

import 'package:flutter/material.dart';

class PuzzleCard extends StatelessWidget {
  final String imgUrl;
  final bool isMatched;
  final bool isFlipped;
  final bool isDisabled;
  final VoidCallback onTap;
  final String placeholderAsset;

  const PuzzleCard({
    required this.imgUrl,
    required this.isMatched,
    required this.isFlipped,
    required this.isDisabled,
    required this.onTap,
    required this.placeholderAsset,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isDisabled,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            final rotate = isFlipped
                ? Tween(begin: 0.0, end: 1.0).animate(animation)
                : Tween(begin: 1.0, end: 0.0).animate(animation);
            return AnimatedBuilder(
              animation: rotate,
              builder: (context, _) {
                final showFront = rotate.value < 0.5;
                Widget cardContent = showFront
                    ? Image.asset(
                        placeholderAsset,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      );
                if (isMatched) {
                  cardContent = ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.grey,
                      BlendMode.saturation,
                    ),
                    child: cardContent,
                  );
                }
                return Transform(
                  transform: Matrix4.rotationY(rotate.value * 3.1416),
                  alignment: Alignment.center,
                  child: cardContent,
                );
              },
            );
          },
          child: SizedBox(
            key: ValueKey(isFlipped),
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
