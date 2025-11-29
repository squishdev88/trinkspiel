import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;

  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  late AnimationController _cardController;
  late Animation<double> _cardRotation;
  late Animation<double> _cardScale;

  @override
  void initState() {
    super.initState();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(-1.2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _fadeAnim = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    _textController.forward();

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _cardRotation = Tween<double>(
      begin: -0.4,
      end: 2 * 3.14159, // 1 Drehung
    ).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    _cardScale = Tween<double>(
      begin: 1.0,
      end: 18.0,
    ).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _cardController.forward();

    _cardController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontFamily: 'KingsCupFont',
      fontSize: 34,
      fontWeight: FontWeight.w700,
      letterSpacing: 4,
      color: Colors.amber,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF05050B),
      body: Center(
        child: AnimatedBuilder(
          animation: _cardController,
          builder: (context, child) {
            return Transform.scale(
              scale: _cardScale.value,
              child: child,
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Text('KINGS CUP', style: titleStyle),
                ),
              ),
              const SizedBox(height: 24),
              Transform.rotate(
                angle: _cardRotation.value,
                child: Container(
                  width: 80,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '♠',
                      style: TextStyle(
                        fontSize: 46,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
