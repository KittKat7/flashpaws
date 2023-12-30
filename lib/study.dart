library study;
import 'package:flashpaws/flashcard.dart';

part 'review.dart';
part 'practice.dart';

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