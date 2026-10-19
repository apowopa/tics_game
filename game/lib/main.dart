import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/concept_pair.dart';
import 'widgets/feedback_banner.dart';
import 'widgets/memory_card_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AIMemoramaApp());
}

enum BoardSizeOption {
  fast(6, 'Rápido (6 pares • 12 cartas)'),
  medium(10, 'Medio (10 pares • 20 cartas)'),
  full(15, 'Completo (15 pares • 30 cartas)');

  final int pairs;
  final String label;
  const BoardSizeOption(this.pairs, this.label);
}

class AIMemoramaApp extends StatelessWidget {
  const AIMemoramaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memorama IA: Fundamentos de Agentes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1120),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF38BDF8),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MemoryGameScreen(),
    );
  }
}

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final Random _random = Random();
  BoardSizeOption? _selectedMode;
  int _activePairsCount = 6;

  List<MemoryCardModel> _cards = [];
  MemoryCardModel? _firstSelected;
  MemoryCardModel? _secondSelected;
  bool _isLocked = false;

  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _attempts = 0;
  final Set<int> _matchedPairIds = {};

  bool? _feedbackSuccess;
  String _feedbackTitle = 'Une cada concepto (morado) con su definición (azul)';
  String _feedbackMessage = 'Toca dos cartas para voltearlas.';
  Timer? _mismatchTimer;

  @override
  void dispose() {
    _mismatchTimer?.cancel();
    super.dispose();
  }

  void _initBoard(int pairsCount) {
    _mismatchTimer?.cancel();
    _activePairsCount = pairsCount;

    final List<ConceptPair> pool = List<ConceptPair>.from(kAllConceptPairs)
      ..shuffle(_random);
    final List<ConceptPair> chosenPairs = pool.take(pairsCount).toList();

    final List<MemoryCardModel> generated = [];
    for (final pair in chosenPairs) {
      generated.add(
        MemoryCardModel(
          uid: 'c_${pair.id}',
          pairId: pair.id,
          type: CardType.concept,
          text: pair.concept,
          pair: pair,
        ),
      );
      generated.add(
        MemoryCardModel(
          uid: 'd_${pair.id}',
          pairId: pair.id,
          type: CardType.definition,
          text: pair.definition,
          pair: pair,
        ),
      );
    }
    generated.shuffle(_random);

    setState(() {
      _cards = generated;
      _firstSelected = null;
      _secondSelected = null;
      _isLocked = false;
      _score = 0;
      _streak = 0;
      _bestStreak = 0;
      _attempts = 0;
      _matchedPairIds.clear();
      _feedbackSuccess = null;
      _feedbackTitle = 'Une cada concepto (morado) con su definición (azul)';
      _feedbackMessage = 'Toca dos cartas para voltearlas.';
    });
  }

  void _shuffleBoard() {
    _mismatchTimer?.cancel();
    HapticFeedback.mediumImpact();
    setState(() {
      for (final card in _cards) {
        if (!card.isMatched) {
          card.isFlipped = false;
          card.isShaking = false;
        }
      }
      _firstSelected = null;
      _secondSelected = null;
      _isLocked = false;
      _cards.shuffle(_random);
      _feedbackSuccess = null;
      _feedbackTitle = 'Cartas barajeadas';
      _feedbackMessage = 'Se mezclaron las posiciones del tablero.';
    });
  }

  void _onCardTap(MemoryCardModel card) {
    // Allow player to immediately tap a new card even during mismatch delay
    if (_isLocked && _firstSelected != null && _secondSelected != null) {
      _mismatchTimer?.cancel();
      setState(() {
        _firstSelected!.isFlipped = false;
        _secondSelected!.isFlipped = false;
        _firstSelected!.isShaking = false;
        _secondSelected!.isShaking = false;
        _firstSelected = null;
        _secondSelected = null;
        _isLocked = false;
      });
    }

    if (card.isFlipped || card.isMatched) {
      return;
    }

    HapticFeedback.selectionClick();

    setState(() {
      card.isFlipped = true;
    });

    if (_firstSelected == null) {
      _firstSelected = card;
      return;
    }

    _secondSelected = card;
    _attempts++;
    _evaluateTurn(_firstSelected!, _secondSelected!);
  }

  void _evaluateTurn(MemoryCardModel first, MemoryCardModel second) {
    if (first.pairId == second.pairId) {
      HapticFeedback.lightImpact();
      setState(() {
        first.isMatched = true;
        second.isMatched = true;
        _matchedPairIds.add(first.pairId);
        _streak++;
        if (_streak > _bestStreak) {
          _bestStreak = _streak;
        }
        final int pointsEarned = 10 * _streak;
        _score += pointsEarned;
        _firstSelected = null;
        _secondSelected = null;

        final String streakTag = _streak > 1
            ? ' • ¡Racha x$_streak! (+$pointsEarned pts)'
            : ' (+10 pts)';
        _feedbackSuccess = true;
        _feedbackTitle = '¡Correcto: ${first.pair.concept}!$streakTag';
        _feedbackMessage = first.pair.feedback;
      });

      if (_matchedPairIds.length == _activePairsCount) {
        Future.delayed(const Duration(milliseconds: 550), () {
          if (mounted) _showVictoryDialog();
        });
      }
    } else {
      final conceptCard = first.type == CardType.concept ? first : second;
      setState(() {
        _isLocked = true;
        _streak = 0;
        first.isShaking = true;
        second.isShaking = true;
        _feedbackSuccess = false;
        _feedbackTitle = 'Tip (${conceptCard.pair.concept}):';
        _feedbackMessage = conceptCard.pair.feedback;
      });

      _mismatchTimer = Timer(const Duration(milliseconds: 1100), () {
        if (!mounted) return;
        setState(() {
          first.isFlipped = false;
          second.isFlipped = false;
          first.isShaking = false;
          second.isShaking = false;
          _firstSelected = null;
          _secondSelected = null;
          _isLocked = false;
        });
      });
    }
  }

  void _showCardDetailModal(MemoryCardModel card) {
    if (!card.isFlipped && !card.isMatched) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(
              card.type == CardType.concept
                  ? Icons.lightbulb_rounded
                  : Icons.menu_book_rounded,
              color: const Color(0xFF38BDF8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                card.type == CardType.concept ? 'Concepto' : 'Definición',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
        content: Text(
          card.text,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        title: const Column(
          children: [
            Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFFBBF24),
              size: 48,
            ),
            SizedBox(height: 8),
            Text(
              '¡Ronda Completada!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Encontraste los $_activePairsCount pares en esta partida.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatPill('Puntos', '$_score', const Color(0xFF38BDF8)),
                  _buildStatPill(
                    'Mejor Racha',
                    'x$_bestStreak',
                    const Color(0xFFF59E0B),
                  ),
                  _buildStatPill(
                    'Turnos',
                    '$_attempts',
                    const Color(0xFFA78BFA),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _openGlossary();
            },
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('Glosario'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _initBoard(_activePairsCount);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Otra Ronda'),
          ),
        ],
      ),
    );
  }

  void _openGlossary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GlossarySheet(matchedIds: _matchedPairIds),
    );
  }

  ({int cols, int rows}) _calculateGridDimensions(
    int totalCards,
    double width,
    double height,
  ) {
    final bool isPortrait = height >= width;
    if (totalCards <= 12) {
      return isPortrait ? (cols: 3, rows: 4) : (cols: 4, rows: 3);
    } else if (totalCards <= 20) {
      return isPortrait ? (cols: 4, rows: 5) : (cols: 5, rows: 4);
    } else {
      return isPortrait ? (cols: 5, rows: 6) : (cols: 6, rows: 5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final bool isMobile = width < 640;

            if (_cards.isEmpty) {
              final BoardSizeOption defaultOption = width < 520
                  ? BoardSizeOption.fast
                  : width < 900
                      ? BoardSizeOption.medium
                      : BoardSizeOption.full;
              _selectedMode = defaultOption;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _initBoard(defaultOption.pairs);
              });
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                _buildTopBar(isMobile),
                _buildScoreHeader(isMobile),
                FeedbackTickerBar(
                  isSuccess: _feedbackSuccess,
                  title: _feedbackTitle,
                  message: _feedbackMessage,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 8 : 16,
                      4,
                      isMobile ? 8 : 16,
                      8,
                    ),
                    child: LayoutBuilder(
                      builder: (context, boardConstraints) {
                        final bWidth = boardConstraints.maxWidth;
                        final bHeight = boardConstraints.maxHeight;
                        final dims = _calculateGridDimensions(
                          _cards.length,
                          bWidth,
                          bHeight,
                        );
                        final double spacing = isMobile ? 6.0 : 10.0;

                        final double cellWidth =
                            (bWidth - (dims.cols - 1) * spacing) / dims.cols;
                        final double cellHeight =
                            (bHeight - (dims.rows - 1) * spacing) / dims.rows;
                        final double aspectRatio =
                            (cellWidth / cellHeight).clamp(0.45, 2.4);

                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: dims.cols,
                            mainAxisSpacing: spacing,
                            crossAxisSpacing: spacing,
                            childAspectRatio: aspectRatio,
                          ),
                          itemCount: _cards.length,
                          itemBuilder: (context, index) {
                            final card = _cards[index];
                            return MemoryCardWidget(
                              key: ValueKey(card.uid),
                              card: card,
                              onTap: () => _onCardTap(card),
                              onLongPress: () => _showCardDetailModal(card),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isMobile) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 18,
        6,
        isMobile ? 8 : 18,
        2,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF0EA5E9)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.hub_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Memorama IA',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isMobile ? 15 : 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          PopupMenuButton<BoardSizeOption>(
            tooltip: 'Cantidad de cartas en pantalla',
            initialValue: _selectedMode,
            onSelected: (option) {
              _selectedMode = option;
              _initBoard(option.pairs);
            },
            itemBuilder: (context) => BoardSizeOption.values
                .map(
                  (opt) => PopupMenuItem(
                    value: opt,
                    child: Text(opt.label),
                  ),
                )
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.grid_view_rounded,
                    size: 14,
                    color: Color(0xFF38BDF8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_activePairsCount pares',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Barajear cartas',
            visualDensity: VisualDensity.compact,
            onPressed: _shuffleBoard,
            icon: const Icon(
              Icons.shuffle_rounded,
              color: Color(0xFFA78BFA),
              size: 20,
            ),
          ),
          IconButton(
            tooltip: 'Glosario de estudio',
            visualDensity: VisualDensity.compact,
            onPressed: _openGlossary,
            icon: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF38BDF8),
              size: 20,
            ),
          ),
          IconButton(
            tooltip: 'Nueva partida',
            visualDensity: VisualDensity.compact,
            onPressed: () => _initBoard(_activePairsCount),
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHeader(bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 18,
        vertical: 3,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatPill('Puntos', '$_score', const Color(0xFF38BDF8)),
          _buildDivider(),
          _buildStatPill(
            'Racha',
            _streak > 0 ? '🔥 x$_streak' : 'x0',
            _streak > 1 ? const Color(0xFFF59E0B) : Colors.white70,
          ),
          _buildDivider(),
          _buildStatPill(
            'Pares',
            '${_matchedPairIds.length}/$_activePairsCount',
            const Color(0xFF10B981),
          ),
          _buildDivider(),
          _buildStatPill('Turnos', '$_attempts', const Color(0xFFA78BFA)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 20,
      color: Colors.white12,
    );
  }

  Widget _buildStatPill(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
