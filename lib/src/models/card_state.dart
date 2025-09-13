import 'dart:ui';

class CardState {
  final bool isMatched;
  final bool isFlipped;
  final bool isDisabled;
  final VoidCallback onTap;

  CardState({
    required this.isMatched,
    required this.isFlipped,
    required this.isDisabled,
    required this.onTap,
  });
}