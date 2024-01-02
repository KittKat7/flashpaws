import 'dart:math';
import 'package:flashpaws/flashcard.dart';

class MultiChoice {

  static MultiChoice? test;

  // need to track key, deck, currect answer, other answers
  late List<Flashcard> deck;
  Map<String, List<String>> values = {};
  Map<String, String?> userAnswers = {};

  late Duration timeElapsed;
  late DateTime _initialTime = DateTime.now();
  late DateTime _endTime = DateTime.now();
  set endTime(DateTime endTime) {
    _endTime = endTime;
  }

  int index = 0;

  MultiChoice() {
    _initialTime = DateTime.now();
    var unrandomDeck = Flashcard.filteredCards;
    unrandomDeck.shuffle();
    deck = unrandomDeck;

    for (Flashcard c in deck) {
      
      String key = c.id;

      values[key] = [c.values[0]];
      if (c.values.length > 1) {

        var falseValues = c.values.sublist(1);
        
        while (values[key]!.length < 4 && falseValues.isNotEmpty) {
          int falseIndex = Random().nextInt(falseValues.length);
          values[key]!.add(falseValues[falseIndex]);
          falseValues.removeAt(falseIndex);
        }//e while
      }//e if
      else {
        List<Flashcard> tmpDeck = List<Flashcard>.from(deck);
        tmpDeck.remove(c);
        while (values[key]!.length < 4 && tmpDeck.isNotEmpty) {
          int randIndex = Random().nextInt(tmpDeck.length);
          Flashcard randCard = tmpDeck[randIndex];
          tmpDeck.remove(randCard);
          String randValue = randCard.values[Random().nextInt(randCard.values.length)];
          values[key]!.add(randValue);
        }//e while
      }//e else
      values[key]!.shuffle();
    }//e for
  }//e MultiChoice()

  bool hasNextCard() {
    if (index + 1 == deck.length) return false;
    return true;
  }

  bool hasPrevCard() {
    if (index <= 0) return false;
    return true;
  }

  ///
  /// ```
  /// Map<String, dynamic> {
  ///   'id': id,
  ///   'key': key,
  ///   'values': cardValues
  /// };
  /// ```
  Map<String, dynamic> getCard() {
    String id = deck[index].id;
    String key = deck[index].key;
    List<String> cardValues = values[id]!;

    Map<String, dynamic> ret = {
      'id': deck[index].deck,
      'key': key,
      'values': cardValues,
    };

    return ret;
  }

  Map<String, dynamic> nextCard() {
    if (index < deck.length) index++;

    return getCard();
  }//e nextCard()

  Map<String, dynamic> prevCard() {
    if (index > 0) index--;
    
    return getCard();
  }//e nextCard()

  void answerCard(String? answer) {
    userAnswers[deck[index].id] = answer;
  }//e answerCard()

  String? getEnteredAnswer() {
    return userAnswers[deck[index].id];
  }

  ///
  /// ```
  /// Map<String, num> ret = {
  ///    'points': points,
  ///    'total': total,
  ///    'percent': percent,
  ///  };
  ///  ```
  Map<String, dynamic> getResults() {
    int total = deck.length;
    int points = 0;
    for (Flashcard c in deck) {
      String id = c.id;
      String correctAnswer = c.values[0];
      if (correctAnswer == userAnswers[id]) {
        points++;
      }//e if
    }//e for
    double percent = points / total;

    Map<String, dynamic> ret = {
      'points': points,
      'total': total,
      'percent': percent,
      'duration': _endTime.difference(_initialTime),
    };
    return ret;
  }//e getResults()

}//e MultiChoice