
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

  /// setFilter
  /// Sets the filter to the passed parameter, and updates the filtered cards and subdecks.
  /// @param List<String> filter The new filter
  static void setFilter(List<String> filter) {
    _filter = filter;
    filteredCards = getFilteredCards(cards);
    filteredDecks = getSubdecks(filteredCards);
  }

  /// pushFilter
  /// Adds a filter layer onto the filter stack.
  /// Also updates the list of cards and subdecks to match the current filter.
  /// param String layer The layer to be added to the filter.
  static void pushFilter(String layer) {
    _filter.add(layer);

    filteredCards = getFilteredCards(filteredCards);
    filteredDecks = getSubdecks(filteredCards);
  } //end pushFilter

  /// popFilter
  /// Removes the top layer from the filter and returns it.
  /// Also updates the list of cards and subdecks to match the current filter.
  /// @returns String the popped string from the filter.
  static String popFilter() {
    String tmp = filter[-1];
    filter.removeAt(-1);
    filteredCards = getFilteredCards(cards);
    filteredDecks = getSubdecks(filteredCards);
    return tmp;
  } //end popFilter

  /// getFilteredCards
  /// Takes a list of Flashcards as the parameter, and filter those cards based on the current
  /// filter.
  /// @param List<Flashcard> tempCards
  /// @returns List<Flashcards> cards matching the filter
  static List<Flashcard> getFilteredCards(List<Flashcard> listOfCards) {
    List<Flashcard> returnList = [];
    for (Flashcard c in listOfCards) {
      if (c.deck.startsWith(filter.join("/"))) {
        returnList.add(c);
      } //end if
    } //end for
    return returnList;
  } //end getFilteredCards

  /// getSubdecks
  /// Takes a list of cards and gets the a list of all subdecks from these cards matching the
  /// current filter.
  /// @param List<Flashcards> The list of cards to get subdecks from
  /// @returns List<String> a list of all subdecks from the provided cards, matching the active
  /// filter
  static List<String> getSubdecks(List<Flashcard> listOfCards) {
    // List of subdeck layers to return
    List<String> retList = [];
    // Join the filter stack into a single string
    String filterStr = filter.join("/");
    // Go through the list of provided cards
    for (Flashcard c in listOfCards) {
      // If the deck of the card does not start with the filter, skip this card
      if (!c.deck.startsWith(filterStr)) continue;
      // Get the deck for the card with the filter removed from the deck
      String tmpStr = c.deck.substring(filterStr.length);
      // If the subdeck starts with "/", remove the leading "/"
      if (tmpStr.startsWith("/")) tmpStr = tmpStr.substring(1);
      // Get the next layer in the deck
      tmpStr = tmpStr.split("/")[0];
      // Add the layer to the list if it is not allready added AND the layer is not empty
      if (!retList.contains(tmpStr) && tmpStr.isNotEmpty) retList.add(tmpStr);
    } //end for
    return retList;
  } //end getSubdecks

  /// The key for the flashcard
  String key;
  /// The deck the flashcard is in
  String deck;
  /// All possible answers for the flashcard, index 0 is the correct one
  List<String> values;
  /// All tags that this card has
  List<String> tags;

  /// get id Returns the unique id of the card.
  Record get id { return (deck, key); }

  /// Constructor
  Flashcard(this.key, this.deck, this.values, {List<String>? tags}) : tags = tags ?? [];


} //end Flashcard