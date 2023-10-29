Map<String, List<Flashcard>> decks = {};
Map<String, List<String>> topics = {};
Map<String, List<Flashcard>> tagGroups = {};


class Flashcard {  

  String key;
  String deck;
  String topic;
  Record get id {
    return (deck.toLowerCase(), key.toLowerCase());
  }
  List<String> values;
  List<String> tags;

  Flashcard(this.key, this.values, this.deck, this.topic, this.tags);
}