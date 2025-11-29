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

  @override
  void initState() {
    super.initState();

    // Animation für den "KINGS CUP"-Text (von links rein + Fade)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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

    // drehende Karte
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _cardRotation = Tween<double>(
      begin: -0.5,
      end: 0.5,
    ).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: Curves.easeInOut,
      ),
    );

    _cardController.repeat(reverse: true);

    // nach kurzer Zeit weiter zum HomeScreen
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      widget.onDone();
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
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: 4,
      color: Colors.amber,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF05050B),
      body: Center(
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
            AnimatedBuilder(
              animation: _cardRotation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _cardRotation.value,
                  child: child,
                );
              },
              child: Container(
                width: 80,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
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
    );
  }
}
