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
  }//e Build
}//e DeckBtn

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
  }//e Build
}//e CardBtn

///TODO comment
class StartBtn extends StatelessWidget {
  /// The card to be displayed.
  final String text;
  final Icon icon;
  /// The function to run when the button is pressed.
  final void Function(BuildContext) onPressed;

  /// Constructor
  const StartBtn({super.key, required this.icon, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {

    ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: colorScheme(context).background
    );

    return ElevatedButton(
      style: style,
      onPressed: () => onPressed(context),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [icon, MarkD(text)])
    );
  }//e Build
}//e CardBtn

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
  }//e for
  
  // For every layer in the provided list of layers, add a button which onPress pushes that layer
  // onto the filter.
  for (String layer in layers) {
    children.add(LayerBtn(
      layer: layer,
      onPressed: () { Flashcard.pushFilter(layer); updateState(); }
    ));
  }//e for
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
}//e deckBtns

/// cardBtns
/// Creates and returns a column of Flashcards.
/// @param List<Flashcard> cards The cards that need to be displayed.
/// @param void Function() updateState A function which updates the page.
/// @return Column A Column of Flashcard buttons.
Widget cardBtns(List<Flashcard> cards, void Function() updateState) {
  List<Widget> children = [];
  
  // for every card in the list of cards, create a button, and add it to a list.
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
          );//e confirmPopup
        },//e onLongPress
      )//e CardBtn
    );//e add
  }//e for

  // Using the generated list of buttons, create and return the Column.
  Widget column = Column(children: children,);
  return column;
}//e cardBtns

/// startBtns
/// //TODO
Widget startBtns() {

  Widget practice = StartBtn(
    icon: const Icon(Icons.play_arrow),
    text: getString('btn_practice'),
    onPressed: (context) => Navigator.of(context).pushNamed(getRoute('practice'))
  );
  Widget review = StartBtn(
    icon: const Icon(Icons.fast_forward),
    text: getString('btn_review'),
    onPressed: (context) => Navigator.of(context).pushNamed(getRoute('review'))
  );
  Widget multitest = StartBtn(
    icon: const Icon(Icons.check_box),
    text: getString('btn_multitest'),
    onPressed: (p1) => print("//TODO MultiTest")
  );

  Widget startBtns = GridView.count(
    primary: false,
    shrinkWrap: true,
    crossAxisCount: 3,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 4,
    children: [practice, review, multitest],
  );

  startBtns = Padding(padding: const EdgeInsets.only(bottom: 10), child: startBtns);

  return startBtns;
}

/// createCardPopup
/// A popuop that allows the user to enter information, and create a card from the provided
/// information.
void createCardPopup(
    BuildContext context,
    String title,
    Function(String, String, List<String>, [List<String>?]) onConfirm,
  ) {
  // The text controllers for the text entry fields
  final TextEditingController keyController = TextEditingController();
  final TextEditingController deckController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController tagController = TextEditingController();

  // Create the text fields
  TextField keyField = TextField(
    decoration: InputDecoration(hintText: getString('hint_create_new_card_key')),
    controller: keyController,
    keyboardType: TextInputType.multiline,
    maxLines: null,
  );//e keyField
  TextField deckField = TextField(
    decoration: InputDecoration(hintText: getString('hint_create_new_card_deck')),
    controller: deckController,
    keyboardType: TextInputType.multiline,
    maxLines: null,
  );//e deckField
  TextField valueField = TextField(
    decoration: InputDecoration(hintText: getString('hint_create_new_card_values')),
    controller: valueController,
    keyboardType: TextInputType.multiline,
    maxLines: null,
  );//e valueField
  TextField tagField = TextField(
    decoration: InputDecoration(hintText: getString('hint_create_new_card_tags')),
    controller: tagController,
    keyboardType: TextInputType.multiline,
    maxLines: null,
  );//e tagField

  // showDialog
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
              // Get the text, and ensure propper formatting.
              String key = keyController.text;
              String deck = deckController.text;
              // Ensure deck ends with '/'
              if (!deck.endsWith("/")) deck += "/";
              String valuesStr = valueController.text;
              if (valuesStr.endsWith("\n+++")) valuesStr = valuesStr.substring(0, valuesStr.length-4);
              List<String> values = valuesStr.split("\n+++\n");
              List<String> tags = [];
              // Ensure tags start with '#'
              for (String t in tagController.text.split(" ")) {
                if (t.isEmpty) continue;
                t = t.trim();
                if (t.startsWith('#')) {
                  tags.add(t);
                } else {
                  tags.add('#$t');
                }//e if else
              }//e for

              Navigator.of(context).pop();
              onConfirm(key, deck, values, tags);
            },//e onPressed
          ),//e TextButton
        ],//e <Widget>[]
      );//e AlertDialog
    },//e builder
  );//e showDialog
}//e createCardPopup


/// createCardPopup
/// A popuop that allows the user to enter information, and create a card from the provided
/// information.
void themeMenuPopup(BuildContext context) {

  var themeModeRow = Wrap(
    children: [
      ElevatedButton(onPressed: () => getAppThemeMode(context).setLightMode(), child: MarkD(getString('btn_light_theme'))),
      ElevatedButton(onPressed: () => getAppThemeMode(context).setDarkMode(), child: MarkD(getString('btn_dark_theme'))),
      ElevatedButton(onPressed: () => getAppThemeMode(context).setAutoMode(), child: MarkD(getString('btn_auto_theme'))),
  ]);

  // showDialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      var column = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          themeModeRow,
        ]
      );
      return AlertDialog(
        title: MarkD(getString('btn_theme_brightness_menu')),
        content: column,
        actions: <Widget>[
          TextButton(
            child: Text(getString('close')),
            onPressed: () {
              Navigator.of(context).pop();
            },//e onPressed
          ),//e TextButton
        ],//e <Widget>[]
      );//e AlertDialog
    },//e builder
  );//e showDialog
}//e createCardPopup