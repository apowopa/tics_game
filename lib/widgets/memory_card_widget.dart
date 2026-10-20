import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/concept_pair.dart';

class MemoryCardWidget extends StatefulWidget {
  final MemoryCardModel card;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const MemoryCardWidget({
    super.key,
    required this.card,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<MemoryCardWidget>
    with TickerProviderStateMixin {
  late final AnimationController _flipController;
  late final AnimationController _shakeController;
  late final Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: (widget.card.isFlipped || widget.card.isMatched) ? 1.0 : 0.0,
    );
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeOutCubic,
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
  }

  @override
  void didUpdateWidget(covariant MemoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldShowFront = widget.card.isFlipped || widget.card.isMatched;
    if (shouldShowFront && _flipController.value < 1.0) {
      _flipController.forward();
    } else if (!shouldShowFront && _flipController.value > 0.0) {
      _flipController.reverse();
    }

    if (widget.card.isShaking && !_shakeController.isAnimating) {
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: Listenable.merge([_flipAnimation, _shakeController]),
        builder: (context, child) {
          final shakeOffset = widget.card.isShaking
              ? math.sin(_shakeController.value * math.pi * 4) * 3.5
              : 0.0;

          final angle = _flipAnimation.value * math.pi;
          final isFrontVisible = angle >= (math.pi / 2);

          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(angle),
              child: isFrontVisible
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: _buildFront(context),
                    )
                  : _buildBack(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shortest = math.min(constraints.maxWidth, constraints.maxHeight);
        final iconSize = (shortest * 0.34).clamp(14.0, 26.0);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
              width: 1.2,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.psychology_alt_rounded,
              size: iconSize,
              color: const Color(0xFF38BDF8).withValues(alpha: 0.75),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFront(BuildContext context) {
    final isConcept = widget.card.type == CardType.concept;
    final isMatched = widget.card.isMatched;
    final isShaking = widget.card.isShaking;

    final Color accentColor = isMatched
        ? const Color(0xFF10B981)
        : isShaking
            ? const Color(0xFFF59E0B)
            : isConcept
                ? const Color(0xFF818CF8)
                : const Color(0xFF38BDF8);

    final Color bgColor = isMatched
        ? const Color(0xFF064E3B).withValues(alpha: 0.75)
        : isConcept
            ? const Color(0xFF1E1B4B)
            : const Color(0xFF0C4A6E);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTiny = constraints.maxHeight < 80 || constraints.maxWidth < 85;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTiny ? 5 : 8,
            vertical: isTiny ? 4 : 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: bgColor,
            border: Border.all(
              color: accentColor.withValues(alpha: isMatched ? 0.9 : 0.7),
              width: isMatched ? 1.8 : 1.3,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      isConcept ? 'CONCEPTO' : 'DEFINICIÓN',
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: isTiny ? 6.5 : 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: accentColor,
                      ),
                    ),
                  ),
                  if (isMatched)
                    Icon(
                      Icons.check_circle_rounded,
                      size: isTiny ? 10 : 12,
                      color: const Color(0xFF34D399),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Center(
                  child: Text(
                    widget.card.text,
                    textAlign: TextAlign.center,
                    maxLines: isConcept ? 3 : 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isConcept
                          ? (isTiny ? 10.5 : 13.0)
                          : (isTiny ? 9.0 : 11.2),
                      fontWeight: isConcept ? FontWeight.w700 : FontWeight.w500,
                      height: 1.15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
