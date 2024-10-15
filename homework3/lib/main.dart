import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Matching Game'),
      ),
      body: Column(
        children: [
          const ScoreAndTimer(),
          Expanded(
            child: CardGrid(),
          ),
        ],
      ),
    );
  }
}

class ScoreAndTimer extends StatelessWidget {
  const ScoreAndTimer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Score: ${gameModel.score}'),
          Text('Time: ${gameModel.elapsedTime} seconds'),
        ],
      ),
    );
  }
}

class CardGrid extends StatelessWidget {
  const CardGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context);
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
      ),
      itemCount: gameModel.cards.length,
      itemBuilder: (context, index) {
        return CardWidget(card: gameModel.cards[index], index: index);
      },
    );
  }
}

class CardWidget extends StatelessWidget {
  final CardModel card;
  final int index;

  const CardWidget({Key? key, required this.card, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<GameModel>(context, listen: false).flipCard(index);
      },
      child: AnimatedBuilder(
        animation: card.controller ?? const AlwaysStoppedAnimation(0),
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY((card.controller?.value ?? 0) * 3.14),
            alignment: Alignment.center,
            child: card.isFaceUp
                ? Container(
                    color: Colors.white,
                    child: Center(
                      child: Text(
                        card.value,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.blue,
                    child: const Center(
                      child: Text(
                        '?',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class GameModel extends ChangeNotifier {
  List<CardModel> cards = [];
  int score = 0;
  int elapsedTime = 0;
  Timer? timer;
  List<int> flippedCardIndexes = [];
  int pairsFound = 0;
  final int totalPairs = 8; // Adjust this for different difficulty levels

  GameModel() {
    initGame();
  }

  void initGame() {
    cards = _generateCardPairs(totalPairs);
    cards.shuffle();

    // Reset game state
    score = 0;
    elapsedTime = 0;
    flippedCardIndexes = [];
    pairsFound = 0;
    startTimer();
    notifyListeners();
  }

  List<CardModel> _generateCardPairs(int numberOfPairs) {
    const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    List<CardModel> cardPairs = [];

    // Ensure we don't exceed the number of available letters
    if (numberOfPairs > alphabet.length) {
      throw ArgumentError('Number of pairs exceeds available unique letters.');
    }

    // Randomly select letters and create pairs
    List<String> selectedLetters = alphabet.split('')..shuffle();
    for (int i = 0; i < numberOfPairs; i++) {
      String letter = selectedLetters[i];
      cardPairs.add(CardModel(value: letter));
      cardPairs.add(CardModel(value: letter));
    }

    return cardPairs;
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedTime++;
      notifyListeners();
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void flipCard(int index) {
    if (flippedCardIndexes.length == 2 || cards[index].isFaceUp) {
      return;
    }

    cards[index].flip();
    flippedCardIndexes.add(index);

    if (flippedCardIndexes.length == 2) {
      checkMatch();
    }

    notifyListeners();
  }

  void checkMatch() {
    final card1 = cards[flippedCardIndexes[0]];
    final card2 = cards[flippedCardIndexes[1]];

    if (card1.value == card2.value) {
      score += 10;
      pairsFound++;
      flippedCardIndexes.clear();

      if (pairsFound == totalPairs) {
        stopTimer();
        // Trigger victory logic here
      }
    } else {
      score = max(0, score - 5);
      Future.delayed(const Duration(milliseconds: 500), () {
        for (var index in flippedCardIndexes) {
          cards[index].flip();
        }
        flippedCardIndexes.clear();
        notifyListeners();
      });
    }

    notifyListeners();
  }

  void showVictoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: Text('You won!\nScore: $score\nTime: $elapsedTime seconds'),
          actions: <Widget>[
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                initGame();
              },
            ),
          ],
        );
      },
    );
  }
}

class CardModel {
  final String value;
  bool isFaceUp = false;
  AnimationController? controller;

  CardModel({required this.value});

  void flip() {
    isFaceUp = !isFaceUp;
    if (controller != null) {
      if (isFaceUp) {
        controller!.forward();
      } else {
        controller!.reverse();
      }
    }
  }
}
