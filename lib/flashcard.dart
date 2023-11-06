
class Flashcard {

  static List<Flashcard> cards = [];

  static List<String> getDecks([List<String> baseDeck = const []]) {
    String baseDeckString = baseDeck.join('/').toLowerCase();
    List<String> decks = [];
    for (Flashcard c in cards) {
      if (!decks.contains(c.deckString) && c.deckString.startsWith(baseDeckString)) {
        decks.add(c.deckString.toLowerCase());
      }
    }
    return decks;
  }

  String key;
  List<String> deck;
  List<String> values;
  List<String> tags;

  Record get id { return (deck, key); }
  String get deckString { return deck.join('/').toLowerCase(); }

  Flashcard(this.key, this.deck, this.values, {List<String>? tags}) : tags = tags ?? [];


} // end Flashcard