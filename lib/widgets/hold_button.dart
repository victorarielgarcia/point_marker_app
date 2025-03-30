import 'package:flutter/material.dart';

class HoldButton extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isEntry;
  final double holdDuration;

  const HoldButton({
    super.key,
    required this.onComplete,
    required this.isEntry,
    this.holdDuration = 1.0,
  });

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<HoldButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: (widget.holdDuration * 1000).toInt()),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startHolding() {
    setState(() {
      _isHolding = true;
    });
    _controller.forward().then((_) {
      if (_isHolding) {
        widget.onComplete();
      }
    });
  }

  void _stopHolding() {
    setState(() {
      _isHolding = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isEntry ? Colors.green : Colors.red;

    return GestureDetector(
      onTapDown: (_) => _startHolding(),
      onTapUp: (_) => _stopHolding(),
      onTapCancel: () => _stopHolding(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 6,
                  ),
                ),
                child: CircularProgressIndicator(
                  value: _animation.value,
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              );
            },
          ),
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.fingerprint,
              size: 80,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
