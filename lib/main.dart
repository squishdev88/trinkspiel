// main.dart
//
// Trinkspiel "Kings Cup / Circle" – Version mit:
// - fancy Startscreen (Sound, Kings Cup Schrift, Sprache/Settings-Buttons)
// - Kamerazoom auf den Tisch
// - 52 Karten (♥ ♦ ♣ ♠, Ass–König)
// - animierte, schwebende Karte
// - Skill-Mechanik: Treffer NUR, wenn man in der Mitte der Karte tippt
// - Schwierigkeit: "Mitte-Zone" wird kleiner, je länger man spielt
// - Fragendatenbank (eigene Frage / Frage vom Spiel)
//
// Alles nur mit Flutter + zwei Paketen:
//   audioplayers    -> Sound
//   google_fonts    -> schöne Schrift
import 'splash.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('de'),
        Locale('en'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('de'),
      child: const MyApp(),
    ),
  );
}


/// Root-Widget der App.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kings Cup',
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      navigatorKey: navigatorKey,  
theme: ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'KingsCupFont',         // ✔ hier ist es erlaubt
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: const Color(0xFF101020),
),

      home: SplashScreen(
  onDone: () {
    navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  },
),
    );
  }
}


// ===========================================================================
// STARTSCREEN
// ===========================================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Vollbild-Hintergrundbild
          SizedBox(
            width: size.width,
            height: size.height,
            child: Image.asset(
              'assets/images/mascot.png',
              fit: BoxFit.cover,
            ),
          ),

          // leichte Verdunkelung unten, damit Text/Buttons lesbar sind
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black54,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Oben rechts: Flaggen + Settings
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _languageFlag(const Locale('de'), '🇩🇪'),
                      const SizedBox(width: 8),
                      _languageFlag(const Locale('en'), '🇬🇧'),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          // TODO: Settings-Screen später
                        },
                        icon: const Icon(Icons.settings, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Unten: Spielen-Button
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 40,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 10,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PlayerSetupScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'home_play'.tr().toUpperCase(), // z.B. "STARTEN"
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageFlag(Locale locale, String emoji) {
    final isActive = context.locale == locale;

    return GestureDetector(
      onTap: () => context.setLocale(locale),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
              color: isActive
    ? Colors.amber.withOpacity(0.2)
    : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? Colors.amber : Colors.white54,
            width: 1,
          ),
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}



// ===========================================================================
// SPIELER-EINGABE
// ===========================================================================

// ===========================================================================
// SPIELER-EINGABE – NEU DESIGNED
// ===========================================================================
class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _playerControllers = [
    TextEditingController(text: 'Spieler 1'),
    TextEditingController(text: 'Spieler 2'),
  ];

  late final AnimationController _listAnimController;

  @override
  void initState() {
    super.initState();
    _listAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    for (final c in _playerControllers) {
      c.dispose();
    }
    _listAnimController.dispose();
    super.dispose();
  }

  void _addPlayerField() {
    setState(() {
      _playerControllers.add(
        TextEditingController(
          text: 'Spieler ${_playerControllers.length + 1}',
        ),
      );
    });
  }

  void _removePlayerField(int index) {
    if (_playerControllers.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mindestens 2 Spieler müssen mitspielen.'),
        ),
      );
      return;
    }
    setState(() {
      _playerControllers[index].dispose();
      _playerControllers.removeAt(index);
    });
  }

  void _startGame() {
    final players = _playerControllers
        .map((c) => c.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    if (players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte mindestens 2 Spieler eintragen.'),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CircleGameScreen(players: players),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontFamily: 'KingsCupFont',
      fontSize: 26,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kings Cup – Spieler'),
      ),
      body: Stack(
        children: [
          // leichter Hintergrundverlauf
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0B0B18),
                  Color(0xFF17152A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text('WER SPIELT MIT?', style: titleStyle),
                  const SizedBox(height: 8),
                  Text(
                    'Fügt eure Namen hinzu.\n'
                    'Ihr könnt aber auch einfach das Handy herumgeben.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _listAnimController,
                      builder: (context, child) {
                        return ListView.builder(
                          itemCount: _playerControllers.length,
                          itemBuilder: (context, index) {
                            final animation = CurvedAnimation(
                              parent: _listAnimController,
                              curve: Interval(
                                0.0,
                                1.0,
                                // alle Elemente kriegen dieselbe Kurve; reicht hier
                              ),
                            );
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.1),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: _buildPlayerCard(index),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _addPlayerField,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.amber,
                            side:
                                const BorderSide(color: Colors.amber, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Spieler hinzufügen'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'KINGS CUP STARTEN',
                        style: TextStyle(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF201C35),
              Color(0xFF2B2142),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white24,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Text(
              '#${index + 1}',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _playerControllers[index],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Spielername',
                ),
              ),
            ),
            IconButton(
              onPressed: () => _removePlayerField(index),
              icon: const Icon(Icons.remove_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}


// ===========================================================================
// DATENMODELL: KARTEN & FRAGEN
// ===========================================================================

enum CardRank {
  ace,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
}

extension CardRankDisplay on CardRank {
  String get shortLabel {
    switch (this) {
      case CardRank.ace:
        return 'A';
      case CardRank.two:
        return '2';
      case CardRank.three:
        return '3';
      case CardRank.four:
        return '4';
      case CardRank.five:
        return '5';
      case CardRank.six:
        return '6';
      case CardRank.seven:
        return '7';
      case CardRank.eight:
        return '8';
      case CardRank.nine:
        return '9';
      case CardRank.ten:
        return '10';
      case CardRank.jack:
        return 'J';
      case CardRank.queen:
        return 'Q';
      case CardRank.king:
        return 'K';
    }
  }
}

enum CardSuit {
  hearts,
  diamonds,
  clubs,
  spades,
}

extension CardSuitDisplay on CardSuit {
  String get symbol {
    switch (this) {
      case CardSuit.hearts:
        return '♥';
      case CardSuit.diamonds:
        return '♦';
      case CardSuit.clubs:
        return '♣';
      case CardSuit.spades:
        return '♠';
    }
  }

  Color get color {
    switch (this) {
      case CardSuit.hearts:
      case CardSuit.diamonds:
        return Colors.red;
      case CardSuit.clubs:
      case CardSuit.spades:
        return Colors.white;
    }
  }
}

class GameCard {
  final CardRank rank;
  final CardSuit suit;
  final String title;
  final String description;

  GameCard({
    required this.rank,
    required this.suit,
    required this.title,
    required this.description,
  });
}

/// einfache Fragendatenbank im Code
class QuestionRepository {
  static final Random _random = Random();

  static const List<String> generalQuestions = [
    'Wie viele Kontinente gibt es?',
    'Wie viele Bundesländer hat Deutschland?',
    'Wie viele Minuten hat eine Stunde?',
    'Wie viele Spieler sind gerade in dieser Runde?',
    'Wie viele Karten hat ein Standard-Kartendeck?',
  ];

  static const List<String> neverHaveIEverQuestions = [
    'Ich habe noch nie geklaut.',
    'Ich habe noch nie bei einer Prüfung geschummelt.',
    'Ich habe noch nie jemanden geghostet.',
    'Ich habe noch nie meinen Geburtstag vergessen.',
    'Ich habe noch nie heimlich etwas weggetrunken.',
  ];

  static String randomGeneralQuestion() =>
      generalQuestions[_random.nextInt(generalQuestions.length)];

  static String randomNeverHaveIEverQuestion() =>
      neverHaveIEverQuestions[_random.nextInt(neverHaveIEverQuestions.length)];
}

/// 52-Karten-Deck erstellen
List<GameCard> createFullCircleDeck() {
  final List<GameCard> cards = [];

  String titleForRank(CardRank rank) {
    switch (rank) {
      case CardRank.ace:
        return 'Wasserfall';
      case CardRank.two:
        return 'Zwei verteilen';
      case CardRank.three:
        return 'Drei trinken';
      case CardRank.four:
        return 'Frage an alle';
      case CardRank.five:
        return 'Kategorie';
      case CardRank.six:
        return 'Damen trinken';
      case CardRank.seven:
        return 'Heaven';
      case CardRank.eight:
        return 'Trinkpartner';
      case CardRank.nine:
        return 'Reimen';
      case CardRank.ten:
        return 'Männer trinken';
      case CardRank.jack:
        return 'Neue Regel';
      case CardRank.queen:
        return 'Ich hab noch nie…';
      case CardRank.king:
        return 'König – Kings Cup';
    }
  }

  String descriptionForRank(CardRank rank) {
    switch (rank) {
      case CardRank.ace:
        return 'Wasserfall: Alle trinken, bis die Person links von dir stoppt. '
            'Du beginnst.';
      case CardRank.two:
        return 'Verteile insgesamt 2 Schlucke an beliebige Person(en).';
      case CardRank.three:
        return 'Du trinkst selbst 3 Schlucke.';
      case CardRank.four:
        return 'Frage an alle: Eigene Frage oder Frage vom Spiel.';
      case CardRank.five:
        return 'Kategorie: Wähle ein Thema, reihum wird genannt. '
            'Wer nichts mehr weiß, trinkt.';
      case CardRank.six:
        return 'Alle Damen trinken einen Schluck.';
      case CardRank.seven:
        return 'Heaven: Finger nach oben. Wer zuletzt reagiert, trinkt.';
      case CardRank.eight:
        return 'Trinkpartner: Wähle eine Person, die immer mit dir trinkt, '
            'bis die nächste 8 kommt.';
      case CardRank.nine:
        return 'Reimen: Denke ein Wort, reihum wird gereimt. '
            'Wer nichts mehr weiß, trinkt.';
      case CardRank.ten:
        return 'Alle Männer trinken einen Schluck.';
      case CardRank.jack:
        return 'Neue Regel: Denke dir eine Hausregel aus, die ab jetzt gilt.';
      case CardRank.queen:
        return 'Ich hab noch nie…: Alle, die die Aussage doch getan haben, '
            'müssen trinken.';
      case CardRank.king:
        return 'König – Kings Cup: Einen Schluck in den Cup schütten. '
            'Der 4. König muss den Cup austrinken.';
    }
  }

  for (final suit in CardSuit.values) {
    for (final rank in CardRank.values) {
      cards.add(
        GameCard(
          rank: rank,
          suit: suit,
          title: titleForRank(rank),
          description: descriptionForRank(rank),
        ),
      );
    }
  }
  return cards;
}

// ===========================================================================
// KARTEN-VISUALISIERUNG & TAP-MECHANIK
// ===========================================================================

/// Zeigt eine Spielkarte an (Vorder- oder Rückseite).
class PlayingCardView extends StatelessWidget {
  final GameCard card;
  final bool faceDown;

  // NEU:
  final double width;
  final double height;

  const PlayingCardView({
    super.key,
    required this.card,
    required this.faceDown,
    this.width = 100,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: faceDown ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: faceDown
          ? const Center(
              child: Text(
                'KC',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Center(
              child: Text(
                '${card.rank.shortLabel}\n${card.suit.symbol}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}


/// Karte, die angetippt werden kann.
/// Wichtig: Hier wird geprüft, WO auf der Karte getippt wurde.
///
/// - Wir normalisieren die Tap-Position (0 = oben, 1 = unten).
/// - Nur wenn sie im "Mitte-Bereich" liegt, gilt es als success.
/// - Die Größe dieses Bereichs hängt von der difficulty ab.
class TappableCard extends StatelessWidget {
  final GameCard card;
  final bool faceDown;
  final bool enabled;
  final void Function(double relativeY) onTapY;

  const TappableCard({
    super.key,
    required this.card,
    required this.faceDown,
    required this.enabled,
    required this.onTapY,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: enabled
          ? (details) {
              final size = context.size;
              if (size == null) return;
              final y = details.localPosition.dy.clamp(0.0, size.height);
              final relativeY = y / size.height; // 0.0 bis 1.0
              onTapY(relativeY);
            }
          : null,
      child: PlayingCardView(card: card, faceDown: faceDown),
    );
  }
}

// ===========================================================================
// SPIEL-SCREEN (CIRCLE)
// ===========================================================================

// ===========================================================================
// KINGS CUP – SPIELSCREEN (Cup + Kartenkreis)
// ===========================================================================
class CircleGameScreen extends StatefulWidget {
  final List<String> players;

  const CircleGameScreen({super.key, required this.players});

  @override
  State<CircleGameScreen> createState() => _CircleGameScreenState();
}

class _CircleGameScreenState extends State<CircleGameScreen>
    with TickerProviderStateMixin {
  late List<GameCard> _deck;
  final Random _random = Random();

  int _currentPlayerIndex = 0;
  GameCard? _currentCard;
  int _drawnKings = 0;

  bool _isAwaitingTap = false;
  bool? _tapSuccess;
  int _successCount = 0;
  String? _currentQuestionText;

  late final AnimationController _cardFloatController;
  late final AnimationController _drawController;

  String get _currentPlayerName => widget.players[_currentPlayerIndex];

  @override
  void initState() {
    super.initState();
    _deck = createFullCircleDeck();

    _cardFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _cardFloatController.dispose();
    _drawController.dispose();
    super.dispose();
  }

  void _nextPlayer() {
    setState(() {
      _currentPlayerIndex =
          (_currentPlayerIndex + 1) % widget.players.length;
    });
  }

  void _prepareNewCard() {
    if (_deck.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deck leer – Spiel vorbei!'),
        ),
      );
      return;
    }

    setState(() {
      final index = _random.nextInt(_deck.length);
      final card = _deck.removeAt(index);
      _currentCard = card;
      _isAwaitingTap = true;
      _tapSuccess = null;
      _currentQuestionText = null;

      if (card.rank == CardRank.king) {
        _drawnKings++;
      }

      _drawController
        ..reset()
        ..forward();
      _cardFloatController
        ..reset()
        ..repeat(reverse: true);
    });
  }

  void _handleTapOnMovingCard() {
    if (!_isAwaitingTap || _currentCard == null) return;

    final t = _cardFloatController.value;
    final sinValue = sin(t * 2 * pi);

    const baseTolerance = 0.35;
    const minTolerance = 0.12;
    const shrinkPerSuccess = 0.03;

    final tolerance =
        (baseTolerance - _successCount * shrinkPerSuccess)
            .clamp(minTolerance, baseTolerance);

    final success = sinValue.abs() <= tolerance;

    setState(() {
      _tapSuccess = success;
      if (success) _successCount++;
      _isAwaitingTap = false;
      _cardFloatController.stop();
    });
  }

  void _endTurnAndNextPlayer() {
    setState(() {
      _currentCard = null;
      _tapSuccess = null;
      _currentQuestionText = null;
      _isAwaitingTap = false;
    });
    _nextPlayer();
  }

  @override
  Widget build(BuildContext context) {
    String? kingInfo;
    if (_currentCard?.rank == CardRank.king) {
      kingInfo = 'Gezogene Könige: $_drawnKings / 4\n'
          '${_drawnKings == 4 ? '⚠️ 4. König! Der Spieler muss den Kings Cup trinken.' : ''}';
    }

    final isQuestionCard =
        _currentCard?.rank == CardRank.four ||
        _currentCard?.rank == CardRank.queen;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kings Cup – Spiel'),
        actions: [
          IconButton(
            tooltip: 'Zur Startseite',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _isAwaitingTap ? _handleTapOnMovingCard : null,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF050512),
                Color(0xFF15152A),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kopfbereich mit Infos
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AKTUELLER SPIELER: $_currentPlayerName'.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'KingsCupFont',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Verbleibende Karten: ${_deck.length}'),
                      Text('Skill-Level: $_successCount'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Tisch + Cup + Kartenkreis + Karte + Zielzone
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 340,
                      height: 360,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // runder „Tisch“
                          Container(
                            width: 320,
                            height: 320,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Color(0xFF3E2723),
                                  Color(0xFF261313),
                                  Color(0xFF120A0A),
                                ],
                                radius: 0.9,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black87,
                                  blurRadius: 30,
                                  offset: Offset(0, 18),
                                ),
                              ],
                            ),
                          ),

                          // Kartenkreis (Deko-Karten, Rückseite)
                          const _CardRing(),

                          // Kings Cup in der Mitte
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [
                                  Color(0xFF5D4037),
                                  Color(0xFF3E2723),
                                  Color(0xFF1B1412),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.amber.shade700,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'KINGS\nCUP',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'KingsCupFont',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade200,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),

                          // Ziel-Rechteck, pulsierend
                          Positioned(
                            bottom: 40,
                            child: AnimatedOpacity(
                              opacity: _isAwaitingTap ? 1 : 0.3,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                width: 160,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.greenAccent,
                                    width: 2,
                                  ),
                                  color: Colors.greenAccent
                                      .withOpacity(0.12),
                                ),
                              ),
                            ),
                          ),

                          // bewegte Karte
                          if (_currentCard != null)
                            AnimatedBuilder(
                              animation: Listenable.merge(
                                [_cardFloatController, _drawController],
                              ),
                              builder: (context, child) {
                                final drawOffset =
                                    (1 - _drawController.value) * 90;

                                final floatAmplitude = 70.0;
                                final floatDy = _isAwaitingTap
                                    ? sin(_cardFloatController.value *
                                            2 *
                                            pi) *
                                        -floatAmplitude
                                    : 0.0;

                                final totalDy =
                                    drawOffset + floatDy;

                                return Transform.translate(
                                  offset: Offset(0, totalDy),
                                  child: child,
                                );
                              },
                              child: PlayingCardView(
                                card: _currentCard!,
                                faceDown: _isAwaitingTap,
                                width: 120,
                                height: 170,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Info-Karten unten
                if (_currentCard != null && !_isAwaitingTap) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Card(
                      color: Colors.white.withOpacity(0.05),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Gezogene Karte: '
                              '${_currentCard!.rank.shortLabel} ${_currentCard!.suit.symbol}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentCard!.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(_currentCard!.description),
                            const SizedBox(height: 8),
                            if (_tapSuccess != null)
                              Text(
                                _tapSuccess == true
                                    ? 'Perfekt im Zielbereich gestoppt – kein Strafschluck! 🎯'
                                    : 'Nicht im Zielbereich – Strafschluck! 🥤',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _tapSuccess == true
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                ),
                              ),
                            if (kingInfo != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                kingInfo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            if (isQuestionCard) ...[
                              const Divider(),
                              const Text(
                                'Frage wählen:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _currentQuestionText =
                                              'Eigene Frage: Denkt euch eine Frage '
                                              'und stellt sie der Runde.';
                                        });
                                      },
                                      child: const Text('Eigene Frage'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          if (_currentCard!.rank ==
                                              CardRank.four) {
                                            _currentQuestionText =
                                                QuestionRepository
                                                    .randomGeneralQuestion();
                                          } else {
                                            _currentQuestionText =
                                                QuestionRepository
                                                    .randomNeverHaveIEverQuestion();
                                          }
                                        });
                                      },
                                      child: const Text('Frage vom Spiel'),
                                    ),
                                  ),
                                ],
                              ),
                              if (_currentQuestionText != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  _currentQuestionText!,
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Buttons unten
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (_currentCard == null && !_isAwaitingTap)
                              ? _prepareNewCard
                              : null,
                          child: const Text('Karte vorbereiten'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              (_currentCard != null && !_isAwaitingTap)
                                  ? _endTurnAndNextPlayer
                                  : null,
                          child: const Text(
                            'Zug beenden / Nächster Spieler',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// dekorativer Kartenring (Rückseiten)
class _CardRing extends StatelessWidget {
  const _CardRing();

  @override
  Widget build(BuildContext context) {
    const cardCount = 16; // nicht alle 52 zeigen, sonst zu voll
    final radius = 135.0;
    final cardWidth = 46.0;
    final cardHeight = 70.0;

    return SizedBox(
      width: radius * 2 + cardWidth,
      height: radius * 2 + cardHeight,
      child: Stack(
        children: [
          for (int i = 0; i < cardCount; i++)
            _buildCardAtAngle(
              angle: (2 * pi * i) / cardCount,
              radius: radius,
              width: cardWidth,
              height: cardHeight,
            ),
        ],
      ),
    );
  }

  Widget _buildCardAtAngle({
    required double angle,
    required double radius,
    required double width,
    required double height,
  }) {
    final cx = radius + width / 2;
    final cy = radius + height / 2;
    final dx = cos(angle) * radius;
    final dy = sin(angle) * radius;

    return Positioned(
      left: cx + dx - width / 2,
      top: cy + dy - height / 2,
      child: Transform.rotate(
        angle: angle + pi / 2,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'KC',
              style: TextStyle(
                fontFamily: 'KingsCupFont',
                fontSize: 12,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

