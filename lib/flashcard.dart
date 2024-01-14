
import 'dart:collection';
import 'dart:convert';

import 'package:flashpaws/inout.dart';

class Flashcard {

  /// The list of all cards.
  static List<Flashcard> cards = [];
  static void addCard(Flashcard card) {
    if (cards.contains(card)) {
      cards.remove(card);
    }
    cards.add(card);
  }//e addCard()
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
      str = validateTagStr(str);
    }//e if else
    return str;
  }//e get filterString

  int confidence;

  /// setFilter
  /// Sets the filter to the passed parameter, and updates the filtered cards and subdecks.
  /// @param List<String> filter The new filter
  static void setFilter(List<String>? filter) {
    // If null is passed, don't change the filter.
    _filter = filter ?? _filter;
    // Update the filteredCards list.
    filteredCards = getFilteredCards(cards);
    // Update the filteredDecks list.
    filteredDecks = getLayers(filteredCards);
  }//e setFilter()

  /// pushFilter
  /// Adds a filter layer onto the filter stack.
  /// Also updates the list of cards and subdecks to match the current filter.
  /// param String layer The layer to be added to the filter.
  static void pushFilter(String layer) {
    _filter.add(layer);
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
    // If the filter is empty, sort and return all the cards.
    if (filter.isEmpty) {
      cards.sort((a, b) => a.id.toLowerCase().compareTo(b.id.toLowerCase()));
      return cards;
    }//e if

    // The list of cards to return.
    List<Flashcard> returnList = [];

    // For every card in the passed list of cards, determin if the card is in the filter.
    for (Flashcard c in listOfCards) {
      // If the cards deck starts with the filter, add the card to the return list.
      if (c.deck.startsWith(filterString)) {
        returnList.add(c);
      }//e if
      // For every tag the card has.
      for (String tag in c.tagsList) {
        // If the tag starts with the applied filter, add it to the list to return.
        if (tag.startsWith(filterString)) {
          returnList.add(c);
        }//e if
      }//e for
    }//e for

    // Sort the list of cards to return, then return the list.
    returnList.sort((a, b) => a.id.toLowerCase().compareTo(b.id.toLowerCase()));
    return returnList;
  }//e getFilteredCards

  /// Returns a new list with all the filtered cards, shuffled in a random order.
  /// 
  /// Creates a copy list from filtered cards. Then used the shuffle method to randomize the list
  /// and returns the shuffled list.
  static List<Flashcard> getShuffledFilteredCards() {
    // Get a temp list of cards as a copy list from filtered cards.
    List<Flashcard> tmpList = List<Flashcard>.from(filteredCards);
    // Randomize the order of the temp list.
    tmpList.shuffle();
    // Return the temp list.
    return tmpList;
  }//e getShuffledFilteredCards()

  /// getSubdecks
  /// Takes a list of cards and gets the a list of all subdecks from these cards matching the
  /// current filter.
  /// @param List<Flashcards> The list of cards to get subdecks from
  /// @returns List<String> a list of all subdecks from the provided cards, matching the active
  /// filter
  static List<String> getLayers(List<Flashcard> listOfCards) {
    // List of subdeck layers to return.
    List<String> retList = [];

    List<String> deckList = [];
    List<String> tagList = [];
    if (filterString.startsWith('/')) deckList = _getDeckLayers(listOfCards);
    if (filterString.startsWith('#') || filterString == '/') tagList = _getTagLayers(listOfCards);

    // Sort the decks and tags by alphabetical order, capitalization does not matter.
    deckList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    tagList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    // Combined the deck and tag lists into a single list with the decks coming first.
    retList = deckList + tagList;
    
    // Return the combined list.
    return retList;
  }//e getLayers

  static List<String> _getDeckLayers(List<Flashcard> cardsList) {
    // Go through the list of provided cards
    List<String> deckList = [];
    for (Flashcard c in cardsList) {
      // If the deck of the card does not start with the filter, skip this card
      if (!c.deck.startsWith(filterString)) continue;
      // Get the deck for the card with the filter removed from the deck
      String tmpStr = c.deck.substring(filterString.length);
      // If the subdeck starts with "/", remove the leading "/"
      if (tmpStr.startsWith("/")) tmpStr = tmpStr.substring(1);
      // Get the next layer in the deck
      tmpStr = tmpStr.split("/")[0];
      // Add the layer to the list if it is not allready added AND the layer is not empty
      if (!deckList.contains(tmpStr) && tmpStr.isNotEmpty) deckList.add(tmpStr);
    }//e for
    return deckList;
  }//e _getDeckLayers()

  static List<String> _getTagLayers(List<Flashcard> cardsList) {
    // Go through the list of provided cards
    List<String> tagList = [];
    for (Flashcard c in cardsList) {
      for (String tag in c.tagsList) {
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
        if (!tagList.contains(tmpStr) && tmpStr.isNotEmpty) tagList.add(tmpStr);
      }//e for
    }//e for
    return tagList;
  }//e _getTagLayers()



  /// newCard
  /// Creates a new card, adds it to the list, and save it to persistant storage. If a card with the
  /// same ID already exists, that card will be deleted and replaces with the new card.
  /// @param String key The key for the card.
  /// @param String deck The deck the card is a part of.
  /// @param List<String> valuesIn A list of answers for the card.
  /// @param List<String>? tagsIn A list of tags the card is part of.
  static void newCard(String key, String deck, List<String> valuesIn, [List<String>? tagsIn]) {
    // Format / trim paramaters
    key = validateKey(key);
    deck = validateDeckStr(deck);
    List<String> values = validateValues(valuesIn);
    tagsIn ??= [];
    List<String> tags = validateTagList(tagsIn);

    // Search and remove all cards the same as the new card.
    Flashcard card = Flashcard(
      key: key,
      deck: deck,
      values: values,
      tagStr: tags.join(' '));
    for (int i = 0; i < cards.length; i++) {
      if (cards[i] == card) {
        cards.removeAt(i);
      }//e if
    }//e for

    // Add the card, update cards and layers.
    addCard(card);
    filteredCards = getFilteredCards(filteredCards);
    filteredDecks = getLayers(filteredCards);
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

    // Replace ' ' space chars with '_' underscores.
    str = str.replaceAll(r' ', '_');

    // Return the validated deck.
    return str;
  }//e validateDeck

  /// Validates the tag to see if it is valid.
  static String validateTag(String tag) {
    tag = tag.trim();
    if (!tag.startsWith('#')) {
      tag = '#$tag';
    }
    if (tag.endsWith('/')) {
      tag = tag.substring(0, tag.length - 1);
    }
    tag.replaceAll(r' ', '_');
    return tag;
  }//e validateTag()

  /// Validates the tag list.
  static List<String> validateTagList(List<String> tags) {
    List<String> _tags = [for (String t in tags) t.trim()];

    _tags = _tags.toSet().toList();
    _tags.remove('');

    for (int i = 0; i < _tags.length; i++) {
      _tags[i] = validateTag(_tags[i]);
    }//e for

    _tags = _tags.toSet().toList();
    _tags.remove('');

    return _tags;
  }//e validateTagList()

  /// Validates the tag string.
  static String validateTagStr(String tags) {
    return validateTagList(tags.split(' ')).join(' ');
  }//e validateTagStr()

  /// Checks all cards to find another card with [id] already exists.
  static bool cardIDExists(String id) {
    for(Flashcard c in cards) {
      if (c.id == id) return true;
    }
    return false;
  }//e cardIDExists()

  /// Validate the list of values.
  static List<String> validateValues(List<String> values) {
    List<String> _values = [for (String v in values) v.trim()];
    _values = LinkedHashSet<String>.from(_values).toList();
    _values.remove('');
    return _values;
  }//e validateValues()

  /// Validates the key.
  static String validateKey(String key) {
    if (key.isEmpty) key = 'EMPTY';
    key = key.trim();
    return key;
  }//e validateKey()

  /// The key for the flashcard
  String key;
  /// The deck the flashcard is in. Treated like a file path, starting and ending with /
  String _deck;
  set deck(String deck) { _deck = validateDeckStr(deck); }
  String get deck { return _deck; }
  /// All possible answers for the flashcard, index 0 is the correct one
  List<String> _values;
  List<String> get values { return List<String>.from(_values); }
  set values(List<String> values) { _values = List<String>.from(values); }
  /// All tags that this card has
  String _tags;
  List<String> get tagsList { return List<String>.from(_tags.split(' ')); }
  set tagsList(List<String> tags) { _tags = List<String>.from(tags).join(' '); }
  // ignore: unnecessary_getters_setters
  String get tagStr { return _tags; }
  set tagStr(String str) { _tags = str; }

  /// get id Returns the unique id of the card.
  String get id { return deck + key; }

  /// Constructor
  Flashcard({
    required this.key,
    required String deck,
    required List<String> values,
    String tagStr = '',
    int? confidence
    }) :
    _deck = validateDeckStr(deck),
    _values = values,
    _tags = tagStr,
    confidence = confidence ?? -1;
  //e Flashcard()

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
    'tags': tagStr,
    'cnfdnc': confidence
  };//e toJson

  /// fromJson
  /// Takes a JSON map and returns a Flashcard created with that data.
  /// @param Map<String, dynamic> json The JSON style Map to create a Flashcard with.
  /// @return Flashcard A Flashcard created from the Map.
  factory Flashcard.fromJson(Map<String, dynamic> json) =>
    Flashcard(
      key: json['key'],
      deck: json['deck'],
      values: List<String>.from(json['values']),
      tagStr: json['tags'],
      confidence: json['cnfdnc']);
  //e fromJson
  
  /// Returns the hashcode of [id] as it is used to distinguish the cards.
  @override
  int get hashCode => id.hashCode;
  
  /// Returns true if [other]'s [id] and [id] are the same. Otherwise returns false.
  @override
  bool operator ==(Object other) {
    return other is Flashcard? id == other.id : false;
  }//e ==
  
}//e Flashcard