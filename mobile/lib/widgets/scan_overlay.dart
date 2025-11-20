import 'package:flutter/material.dart';

class ScanOverlay extends StatefulWidget {
  const ScanOverlay({super.key});

  @override
  State<ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<ScanOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.7;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;

    return Stack(
      children: [
        // Animated scanning line
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Positioned(
              left: left,
              top: top + (_animation.value * (scanAreaSize - 4)),
              child: Container(
                width: scanAreaSize,
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Corner decorations
        Positioned(
          left: left - 10,
          top: top - 10,
          child: _buildCornerDecoration(
            Colors.white,
            [Alignment.topLeft],
          ),
        ),
        Positioned(
          right: left - 10,
          top: top - 10,
          child: _buildCornerDecoration(
            Colors.white,
            [Alignment.topRight],
          ),
        ),
        Positioned(
          left: left - 10,
          bottom: size.height - top - scanAreaSize - 10,
          child: _buildCornerDecoration(
            Colors.white,
            [Alignment.bottomLeft],
          ),
        ),
        Positioned(
          right: left - 10,
          bottom: size.height - top - scanAreaSize - 10,
          child: _buildCornerDecoration(
            Colors.white,
            [Alignment.bottomRight],
          ),
        ),
      ],
    );
  }

  Widget _buildCornerDecoration(Color color, List<Alignment> corners) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(
          color: color,
          width: 3,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.transparent,
            width: 6,
          ),
        ),
      ),
    );
  }
}
