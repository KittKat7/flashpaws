part of 'study.dart';

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