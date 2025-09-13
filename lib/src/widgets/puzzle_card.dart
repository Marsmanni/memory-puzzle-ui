import 'package:flutter/material.dart';

import '../models/card_state.dart';

class PuzzleCard extends StatefulWidget {
  final String imgUrl;
  final String placeholderAsset;
  final CardState state;

  const PuzzleCard({
    required this.imgUrl,
    required this.placeholderAsset,
    required this.state,
    super.key,
  });

  @override
  State<PuzzleCard> createState() => _PuzzleCardState();
}

class _PuzzleCardState extends State<PuzzleCard> {
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: widget.state.isDisabled,
      child: GestureDetector(
        onTap: widget.state.onTap,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            final rotate = widget.state.isFlipped
                ? Tween(begin: 0.0, end: 1.0).animate(animation)
                : Tween(begin: 1.0, end: 0.0).animate(animation);
            return AnimatedBuilder(
              animation: rotate,
              builder: (context, _) {
                final showFront = rotate.value < 0.5;
                Widget cardContent = showFront
                    ? Image.asset(
                        widget.placeholderAsset,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Image.network(
                        widget.imgUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      );
                if (widget.state.isMatched) {
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
            key: ValueKey(widget.state.isFlipped),
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
