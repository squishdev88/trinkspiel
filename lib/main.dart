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

import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

/// Root-Widget der App.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kings Cup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101020),
      ),
      home: const HomeScreen(),
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
  late final AudioPlayer _player;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer();

    // Pulsierender Effekt für den "Spielen"-Button.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Optional: Start-Sound direkt beim Öffnen abspielen.
    _playStartSound();
  }

  Future<void> _playStartSound() async {
    // Achtung: funktioniert nur, wenn assets/sounds/start.mp3 existiert
    try {
      await _player.play(AssetSource('sounds/start.mp3'));
    } catch (_) {
      // Wenn die Datei noch nicht existiert, einfach ignorieren.
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _goToPlayerSetup() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: const PlayerSetupScreen(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.cinzelDecorative(
      textStyle: const TextStyle(
        fontSize: 44,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
        color: Colors.amber,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Hintergrundverlauf
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF060612),
                    Color(0xFF1B1630),
                    Color(0xFF2A1B3D),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // „Dunkler Tisch“-Effekt unten
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Inhalt
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top-Leiste: Sprache + Einstellungen (nur Platzhalter).
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: 'Sprache',
                        onPressed: () {
                          // TODO: später Sprachmenü
                        },
                        icon: const Icon(Icons.language),
                      ),
                      IconButton(
                        tooltip: 'Einstellungen',
                        onPressed: () {
                          // TODO: später Settings
                        },
                        icon: const Icon(Icons.settings),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Titel "Kings Cup"
                  Center(
                    child: Column(
                      children: [
                        Text('Kings',
                            style: titleStyle.copyWith(fontSize: 40)),
                        Text('Cup',
                            style: titleStyle.copyWith(fontSize: 54)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Das ultimative Party-Trinkspiel',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // "Spielen"-Button mit Puls-Animation
                  Center(
                    child: ScaleTransition(
                      scale: _pulseAnim,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 18,
                          ),
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          elevation: 8,
                        ),
                        onPressed: _goToPlayerSetup,
                        child: Text(
                          'SPIELEN',
                          style: GoogleFonts.cinzel(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// SPIELER-EINGABE
// ===========================================================================

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final List<TextEditingController> _playerControllers = [
    TextEditingController(text: 'Spieler 1'),
    TextEditingController(text: 'Spieler 2'),
  ];

  @override
  void dispose() {
    for (final c in _playerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addPlayerField() {
    setState(() {
      _playerControllers.add(
        TextEditingController(text: 'Spieler ${_playerControllers.length + 1}'),
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
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, animation, __) {
          return ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: CircleGameScreen(players: players),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.cinzel(
      fontSize: 26,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spieler eintragen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Wer spielt mit?',
              style: titleStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Fügt eure Namen hinzu. Später können hier noch weitere '
              'Einstellungen hinzukommen (Schwierigkeit, Packs, usw.).',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _playerControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _playerControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Spieler ${index + 1}',
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removePlayerField(index),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                    ],
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
                    icon: const Icon(Icons.add),
                    label: const Text('Spieler hinzufügen'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startGame,
              child: const Text('Circle starten'),
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

  const PlayingCardView({
    super.key,
    required this.card,
    required this.faceDown,
  });

  @override
  Widget build(BuildContext context) {
    if (faceDown) {
      return Container(
        width: 120,
        height: 170,
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Kings\nCup',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      );
    }

    final rank = card.rank.shortLabel;
    final suitSymbol = card.suit.symbol;
    final suitColor = card.suit.color;

    return Container(
      width: 120,
      height: 170,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: suitColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rank,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: suitColor,
                    ),
                  ),
                  Text(
                    suitSymbol,
                    style: TextStyle(
                      fontSize: 18,
                      color: suitColor,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    rank,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: suitColor,
                    ),
                  ),
                  Text(
                    suitSymbol,
                    style: TextStyle(
                      fontSize: 18,
                      color: suitColor,
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Text(
                suitSymbol,
                style: TextStyle(
                  fontSize: 48,
                  color: suitColor,
                ),
              ),
            ),
          ],
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
  int _successCount = 0; // steuert Schwierigkeit
  String? _currentQuestionText;

  late final AnimationController _zoomController;
  late final Animation<double> _zoomAnimation;

  late final AnimationController _cardFloatController;

  String get _currentPlayerName => widget.players[_currentPlayerIndex];

  @override
  void initState() {
    super.initState();
    _deck = createFullCircleDeck();

    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _zoomAnimation = CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeOut,
    );
    _zoomController.forward();

    _cardFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _cardFloatController.dispose();
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

      _cardFloatController
        ..reset()
        ..repeat(reverse: true);
    });
  }

  /// Hier passiert die eigentliche Skill-Logik:
  ///
  /// [relativeY] ist zwischen 0 (oben) und 1 (unten).
  /// Wir definieren eine "Mitte-Zone" rund um 0.5.
  ///
  /// Am Anfang ist diese Zone groß (leicht),
  /// wird aber kleiner, je mehr Erfolg man hatte.
  void _handleTapOnCard(double relativeY) {
    if (!_isAwaitingTap || _currentCard == null) return;

    // Basis-Toleranz: Mitte darf +/- 0.22 sein => Mitte-Zone ~44 % der Karte.
    // Schwierigkeitssteigerung: pro Erfolg wird die Zone kleiner,
    // mindestens aber +/- 0.10 (20 % der Karte).
    final baseTolerance = 0.22;
    final minTolerance = 0.10;
    final shrinkPerSuccess = 0.02;
    final tolerance =
        (baseTolerance - _successCount * shrinkPerSuccess)
            .clamp(minTolerance, baseTolerance);

    final distanceFromCenter = (relativeY - 0.5).abs();
    final success = distanceFromCenter <= tolerance;

    setState(() {
      _tapSuccess = success;
      if (success) {
        _successCount++;
      }
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
        automaticallyImplyLeading: false,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Aktueller Spieler: $_currentPlayerName',
              style: GoogleFonts.cinzel(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text('Verbleibende Karten: ${_deck.length}'),
            const SizedBox(height: 4),
            Text('Skill-Level: $_successCount'),
            const SizedBox(height: 16),

            // Tisch + Becher + schwebende Karte
            Expanded(
              child: ScaleTransition(
                scale: _zoomAnimation,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Kings Cup in der Mitte
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFF3E2723),
                              Color(0xFF1B1412),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Kings\nCup',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cinzel(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_currentCard != null)
                        AnimatedBuilder(
                          animation: _cardFloatController,
                          builder: (context, child) {
                            final dy = _isAwaitingTap
                                ? sin(_cardFloatController.value * pi) * -12
                                : 0.0;
                            return Transform.translate(
                              offset: Offset(0, dy),
                              child: child,
                            );
                          },
                          child: TappableCard(
                            card: _currentCard!,
                            faceDown: _isAwaitingTap,
                            enabled: _isAwaitingTap,
                            onTapY: _handleTapOnCard,
                          ),
                        )
                      else
                        const Text(
                          'Bereit? Klicke auf „Karte vorbereiten“, um eine '
                          'neue Karte zu ziehen.',
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 16),

                      if (_isAwaitingTap)
                        const Text(
                          'Tippe in der Mitte der Karte.\n'
                          'Oben oder unten = Strafschluck!',
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            if (_currentCard != null && !_isAwaitingTap) ...[
              Card(
                color: Colors.white.withValues(alpha: 0.05),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Gezogene Karte: '
                        '${_currentCard!.rank.shortLabel} '
                        '${_currentCard!.suit.symbol}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _currentCard!.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(_currentCard!.description),
                      const SizedBox(height: 8),
                      if (_tapSuccess != null)
                        Text(
                          _tapSuccess == true
                              ? 'Du hast perfekt getroffen – sauber rausgezogen! 🎯'
                              : 'Nicht mittig getroffen – Strafschluck! 🥤',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _tapSuccess == true
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      if (kingInfo != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          kingInfo,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                      const SizedBox(height: 8),
                      if (isQuestionCard) ...[
                        const Divider(),
                        const Text(
                          'Frage wählen:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
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
                          const SizedBox(height: 8),
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
            ],

            const SizedBox(height: 8),

            Row(
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
                    onPressed: (_currentCard != null && !_isAwaitingTap)
                        ? _endTurnAndNextPlayer
                        : null,
                    child: const Text('Zug beenden / Nächster Spieler'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
