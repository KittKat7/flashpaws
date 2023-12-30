part of 'study.dart';

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