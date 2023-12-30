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
      child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [icon, MarkD(text)])
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
  Widget wrap = Align(alignment: Alignment.topLeft, child: Wrap(alignment: WrapAlignment.start, children: children,));
  return wrap;
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
    onPressed: (context) => Navigator.of(context).pushNamed(getRoute('multichoice'))
  );

  Widget wrap = Align(alignment: Alignment.topCenter, child: Wrap(alignment: WrapAlignment.start, children: [practice, review, multitest]));

  Widget startBtns = GridView.count(
    primary: false,
    shrinkWrap: true,
    crossAxisCount: 3,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 4,
    children: [practice, review, multitest],
  );

  startBtns = Padding(padding: const EdgeInsets.only(bottom: 10), child: wrap);

  return startBtns;
}//e startBtns()


/// themeMenuPopup
/// A popuop that allows the user to enter information, and create a card from the provided
/// information.
void themeModePopup(BuildContext context) {

  var themeModeList = Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ElevatedButton(
        onPressed: () => getAppThemeMode(context).setLightMode(),
        child: MarkD(getString('btn_light_theme'))),
      ElevatedButton(
        onPressed: () => getAppThemeMode(context).setDarkMode(),
        child: MarkD(getString('btn_dark_theme'))),
      ElevatedButton(
        onPressed: () => getAppThemeMode(context).setAutoMode(),
        child: MarkD(getString('btn_auto_theme'))),
  ]);

  // showDialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: MarkD(getString('btn_theme_brightness_menu')),
        content: themeModeList,
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

/// themeMenuPopup
/// A popuop that allows the user to enter information, and create a card from the provided
/// information.
void themeColorPopup(BuildContext context) {

  List<String> colors = getAvailableThemeColors;

  List<Widget> colorButtons = [];

  for (String c in colors) {
    colorButtons.add(
      ElevatedButton(
        onPressed:() => getColorTheme(context).setColor(c),
        child: Text("${c.substring(0, 1).toUpperCase()}${c.substring(1).toLowerCase()}"))
    );
  }

  var themeModeList = Column(
    mainAxisSize: MainAxisSize.min,
    children: colorButtons);

  // showDialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: MarkD(getString('btn_theme_brightness_menu')),
        content: themeModeList,
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
}//e themeColorPopup


//TODO create confidence buttons.
class LongPressWidget extends StatelessWidget {

  final Widget child;
  final void Function() onLongPress;

  LongPressWidget({required this.child, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    // create widget
    Widget longPress = GestureDetector(onLongPress: () => onLongPress(), child: child,);
    return longPress;
  }
}

class ConfidenceBtn extends StatelessWidget {
  
  final Icon icon;
  final void Function() onPressed;
  final void Function() onLongPress;
  ConfidenceBtn({required this.icon, required this.onPressed, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    var iconBtn = IconButton(onPressed: onPressed, icon: icon);
    var longPressWidget = LongPressWidget(onLongPress: onLongPress, child: iconBtn);
    return longPressWidget;
  }
}

Widget confidenceBtns(Flashcard currentCard, void Function(int p) setConfidence) {
  Widget expand(Widget child) {
    return Expanded(flex: 1, child: child);
  }
  var confidenceBtns = Row(children: [
    expand(ConfidenceBtn(
      icon: Icon(currentCard.confidence == 0? Icons.remove_circle : Icons.remove_circle_outline),
      onPressed: () => setConfidence(0),
      onLongPress: () => setConfidence(-1),
    )),
    expand(ConfidenceBtn(
      icon: Icon(currentCard.confidence == 1? Icons.circle : Icons.circle_outlined),
      onPressed: () => setConfidence(1),
      onLongPress: () => setConfidence(-1),
    )),
    expand(ConfidenceBtn(
      icon: Icon(currentCard.confidence == 2? Icons.add_circle : Icons.add_circle_outline),
      onPressed: () => setConfidence(2),
      onLongPress: () => setConfidence(-1),
    )),
  ]);
  return confidenceBtns;
}


//TODO
class CreateCardAlert extends StatefulWidget {
  const CreateCardAlert({super.key, required this.onConfirm});

  final Function(String, String, List<String>, [List<String>?]) onConfirm;
  @override
  State<CreateCardAlert> createState() => _CreateCardAlertState();
}

class _CreateCardAlertState extends State<CreateCardAlert> {

  String key = "";
  List<String> values = [""];
  String deck = "";
  String tags = "";

  late TextField keyField;
  List<TextField> valueFields = [];
  late TextField deckField;
  late TextField tagField;

  void _updateValues(int n, String text) {
    if (text.isEmpty && n != 0) {
      values.removeAt(n);
      valueFields.removeAt(n);
      return;
    }
    values[n] = text;
    if (n == valueFields.length - 1) {
      //create new text box
      valueFields.add(TextField(
        onChanged: (t) => setState(() => _updateValues(n+1, t)),
        decoration: InputDecoration(hintText: getString('hint_create_new_card_values_fake')),
        keyboardType: TextInputType.multiline,
        maxLines: null,
      ));
      values.add("");
    }
  }

  @override
  void initState() {
    // Create the text fields
    keyField = TextField(
      onChanged: (t) => key = t,
      decoration: InputDecoration(hintText: getString('hint_create_new_card_key')),
      keyboardType: TextInputType.multiline,
      maxLines: null,
    );//e keyField
    valueFields.add(TextField(
      onChanged: (t) => setState(() => _updateValues(0, t)),
      decoration: InputDecoration(hintText: getString('hint_create_new_card_values')),
      keyboardType: TextInputType.multiline,
      maxLines: null,
    ));//e valueFields
    deckField = TextField(
      onChanged: (t) => deck = t,
      decoration: InputDecoration(hintText: getString('hint_create_new_card_deck')),
      keyboardType: TextInputType.multiline,
      maxLines: null,
    );//e deckField
    tagField = TextField(
      onChanged: (t) => tags = t,
      decoration: InputDecoration(hintText: getString('hint_create_new_card_tags')),
      keyboardType: TextInputType.multiline,
      maxLines: null,
    );//e tagField

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> allFields = [];
    allFields.add(keyField);
    allFields.addAll(valueFields);
    allFields.add(deckField);
    allFields.add(tagField);

    Column column = Column(
      mainAxisSize: MainAxisSize.min,
      children: allFields,
    );

    var alert = AlertDialog(
      title: MarkD(getString('header_create_new_card')),
      content: SingleChildScrollView(child: column,),
      actions: <Widget>[
        // cancel btn
        TextButton(
          child: Text(getString('cancel')),
          onPressed: () {
            // Handle cancel
            Navigator.of(context).pop();
          },
        ),
        // confirm button
        TextButton(
          child: Text(getString('confirm')),
          onPressed: () {
            if (key.isEmpty) {
              alertPopup(
                context,
                getString('err_hdr_create_empty_key'),
                getString('err_msg_create_empty_key'),
                [getString('confirm')],
                [(){}]);
              return;
            }
            if (values[0].isEmpty) {
              alertPopup(
                context,
                getString('err_hdr_create_empty_values'),
                getString('err_msg_create_empty_values'),
                [getString('confirm')],
                [(){}]);
              return;
            }

            // Handle confirm
            // Get the text, and ensure propper formatting.
            // Ensure deck ends with '/'
            if (!deck.endsWith("/")) deck += "/";
            List<String> tagsList = [];
            // Ensure tags start with '#'
            for (String t in tags.split(" ")) {
              if (t.isEmpty) continue;
              t = t.trim();
              if (t.startsWith('#')) {
                tagsList.add(t);
              } else {
                tagsList.add('#$t');
              }//e if else
            }//e for

            // Remove duplicate values and empty values
            while (values.contains("")) {
              values.remove("");
            }//e while
            values = values.toSet().toList();

            for (Flashcard card in Flashcard.cards) {
              if (card.key == key && card.deck == deck) {
                alertPopup(
                  context,
                  getString('err_hdr_create_duplicate_card'),
                  getString('err_msg_create_duplicate_card'),
                  [getString('confirm')],
                  [(){}]);
                return;
              }//e if
            }//e for

            Navigator.of(context).pop();
            widget.onConfirm(key, deck, values, tagsList);
          },//e onPressed
        ),//e TextButton
      ],//e <Widget>[]
    );

    return alert;
  }
}//e _CreateCardWidgetState


/// createCardPopup
/// A popuop that allows the user to enter information, and create a card from the provided
/// information.
void createCardPopup(
    BuildContext context,
    Function(String, String, List<String>, [List<String>?]) onConfirm,
  ) {
  // showDialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CreateCardAlert(onConfirm: onConfirm);
    }//e builder
  );//e showDialog
}//e createCardPopup

/// alertPopup
/// Pops up an alert on screen using the parameters provided.
void alertPopup(
  BuildContext context,
  String title,
  String message,
  List<String> btnStrings,
  List<Function> btnActions
) {

  List<Widget> actions = [];
  for (int i = 0; i < btnStrings.length && i < btnActions.length; i++) {
    actions.add(
      TextButton(
        child: MarkD(btnStrings[i]),
        onPressed: () { Navigator.of(context).pop(); btnActions[i](); },
      )
    );
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: MarkD(title),
        content: MarkD(message),
        actions: actions,
      );
    }//e builder
  );//e showDialog
}//e alertPopup