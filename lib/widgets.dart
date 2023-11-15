import 'package:flashpaws/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:flutterkat/theme.dart';
import 'package:flutterkat/widgets.dart';

/// DeckBtn
/// A custom ElevatedButton which is used exclusivly for buttons allowing the user to modify the
/// deck filter.
class DeckBtn extends StatelessWidget {
  /// What text should be displayed on the button.
  final String layer;
  /// What to do when the button is pressed, should either be adding to the filter or setting the
  /// filter.
  final void Function() onPressed;
  /// Whether or not the button has already been pressed, and should be grayed out.
  final bool isApplied;

  /// Constructor
  const DeckBtn({super.key, required this.layer, required this.onPressed, this.isApplied = false});

  @override
  Widget build(BuildContext context) {
    // the child the button will display.
    Widget child = MarkD(layer);
    // The styling for not selected buttons.
    ButtonStyle priStyle = ElevatedButton.styleFrom(backgroundColor: colorScheme(context).primary);
    // The styling for selected buttons.
    ButtonStyle selStyle = ElevatedButton.styleFrom(backgroundColor: colorScheme(context).surface);
    // If the button is selected (isApplied) style is the selected style, otherwise style is the
    // primary style
    ButtonStyle style = isApplied ? selStyle : priStyle;

    // return an ElevatedButton with the selected style, with the correct onPressed, and correct
    // child.
    return ElevatedButton(style: style, onPressed: () => onPressed(), child: child);
  }
} //end DeckBtn

class CardBtn extends StatelessWidget {
  /// The card to be displayed.
  final Flashcard card;
  /// The function to run when the button is pressed.
  final void Function() onPressed;

  /// Constructor
  const CardBtn({super.key, required this.card, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 1, right: 1),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.all(10),
            backgroundColor: Theme.of(context).canvasColor,
            side: BorderSide(width: 1, color: colorScheme(context).primary)
          ),
          onPressed: () { onPressed(); },
          child: MarkD("## ${card.key}\n${card.deck}\n___\n${card.values[0]}")
        ))
      )
    ]);
  }

}

/// deckBtns
/// This methd builds a list of DeckBtn based on the provided decks.
/// @param List<String> layers A list of layers that need a button.
/// @param void Function() updateState A function which when calls updates the state of the page
/// reloading and updating which buttons are displayed.
/// @return Widget A GridView widget containing all generated DeckBtns.
Widget deckBtns(List<String> layers, void Function() updateState) {
  // All the buttons generated and to be displayed.
  List<Widget> children = [];
  // Add a button to reset the filter and display all decks / cards.
  children.add(DeckBtn(
    layer: "//TODO All",
    onPressed: () { Flashcard.setFilter([]); updateState(); },
    isApplied: true,
  ));

  // For every layer in the applied filter, make a button allowing going directly back to that
  // layer.
  for (int i = 0; i < Flashcard.filter.length; i++) {
    // A string containing the layers that the button should revert to.
    String str = "";
    // The top layer, which should be displayed as the text for the button.
    String layer = Flashcard.filter[i];
    // For every layer up to the layer i, add it to str, then add layer i.
    for (int j = 0; j < i; j++) {
      str += "${Flashcard.filter[j]}/";
    } str += Flashcard.filter[i];
    // Add the DeckBtn with the string of layers split by "/".
    children.add(DeckBtn(
      layer: layer,
      onPressed: () { Flashcard.setFilter(str.split("/")); updateState(); },
      isApplied: true
    ));
  } //end for
  
  // For every layer in the provided list of layers, add a button which onPress pushes that layer
  // onto the filter.
  for (String layer in layers) {
    children.add(DeckBtn(
      layer: layer,
      onPressed: () { Flashcard.pushFilter(layer); updateState(); }
    ));
  } //end for
  // Create and returnt he GridView widget with the created list of buttons, and return it.
  Widget grid = GridView.count(
    primary: false,
    shrinkWrap: true,
    crossAxisCount: 3,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 4,
    children: children,
  );
  return grid;
} //end deckBtns

/// cardBtns
/// Creates and returns a column of flashcards.
/// @param List<Flashcard> cards The cards that need to be displayed.
/// @param 
Widget cardBtns(List<Flashcard> cards, void Function() updateState) {
  List<Widget> children = [];
  
  for (Flashcard card in cards) {
    children.add(
      CardBtn(card: card, onPressed: () { print("CARD ${card.id}"); })
    );
  }
  Widget grid = Column(children: children,);
  return grid;
}


