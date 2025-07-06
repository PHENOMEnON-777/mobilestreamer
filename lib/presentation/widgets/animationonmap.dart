


import 'package:flutter/material.dart';

class AnimatedStationMarker extends StatefulWidget {
  final dynamic station;
  final VoidCallback onTap;

  const AnimatedStationMarker({
    super.key,
    required this.station,
    required this.onTap,
  });

  @override
  State<AnimatedStationMarker> createState() => _AnimatedStationMarkerState();
}

class _AnimatedStationMarkerState extends State<AnimatedStationMarker>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _blinkController;
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  
  late Animation<double> _shakeAnimation;
  late Animation<double> _blinkAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    // Shake animation - subtle trembling effect
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _shakeAnimation = Tween(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Blink animation - appearing/disappearing
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _blinkAnimation = Tween(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // Pulse animation - size pulsing
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Bounce animation - vertical movement
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnimation = Tween(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.linear),
    );

    // Start periodic shaking
    _startPeriodicShaking();
  }

  void _startPeriodicShaking() {
    Future.delayed(Duration(milliseconds: 2000 + (widget.station.hashCode % 3000)), () {
      if (mounted) {
        _shakeController.forward().then((_) {
          if (mounted) {
            _shakeController.reverse().then((_) {
              if (mounted) {
                _startPeriodicShaking();
              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _blinkController.dispose();
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _shakeController,
        _blinkController,
        _pulseController,
        _bounceController,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _shakeAnimation.value * (widget.station.hashCode % 2 == 0 ? 1 : -1),
            _bounceAnimation.value,
          ),
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Opacity(
              opacity: _blinkAnimation.value,
              child: GestureDetector(
                onTap: widget.onTap,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow effect
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(0.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    // Pulsing ring
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red.withOpacity(_pulseAnimation.value * 0.8),
                          width: 2,
                        ),
                      ),
                    ),
                    // Main marker
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.local_gas_station,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    // Beep indicator dot
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.6),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}