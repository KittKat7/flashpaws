
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class Flashcard {

  /// The list of all cards.
  static List<Flashcard> cards = [];
  /// The filter for sorting cards
  static List<String> _filter = [];
  /// The cards that match the current filter
  static List<Flashcard> filteredCards = [];
  /// the subdecks that match the current filter
  static List<String> filteredDecks = [];

  /// get filter Returns the current filter.
  static List<String> get filter { return _filter; }
  static String get filterString { 
    String str = _filter.join('/');
    if (!str.startsWith('#')) {
      str = validateDeckStr(str);
    } else {
      // TODO validate tags
      
    }//e if else
    return str;
  }//e get filterString

  int confidence;

  /// setFilter
  /// Sets the filter to the passed parameter, and updates the filtered cards and subdecks.
  /// @param List<String> filter The new filter
  static void setFilter(List<String> filter) {
    _filter = filter;
    filteredCards = getFilteredCards(cards);
    filteredDecks = getLayers(filteredCards);
  }

  /// pushFilter
  /// Adds a filter layer onto the filter stack.
  /// Also updates the list of cards and subdecks to match the current filter.
  /// param String layer The layer to be added to the filter.
  static void pushFilter(String layer) {
    print("layer - $layer");
    _filter.add(layer);
    print("filterstr - $filterString");
    filteredCards = getFilteredCards(filteredCards);
    filteredDecks = getLayers(filteredCards);
  }//e pushFilter

  /// popFilter
  /// Removes the top layer from the filter and returns it.
  /// Also updates the list of cards and subdecks to match the current filter.
  /// @returns String the popped string from the filter.
  static String popFilter() {
    String tmp = filter[-1];
    filter.removeAt(filter.length -1);
    filteredCards = getFilteredCards(cards);
    filteredDecks = getLayers(filteredCards);
    return tmp;
  }//e popFilter

  /// getFilteredCards
  /// Takes a list of Flashcards as the parameter, and filter those cards based on the current
  /// filter.
  /// @param List<Flashcard> tempCards
  /// @returns List<Flashcards> cards matching the filter
  static List<Flashcard> getFilteredCards(List<Flashcard> listOfCards) {
    // If the filter is empty, return all the cards.
    if (filter.isEmpty) return cards;
    // The list of cards to return.
    List<Flashcard> returnList = [];

    for (Flashcard c in listOfCards) {
      if (c.deck.startsWith(filterString)) {
        returnList.add(c);
      }//e if
      // for tags
      for (String tag in c.tags) {
        if (tag.startsWith(filterString)) {
          returnList.add(c);
        }//e if
      }//e for
    }//e for
    return returnList;
  }//e getFilteredCards

  static List<Flashcard> getShuffledFilteredCards() {
    List<Flashcard> tmpList = List<Flashcard>.from(filteredCards);
    tmpList.shuffle();
    return tmpList;
  }

  /// getSubdecks
  /// Takes a list of cards and gets the a list of all subdecks from these cards matching the
  /// current filter.
  /// @param List<Flashcards> The list of cards to get subdecks from
  /// @returns List<String> a list of all subdecks from the provided cards, matching the active
  /// filter
  static List<String> getLayers(List<Flashcard> listOfCards) {
    // List of subdeck layers to return.
    List<String> retList = [];

    // Go through the list of provided cards
    for (Flashcard c in listOfCards) {
      // If the deck of the card does not start with the filter, skip this card
      if (!c.deck.startsWith(filterString)) continue;
      // Get the deck for the card with the filter removed from the deck
      String tmpStr = c.deck.substring(filterString.length);
      // If the subdeck starts with "/", remove the leading "/"
      if (tmpStr.startsWith("/")) tmpStr = tmpStr.substring(1);
      // Get the next layer in the deck
      tmpStr = tmpStr.split("/")[0];
      // Add the layer to the list if it is not allready added AND the layer is not empty
      if (!retList.contains(tmpStr) && tmpStr.isNotEmpty) retList.add(tmpStr);
    }//e for

    // Do the same things for tags
    // Go through the list of provided cards
    for (Flashcard c in listOfCards) {
      for (String tag in c.tags) {
        print("tags ${c.tags}");
        // If this tag of the card does not start with the filter, skip this tag
        if (!tag.startsWith("#${filterString.substring(1)}")) { continue; }
        // Get the tag for the card with the filter removed from the tag
        String tmpStr = tag.substring(filterString.length);
        if (filterString.length == 1) tmpStr = "#$tmpStr";
        // If the subtag starts with "/", remove the leading "/"
        if (tmpStr.startsWith("/")) tmpStr = tmpStr.substring(1);
        // Get the next layer in the tag
        tmpStr = tmpStr.split("/")[0];
        // Add the layer to the list if it is not allready added AND the layer is not empty
        if (!retList.contains(tmpStr) && tmpStr.isNotEmpty) retList.add(tmpStr);
      }//e for
    }//e for
    return retList;
  }//e getLayers

  /// newCard
  /// Creates a new card, adds it to the list, and save it to persistant storage.
  /// @param String key The key for the card.
  /// @param String deck The deck the card is a part of.
  /// @param List<String> valuesIn A list of answers for the card.
  /// @param List<String>? tagsIn A list of tags the card is part of.
  static void newCard(String key, String deck, List<String> valuesIn, [List<String>? tagsIn]) {
    // Format / trim paramaters
    key = key.trim();
    deck = validateDeckStr(deck);
    List<String> values = [for (String v in valuesIn) v.trim()];
    tagsIn ??= [];
    List<String> tags = [for (String t in tagsIn) t.trim()];

    // Create the new card and check to see if it has already been added. If it has, return and do
    // nothing.
    Flashcard card = Flashcard(key, deck, values, tags);
    String id = card.id;
    for (int i = 0; i < cards.length; i++) {
      if (cards[i].id == id) {
        cards[i] = card;
        return;
      }//e if
    }//e for

    // Add the card, update and sort filtered cards and layers.
    cards.add(card);
    filteredCards = getFilteredCards(filteredCards);
    filteredDecks = getLayers(filteredCards);
    filteredDecks.sort((a, b) => a.compareTo(b));
    filteredCards.sort((a, b) => a.id.compareTo(b.id));
    // Save to persistant.
    saveCards();
  }//e newCard

  /// removeCard
  /// Removes a card from the list of cards.
  /// @param Flashcard card The card to be removed.
  static void removeCard(Flashcard card) {
    // Remove the card from the list and update persistant.
    cards.remove(card);
    saveCards();
  }//e removeCard

  static late Box<dynamic> hiveBox;

  static saveCards([List<Flashcard>? cardsIn]) {
    List<Flashcard> saveCards = cardsIn??=cards;
    List<String> cardsJson = [];
    for (Flashcard card in saveCards) {
      cardsJson.add(jsonEncode(card.toJson()));
    }
    hiveBox.put('flashcards', cardsJson);
  }//e saveCards

  /// Validates a string to make sure it is formatted correctly as a deck variable.
  /// 
  /// Takes a string and ensures that is is formatted correctlty to work as a deck variable and
  /// meets the requirements for a card to function as expected. Then returns the validated string.
  static String validateDeckStr(String str) {
    // Trim string.
    str = str.trim();
    // Ensure starting slash.
    if (!str.startsWith('/')) {
      str = '/$str';
    }//e if
    // Ensure ending slash.
    if (!str.endsWith('/')) {
      str = '$str/';
    }//e if
    return str;
  }//e validateDeck

  /// The key for the flashcard
  String key;
  // TODO BUG - Inconsistancies with how deck is stored. Add consistant '/' to start of and end of
  // deck. deck will be treated like a file path starting with / and ending with /.
  // EX /path/to/file/thisisacard
  /// The deck the flashcard is in. Treated like a file path, starting and ending with /
  String _deck;
  set deck(String deck) { _deck = deck; }
  String get deck { return _deck.endsWith("/") ? _deck : "$_deck/"; }
  String get deckStr { return deck.substring(0, deck.length); }
  /// All possible answers for the flashcard, index 0 is the correct one
  List<String> values;
  /// All tags that this card has
  List<String> tags;

  /// get id Returns the unique id of the card.
  String get id { return deck + key; }

  /// Constructor
  Flashcard(this.key, this._deck, this.values, [List<String>? tags, int? confidence]) : tags = tags ?? [], confidence = confidence ?? -1;

  @override
  String toString() {
    return id;
  }

  /// toJson
  /// Returns a map that is ready to be encoded to JSON.
  /// @return Map<String, dynamic> A map ready to be encoded to JSON.
  Map<String, dynamic> toJson() => {
    'key': key,
    'deck': deck,
    'values': values,
    'tags': tags,
    'cnfdnc': confidence
  };//e toJson

  /// fromJson
  /// Takes a JSON map and returns a Flashcard created with that data.
  /// @param Map<String, dynamic> json The JSON style Map to create a Flashcard with.
  /// @return Flashcard A Flashcard created from the Map.
  factory Flashcard.fromJson(Map<String, dynamic> json) =>
    Flashcard(json['key'], json['deck'], List<String>.from(json['values']), List<String>.from(json['tags']), json['cnfdnc']);
  //e fromJson
}//e Flashcard