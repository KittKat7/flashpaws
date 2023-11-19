import 'package:flashpaws/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:flutterkat/flutterkat.dart';
import 'package:flutterkat/graphics.dart';
import 'package:flutterkat/theme.dart';
import 'package:flutterkat/widgets.dart';

/// DeckBtn
/// A custom ElevatedButton which is used exclusivly for buttons allowing the user to modify the
/// deck filter.
class LayerBtn extends StatelessWidget {
  /// What text should be displayed on the button.
  final String layer;
  /// What to do when the button is pressed, should either be adding to the filter or setting the
  /// filter.
  final void Function() onPressed;
  /// Whether or not the button has already been pressed, and should be grayed out.
  final bool isApplied;

  /// Constructor
  const LayerBtn({super.key, required this.layer, required this.onPressed, this.isApplied = false});

  @override
  Widget build(BuildContext context) {
    // the child the button will display.
    Widget child = MarkD(layer);
    // The styling for not selected buttons.
    ButtonStyle priStyle = ElevatedButton.styleFrom(backgroundColor: colorScheme(context).primaryContainer);
    // The styling for selected buttons.
    ButtonStyle selStyle = ElevatedButton.styleFrom(backgroundColor: colorScheme(context).surface);
    // If the button is selected (isApplied) style is the selected style, otherwise style is the
    // primary style
    ButtonStyle style = isApplied ? selStyle : priStyle;

    // The button.
    Widget button = ElevatedButton(style: style, onPressed: () => onPressed(), child: child);
    // pad the button.
    Widget paddedBtn = Padding(padding: const EdgeInsets.all(5), child: button);

    // return an ElevatedButton with the selected style, with the correct onPressed, and correct
    // child.
    return paddedBtn;
  } //end Build
} //end DeckBtn

/// CardBtn //TODO comment
class CardBtn extends StatelessWidget {
  /// The card to be displayed.
  final Flashcard card;
  /// The function to run when the button is pressed.
  final void Function() onPressed;
  final void Function(BuildContext) onLongPress;

  /// Constructor
  const CardBtn({super.key, required this.card, required this.onPressed, required this.onLongPress});

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
            side: BorderSide(width: 1, color: colorScheme(context).primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () { onPressed(); },
          onLongPress: () { onLongPress(context); },
          child: MarkD("## ${card.key}\n${card.deck}\n___\n${card.values[0]}"),
        ),
      ))
    ]);
  } //end Build
} //end CardBtn

///TODO comment
class StartBtn extends StatelessWidget {
  /// The card to be displayed.
  final String text;
  final Icon icon;
  /// The function to run when the button is pressed.
  final void Function() onPressed;

  /// Constructor
  const StartBtn({super.key, required this.icon, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {

    ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: colorScheme(context).background
    );

    return ElevatedButton(
      style: style,
      onPressed: () => print("flashcard"),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [icon, MarkD(text)])
    );
  } //end Build
} //end CardBtn

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
  children.add(LayerBtn(
    layer: getString('btn_all_cards'),
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
    children.add(LayerBtn(
      layer: layer,
      onPressed: () { Flashcard.setFilter(str.split("/")); updateState(); },
      isApplied: true
    ));
  } //end for
  
  // For every layer in the provided list of layers, add a button which onPress pushes that layer
  // onto the filter.
  for (String layer in layers) {
    children.add(LayerBtn(
      layer: layer,
      onPressed: () { Flashcard.pushFilter(layer); updateState(); }
    ));
  } //end for
  // Create and returnt he GridView widget with the created list of buttons, and return it.
  // Widget grid = GridView.count(
  //   primary: false,
  //   shrinkWrap: true,
  //   crossAxisCount: 3,
  //   mainAxisSpacing: 10,
  //   crossAxisSpacing: 10,
  //   childAspectRatio: 4,
  //   children: children,
  // );
  Widget grid = Align(alignment: Alignment.topLeft, child: Wrap(alignment: WrapAlignment.start, children: children,));
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
      CardBtn(
        card: card,
        onPressed: () { print("CARD ${card.id}"); },
        onLongPress: (context) {
          confirmPopup(
            context,
            getString('header_delete_card'),
            getString('msg_confirm_delete_card', [card.id]),
            () { Flashcard.removeCard(card); updateState(); }
          );
        },
      )
    );
  }
  Widget grid = Column(children: children,);
  return grid;
} //end cardBtns

/// startBtns
/// //TODO
Widget startBtns() {

  Widget flashcard = StartBtn(
    icon: const Icon(Icons.play_arrow),
    text: getString('btn_flashcards'),
    onPressed: () => print("//TODO flashcard"));
  Widget infinite = StartBtn(
    icon: const Icon(Icons.fast_forward),
    text: getString('btn_infinite'),
    onPressed: () => print("//TODO infinite"));
  Widget multichoice = StartBtn(
    icon: const Icon(Icons.check_box),
    text: getString('btn_multitest'),
    onPressed: () => print("//TODO multichoice"));

  Widget startBtns = GridView.count(
    primary: false,
    shrinkWrap: true,
    crossAxisCount: 3,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 4,
    children: [flashcard, infinite, multichoice],
  );

  startBtns = Padding(padding: const EdgeInsets.only(bottom: 10), child: startBtns);

  return startBtns;
}

/// createCardPopup
/// //TODO
void createCardPopup(
    BuildContext context,
    String title,
    Function(String, String, List<String>, [List<String>?]) onConfirm,
  ) {
  final TextEditingController keyController = TextEditingController();
  final TextEditingController deckController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController tagController = TextEditingController();

  TextField keyField = TextField(
    decoration: InputDecoration(hintText: getString('hint_create_new_card_key')),
    controller: keyController,
    keyboardType: TextInputType.multiline,
    maxLines: null,
  );

  TextField deckField = TextField(
    decoration: InputDecoration(hintText: getString('hint_create_new_card_deck')),
    controller: deckController,
    keyboardType: TextInputType.multiline,
    maxLines: null,
  );

  TextField valueField = TextField(
    decoration: InputDecoration(hintText: getString('hint_create_new_card_values')),
    controller: valueController,
    keyboardType: TextInputType.multiline,
    maxLines: null,
  );

  TextField tagField = TextField(
    decoration: InputDecoration(hintText: getString('hint_create_new_card_tags')),
    controller: tagController,
    keyboardType: TextInputType.multiline,
    maxLines: null,
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      var column = Column(
        mainAxisSize: MainAxisSize.min,
        children: [keyField, deckField, valueField, tagField]
      );
      return AlertDialog(
        title: MarkD(title),
        content: column,
        actions: <Widget>[
          TextButton(
            child: Text(getString('cancel')),
            onPressed: () {
              // Handle cancel
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(getString('confirm')),
            onPressed: () {
              // Handle confirm
              String key = keyController.text;
              String deck = deckController.text;
              if (!deck.endsWith("/")) deck += "/";
              String valuesStr = valueController.text;
              if (valuesStr.endsWith("\n+++")) valuesStr = valuesStr.substring(0, valuesStr.length-4);
              List<String> values = valuesStr.split("\n+++\n");
              List<String> tags = [];
              for (String t in tagController.text.split(" ")) {
                if (t.isEmpty) continue;
                t = t.trim();
                if (t.startsWith('#')) {
                  tags.add(t);
                } else {
                  tags.add('#$t');
                } //end if else
              } //end for

              Navigator.of(context).pop();
              onConfirm(key, deck, values, tags);
            },
          ),
        ],
      );
    },
  );
}