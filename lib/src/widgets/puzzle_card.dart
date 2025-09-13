import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../models/card_state.dart';

class PuzzleCard extends StatefulWidget {
  final String imgUrl;
  final CardState state;
  final String placeholderAsset;

  const PuzzleCard({
    super.key,
    required this.imgUrl,
    required this.state,
    required this.placeholderAsset,
  });

  @override
  State<PuzzleCard> createState() => _PuzzleCardState();
}

class _PuzzleCardState extends State<PuzzleCard> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    final begin = random.nextDouble() * 4; // random between 0 and 4
    final end = 4 + random.nextDouble() * 8; // random between 4 and 12
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _shakeAnimation = Tween<double>(begin: begin, end: end)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void didUpdateWidget(covariant PuzzleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.isShaking) {
      _shakeController.forward(from: 0);
    } else {
      _shakeController.stop();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: widget.state.isShaking
              ? Offset(16 * _shakeAnimation.value * (math.sin(DateTime.now().millisecondsSinceEpoch / 50)), 16 * _shakeAnimation.value * (math.cos(DateTime.now().millisecondsSinceEpoch / 50)))
              : Offset.zero,
          child: AbsorbPointer(
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
          ),
        );
      },
    );
  }
}
