// main.dart
//
// Grundgerüst für eure Trinkspiel-App "Circle".
//
// Features in dieser Version:
// - Startscreen mit "Spielen"
// - Spielerliste (Namen eingeben)
// - 52-Karten-Deck mit ♥ ♦ ♣ ♠ und Rängen Ass–König
// - Circle-Regeln für jede Karte (1 = Ass ... König)
// - Kamera-ähnlicher Zoom auf den Tisch/Becher beim Spielstart
// - Animierte Karte, die hoch/runter schwebt
//   -> Spieler muss im "perfekten Moment" auf die Karte tippen
//   -> mittlerer Bereich = ok, sonst Strafschluck
// - Fragendatenbank (lokale Listen in Dart):
//   -> Button: "Eigene Frage"
//   -> Button: "Frage vom Spiel" -> random Frage aus Liste
//
// Später könnt ihr:
// - Layout/Design anpassen
// - echte Grafiken/Assets benutzen
// - Fragen aus echter Datenbank (Firestore, MySQL, etc.) laden
// - Werbung, In-App-Käufe, Abos etc. einbauen

import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Wurzelwidget der App.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trinkspiel Circle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

/// Startscreen:
/// - Willkommenstext
/// - Button "Spielen"
/// - Button "Regeln anzeigen"
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trinkspiel Circle'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Willkommen bei Circle 🍻',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Drück auf "Spielen", um Spieler einzutragen und das Spiel '
                'zu starten.\n\n'
                'Im Spiel zoomt die Kamera auf den Tisch, du siehst den '
                'Kings Cup und ziehst Karten, indem du im richtigen Moment '
                'auf die animierte Karte tippst.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PlayerSetupScreen(),
                    ),
                  );
                },
                child: const Text('Spielen'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text('Regeln – Kurzfassung'),
                      content: SingleChildScrollView(
                        child: Text(
                          'A (Ass): Wasserfall – Alle trinken, bis links von dir stoppt.\n'
                          '2: Zwei Schlucke verteilen.\n'
                          '3: Drei Schlucke trinken.\n'
                          '4: Frage an alle (eigene / aus Fragenliste).\n'
                          '5: Kategorie.\n'
                          '6: Damen trinken.\n'
                          '7: Heaven (Finger nach oben, letzter trinkt).\n'
                          '8: Trinkpartner.\n'
                          '9: Reimen.\n'
                          '10: Männer trinken.\n'
                          'Bube: Neue Regel.\n'
                          'Dame: Ich hab noch nie… (Frage an alle).\n'
                          'König: In den Kings Cup schütten, 4. König trinkt.',
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Regeln anzeigen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
//  Spielereingabe
// ============================================================================

/// Screen, auf dem die Spieler-Namen eingetragen werden.
/// Hier könnt ihr später auch weitere Einstellungen einbauen
/// (z.B. Levelpacks, Schwierigkeitsgrad usw.).
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
      MaterialPageRoute(
        builder: (_) => CircleGameScreen(players: players),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spieler eintragen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Tragt hier eure Namen ein.\n'
              'Später könnt ihr hier auch Avatare, Farben oder Levelpacks wählen.',
              textAlign: TextAlign.center,
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

// ============================================================================
//  Datenmodell: Karten + Fragen
// ============================================================================

/// Ränge: Ass bis König (1–13).
enum CardRank {
  ace, // Ass
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack, // Bube
  queen,
  king,
}

/// Anzeige-Label für den Rang (z.B. "A", "K", "10").
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

/// Farben / Suits des Kartendecks.
enum CardSuit {
  hearts,   // Herz
  diamonds, // Karo
  clubs,    // Kreuz
  spades,   // Pik
}

/// Symbol und Farbe für jede Suit.
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
        return Colors.black;
    }
  }
}

/// Model für eine Spielkarte.
class GameCard {
  final CardRank rank;
  final CardSuit suit;
  final String title;       // z.B. "Wasserfall"
  final String description; // zugehörige Regel

  GameCard({
    required this.rank,
    required this.suit,
    required this.title,
    required this.description,
  });
}

/// Repository für Fragen.
/// Aktuell lokal im Code (Listen).
///
/// WICHTIG für euch:
/// - Wenn ihr mehr Fragen wollt, einfach in den Listen unten neue Strings
///   hinzufügen.
/// - Später könnt ihr dieses Repository ersetzen durch:
///   - lokale JSON-Dateien (über Assets)
///   - oder eine echte Datenbank (z.B. Firebase Firestore, MySQL-Backend etc.)
class QuestionRepository {
  static final Random _random = Random();

  /// Allgemeine Fragen für Karte "4 – Frage an alle".
  static const List<String> generalQuestions = [
    'Wie viele Kontinente gibt es?',
    'In welchem Jahr wurde die Berliner Mauer gebaut?',
    'Wie viele Bundesländer hat Deutschland?',
    'Wie viele Minuten hat eine Stunde?',
    'Wie viele Zähne hat ein erwachsener Mensch normalerweise?',
  ];

  /// "Ich hab noch nie..."-Fragen für die Dame.
  static const List<String> neverHaveIEverQuestions = [
    'Ich habe noch nie geklaut.',
    'Ich habe noch nie bei einer Prüfung geschummelt.',
    'Ich habe noch nie jemanden ghosted.',
    'Ich habe noch nie einen Streit angefangen, nur aus Langeweile.',
    'Ich habe noch nie meinen Geburtstag vergessen.',
  ];

  static String randomGeneralQuestion() {
    return generalQuestions[_random.nextInt(generalQuestions.length)];
  }

  static String randomNeverHaveIEverQuestion() {
    return neverHaveIEverQuestions[
        _random.nextInt(neverHaveIEverQuestions.length)];
  }
}

/// 52-Karten-Deck erzeugen:
/// - 4 Suits
/// - 13 Ränge pro Suit
/// -> 4 * 13 = 52 Karten
///
/// Die Regelbeschreibung hängt nur vom Rang ab: alle Ass-Karten haben
/// die gleiche Regel, usw.
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
            'Du beginnst zu trinken.';
      case CardRank.two:
        return 'Verteile insgesamt 2 Schlucke an beliebige Person(en) deiner Wahl.';
      case CardRank.three:
        return 'Du trinkst selbst 3 Schlucke.';
      case CardRank.four:
        return 'Frage an alle: Stelle eine Frage. '
            'Du kannst eine eigene Frage stellen oder eine zufällige Frage '
            'aus dem Spiel wählen.';
      case CardRank.five:
        return 'Kategorie: Wähle eine Kategorie (z.B. Automarken, Cocktails). '
            'Reihum sagt jeder etwas aus dieser Kategorie. Wer nichts mehr weiß '
            'oder sich wiederholt, trinkt.';
      case CardRank.six:
        return 'Alle weiblichen Spieler trinken einen Schluck.';
      case CardRank.seven:
        return 'Heaven: Alle müssen mit dem Finger nach oben zeigen. '
            'Die Person, die es als letztes macht, trinkt.';
      case CardRank.eight:
        return 'Trinkpartner: Wähle eine Person als Trinkpartner. '
            'Immer wenn du trinkst, muss dein Partner auch trinken – '
            'bis die nächste 8 gezogen wird.';
      case CardRank.nine:
        return 'Reimen: Denke dir ein Wort aus. Reihum muss jeder ein Wort sagen, '
            'das sich darauf reimt. Wer nichts mehr weiß, trinkt.';
      case CardRank.ten:
        return 'Alle männlichen Spieler trinken einen Schluck.';
      case CardRank.jack:
        return 'Neue Regel: Denke dir eine neue Regel aus '
            '(z.B. jeder muss vor dem Trinken "Prost" sagen). '
            'Die Regel gilt, bis eine neue Regel gezogen wird.';
      case CardRank.queen:
        return 'Ich hab noch nie…: Sage einen Satz, der mit '
            '"Ich hab noch nie…" beginnt. Alle, die das doch schon gemacht '
            'haben, müssen trinken.';
      case CardRank.king:
        return 'König – Kings Cup: Schütte einen Schluck deines Getränks '
            'in den Kings Cup. Der Spieler, der den 4. König zieht, '
            'muss den Kings Cup austrinken.';
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

// ============================================================================
//  Spielscreen (Circle)
// ============================================================================

/// Widget, das eine Spielkarte visualisiert.
///
/// - Wenn [faceDown] true ist, wird die Rückseite angezeigt.
/// - Ansonsten Vorderseite mit Rang + Suit-Symbol.
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
      // Rückseite (hier ein simples blaues Design).
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
            'Circle',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      );
    }

    // Vorderseite mit Rang + Suit.
    final rank = card.rank.shortLabel;
    final suitSymbol = card.suit.symbol;
    final suitColor = card.suit.color;

    return Container(
      width: 120,
      height: 170,
      decoration: BoxDecoration(
        color: Colors.white,
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
            // Ecke oben links
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
            // Ecke unten rechts
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
            // Großes Suit-Symbol in der Mitte.
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

/// Spielscreen für Circle.
///
/// Wichtige Zustände:
/// - 52er Deck mit Karten
/// - aktueller Spieler
/// - aktuelle Karte
/// - wie viele Könige wurden schon gezogen?
/// - Animations-Controller für:
///   * Kamera-Zoom beim Start
///   * Hoch/Runter-Schweben der Karte
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

  bool _isAwaitingTap = false; // true: Karte schwebt, Spieler muss tippen
  bool? _tapSuccess; // null: noch nicht getippt, true/false: Ergebnis
  String? _currentQuestionText; // Frage aus der Datenbank (falls genutzt)

  // Animation für Kamera-Zoom (Start des Spiels).
  late final AnimationController _zoomController;
  late final Animation<double> _zoomAnimation;

  // Animation für hoch/runter schwebende Karte.
  late final AnimationController _cardFloatController;

  String get _currentPlayerName => widget.players[_currentPlayerIndex];

  @override
  void initState() {
    super.initState();
    _deck = createFullCircleDeck();

    // Kamera-Zoom von kleiner Ansicht auf den Tisch/Becher.
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _zoomAnimation = CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeOut,
    );
    _zoomController.forward();

    // Controller für Schwebe-Animation der Karte.
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

  /// Bereitet eine neue Karte vor:
  /// - zufällige Karte aus Deck ziehen
  /// - Deck verkleinern
  /// - Schwebeanimation starten
  void _prepareNewCard() {
    if (_deck.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keine Karten mehr im Deck. Spiel vorbei!'),
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

  /// Wird aufgerufen, wenn der Spieler auf die Karte tippt.
  void _onCardTap() {
    if (!_isAwaitingTap || _currentCard == null) return;

    final value = _cardFloatController.value; // 0.0 - 1.0
    // Fenster für "perfekter Moment": mittlere 40%.
    final success = value > 0.3 && value < 0.7;

    setState(() {
      _tapSuccess = success;
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
    // Info-Text für Könige.
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
        title: const Text('Circle – Spiel'),
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
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text('Verbleibende Karten im Deck: ${_deck.length}'),
            const SizedBox(height: 16),

            // Tischbereich mit Becher + Karte, in Kamera-Zoom-Animation.
            Expanded(
              child: ScaleTransition(
                scale: _zoomAnimation,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Kings Cup (Becher in der Mitte).
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.brown.shade400,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Kings Cup',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Animierte Karte (schwebt) bzw. Platzhaltertext.
                      if (_currentCard != null)
                        AnimatedBuilder(
                          animation: _cardFloatController,
                          builder: (context, child) {
                            // Einfaches Hoch/Runter-Schweben
                            final dy = _isAwaitingTap
                                ? sin(_cardFloatController.value * pi) * -10
                                : 0.0;
                            return Transform.translate(
                              offset: Offset(0, dy),
                              child: child,
                            );
                          },
                          child: GestureDetector(
                            onTap: _onCardTap,
                            child: PlayingCardView(
                              card: _currentCard!,
                              faceDown: _isAwaitingTap,
                            ),
                          ),
                        )
                      else
                        const Text(
                          'Bereit? Wähle "Karte vorbereiten", um eine neue '
                          'Karte zu ziehen.',
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 16),

                      if (_isAwaitingTap)
                        const Text(
                          'Tippe im perfekten Moment auf die Karte.\n'
                          'Triffst du nicht gut → Strafschluck! 🥤',
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Detailbereich zu gezogener Karte (Regeltext etc.).
            if (_currentCard != null && !_isAwaitingTap) ...[
              Card(
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
                      const SizedBox(height: 8),
                      Text(
                        _currentCard!.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentCard!.description,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      if (_tapSuccess != null)
                        Text(
                          _tapSuccess == true
                              ? 'Du hast die Karte sauber gezogen. 👌'
                              : 'Du hast die Karte nicht perfekt getroffen – '
                                'Strafschluck! 🥤',
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
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                      const SizedBox(height: 8),

                      // Zusätzliche Buttons für Frage-Karten (4 und Dame).
                      if (isQuestionCard) ...[
                        const Divider(),
                        const Text(
                          'Frage wählen:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  // Eigene Frage -> wir zeigen nur Hinweistext.
                                  setState(() {
                                    _currentQuestionText =
                                        'Eigene Frage: Denkt euch selbst eine '
                                        'Frage aus und stellt sie der Runde.';
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
                                      // "Frage an alle"
                                      _currentQuestionText =
                                          QuestionRepository
                                              .randomGeneralQuestion();
                                    } else {
                                      // Dame: "Ich hab noch nie..."
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

            // Buttons am unteren Rand:
            // - Karte vorbereiten (nur wenn keine Karte aktiv oder Runde vorbei)
            // - Nächster Spieler (wenn Karte bereits ausgewertet ist)
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
                    onPressed:
                        (_currentCard != null && !_isAwaitingTap)
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
