import 'package:flashpaws/flashcard.dart';

abstract class Study {
  late int _index;
  late bool _isShowingValue;
  late List<Flashcard> _deck;
  late Flashcard _currentCard;

  int get index { return _index; }
  int get length { return _deck.length; }
  bool get isShowingValue { return _isShowingValue; }
  String get currentKey { return _currentCard.key; }
  String get currentValue { return _currentCard.values[0]; }
  String get currentDeck { return _currentCard.deck; }
  int get confidence { return _currentCard.confidence; }

  Study() {
    _index = 0;
    _isShowingValue = false;
    _deck = Flashcard.getShuffledFilteredCards();
    _currentCard = _deck[_index];
  }//e Review()

  void flipCard() {
    _isShowingValue = !_isShowingValue;
  }//e flipCard()

  void changeCard() {
    _isShowingValue = false;
  }//e _updateCurrentCard()

  void setConfidence(int cnfdnc) {
    _currentCard.confidence = cnfdnc;
  }//e setConfidence()

}//e Review

class Review extends Study {
  static Review review = Review();

  Review() {
    _index = 0;
    _deck = Flashcard.getShuffledFilteredCards();
    _currentCard = _deck[_index];
  }//e Review()

  bool hasNextCard() {
    if (_index + 1 == _deck.length) return false;
    return true;
  }//e hasNextCard()

  bool hasPrevCard() {
    if (_index <= 0) return false;
    return true;
  }//e hasPrevCard()

  void _updateCurrentCard([int offset = 0]) {
    super.changeCard();
    _index += offset;
    _currentCard = _deck[_index];
  }//e _updateCurrentCard()

  void nextCard() {
    if (!hasNextCard()) return;
    _updateCurrentCard(1);
  }//e nextCard()

  void prevCard() {
    if (!hasPrevCard()) return;
    _updateCurrentCard(-1);
  }//e prevCard()

  Map<String, num> getData() {
    double score = 0;
    double percentScore = 0;

    for (Flashcard c in _deck) {
      if (c.confidence != -1) {
        score += c.confidence / 2;
      }//e if
    }//e for
    percentScore = (score / _deck.length) * 100;
    percentScore.round();
    return {
      'points': score,
      'total': _deck.length,
      'percent': percentScore
    };
  }//e getData()

}//e Review

class Practice extends Study {
  static Practice practice = Practice();

  int _cardsPracticed = 0;

  int get cardsPracticed { return _cardsPracticed; }

  Practice() {
    _index = 0;
    _deck = Flashcard.getShuffledFilteredCards();
    _currentCard = _deck[_index];
  }//e Review()

  void _updateCurrentCard([int offset = 0]) {
    super.changeCard();
    _index += offset;
    _currentCard = _deck[_index];
  }//e _updateCurrentCard()

  void nextCard() {
    Flashcard currCard = _currentCard;
    _deck = _deck.sublist(1);
    _deck.shuffle();
    _deck.add(currCard);
    _cardsPracticed++;
    _updateCurrentCard();
  }//e nextCard()

}//e Review