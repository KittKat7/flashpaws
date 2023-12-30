import 'package:flashpaws/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:flutterkat/flutterkat.dart';
import 'package:flutterkat/graphics.dart';
import 'package:flutterkat/theme.dart';
import 'package:flutterkat/widgets.dart';

/// A Flutter widget representing a customizable layer button.
///
/// The [LayerBtn] widget displays a button with text specified by the [layer]
/// parameter. The appearance and behavior of the button can be customized based
/// on the [isApplied] parameter, which determines whether the button is in a
/// selected state.
///
/// The [onPressed] parameter is a callback function that will be executed when
/// the button is pressed. It is of type `void Function()`.
///
/// Example usage:
/// ```dart
/// LayerBtn(
///   layer: 'Layer Name',
///   onPressed: () {
///     // Handle button press.
///   },
///   isApplied: true, // Set to true for a selected state, false otherwise.
/// )
/// ```
///
/// The button's appearance is determined by the [isApplied] parameter. If
/// [isApplied] is true, the button will have a different background color
/// indicating its selected state; otherwise, it will have a primary color
/// background. The button text is formatted using the `MarkD` widget, allowing
/// rich text and markdown-like styling.
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

/// A Flutter widget representing a customizable card button.
///
/// This [CardBtn] widget displays a [Flashcard] within an [ElevatedButton] that
/// triggers specified actions on both regular press and long press events.
///
/// The [card] parameter is the flashcard to be displayed within the button.
///
/// The [onPressed] parameter is a callback function that will be executed when
/// the button is pressed. It is of type `void Function()`.
///
/// The [onLongPress] parameter is a callback function that will be executed when
/// the button is long-pressed. It is of type `void Function(BuildContext)`.
///
/// Example usage:
/// ```dart
/// CardBtn(
///   card: myFlashcard,
///   onPressed: () {
///     // Handle regular button press.
///   },
///   onLongPress: (BuildContext context) {
///     // Handle long press with access to the build context.
///   },
/// )
/// ```
///
/// The button is styled with a transparent background and a border that follows
/// the primary color scheme of the current theme. The content of the button is
/// formatted using the `MarkD` widget, allowing rich text and markdown-like
/// styling for the flashcard content.
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
          child: MarkD("## ${card.key}\n${card.deckStr}\n___\n${card.values[0]}"),
        ),
      ))
    ]);
  }//e Build
}//e CardBtn

/// A Flutter widget representing a customizable start button.
///
/// The [StartBtn] widget displays a button with an [Icon] and text specified
/// by the [icon] and [text] parameters, respectively. The appearance and
/// behavior of the button can be customized based on the specified [onPressed]
/// callback function.
///
/// The [onPressed] parameter is a callback function that will be executed when
/// the button is pressed. It is of type `void Function(BuildContext)`.
///
/// Example usage:
/// ```dart
/// StartBtn(
///   icon: Icon(Icons.play_arrow),
///   text: 'Start',
///   onPressed: (BuildContext context) {
///     // Handle button press with access to the build context.
///   },
/// )
/// ```
///
/// The button's appearance is determined by the default background color of the
/// current theme. The button content consists of an [Icon] and text, both
/// aligned in a row at the center.
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
}//e StartBtn

/// Generates a widget containing layer buttons for the given list of [layers].
///
/// The [deckBtns] method takes a list of layer names and a callback function
/// [updateState]. It creates buttons for resetting the filter and displaying
/// all decks/cards, buttons for reverting to each applied layer, and buttons for
/// adding new layers to the filter. The [onPressed] callbacks perform actions
/// based on the selected layer, such as setting the filter or pushing a new
/// layer onto the filter.
///
/// Example usage:
/// ```dart
/// Widget deckButtonsWidget = deckBtns(myLayerList, () {
///   // Update state logic.
/// });
/// ```
///
/// The generated list of layer buttons is then used to create a [Wrap] widget
/// for a flexible layout, aligned to the top left.
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

  Widget wrap = Align(alignment: Alignment.topLeft, child: Wrap(alignment: WrapAlignment.start, children: children,));
  return wrap;
}//e deckBtns

/// Generates a widget containing card buttons for the given list of [Flashcard]s.
///
/// The [cardBtns] method takes a list of [Flashcard]s and a callback function
/// [updateState]. For each card in the list, it creates a [CardBtn] with
/// specified [onPressed] and [onLongPress] callbacks. The [onPressed] callback
/// prints a message to the console, and the [onLongPress] callback displays a
/// confirmation popup for deleting the card.
///
/// Example usage:
/// ```dart
/// Widget cardButtonsWidget = cardBtns(myFlashcardList, () {
///   // Update state logic.
/// });
/// ```
///
/// The generated list of card buttons is then used to create a [Column] widget
/// containing all the buttons.
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
            () { Flashcard.removeCard(card); Flashcard.setFilter(Flashcard.filter); updateState(); }
          );//e confirmPopup
        },//e onLongPress
      )//e CardBtn
    );//e add
  }//e for

  // Using the generated list of buttons, create and return the Column.
  Widget column = Column(children: children,);
  return column;
}//e cardBtns

/// Generates a widget containing start buttons for different actions.
///
/// The [startBtns] method creates a widget containing three start buttons for
/// different actions: practice, review, and multitest. Each button includes an
/// icon, text, and an [onPressed] callback to navigate to the corresponding
/// screen using the [Navigator].
///
/// Example usage:
/// ```dart
/// Widget startButtonsWidget = startBtns();
/// ```
///
/// The method uses the [StartBtn] widget to create individual buttons for
/// practice, review, and multitest. These buttons are then arranged in a
/// [Wrap] widget for a flexible layout. Additionally, the buttons are also
/// displayed in a [GridView] with three columns for a more organized display.
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


/// Displays a theme mode selection popup in the specified [context].
///
/// The [themeModePopup] method creates an AlertDialog containing a column of
/// ElevatedButtons, each representing a different theme mode option. The
/// options include setting the theme to light mode, dark mode, or automatic
/// mode.
///
/// Example usage:
/// ```dart
/// themeModePopup(context);
/// ```
///
/// The method utilizes the [getAppThemeMode] function to access the
/// `AppThemeMode` instance and sets the theme mode based on the user's
/// selection.
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

/// Displays a theme color selection popup in the specified [context].
///
/// The [themeColorPopup] method creates an AlertDialog containing a column of
/// ElevatedButtons, each representing a different theme color option. The
/// available theme colors are retrieved using the [getAvailableThemeColors]
/// function. When a color button is pressed, the method uses the
/// [getColorTheme] function to set the color theme accordingly.
///
/// Example usage:
/// ```dart
/// themeColorPopup(context);
/// ```
///
/// The method dynamically generates the color buttons based on the available
/// theme colors and their corresponding names.
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


/// A Flutter widget that adds a long-press gesture to a child widget.
///
/// The [LongPressWidget] class allows you to wrap any widget with a
/// long-press gesture. It takes a [child] widget and a [onLongPress] callback
/// function that will be executed when the user performs a long-press on the
/// wrapped widget.
///
/// Example usage:
/// ```dart
/// LongPressWidget(
///   child: YourWidget(),
///   onLongPress: () {
///     // Handle long-press action.
///   },
/// )
/// ```
class LongPressWidget extends StatelessWidget {

  final Widget child;
  final void Function() onLongPress;

  LongPressWidget({required this.child, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    // create widget
    Widget longPress = GestureDetector(onLongPress: () => onLongPress(), child: child,);
    return longPress;
  }//e buidl()
}//e LongPressWidget

/// A Flutter widget representing a confidence button with additional long-press functionality.
///
/// The [ConfidenceBtn] class combines an [IconButton] with a long-press gesture,
/// allowing users to perform both regular press and long-press actions. It takes
/// an [icon] for the regular press action, [onPressed] callback for the regular
/// press event, and [onLongPress] callback for the long-press event.
///
/// Example usage:
/// ```dart
/// ConfidenceBtn(
///   icon: Icon(Icons.thumb_up),
///   onPressed: () {
///     // Handle regular press action.
///   },
///   onLongPress: () {
///     // Handle long-press action.
///   },
/// )
/// ```
class ConfidenceBtn extends StatelessWidget {
  
  final Icon icon;
  final void Function() onPressed;
  final void Function() onLongPress;
  const ConfidenceBtn({super.key, required this.icon, required this.onPressed, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    var iconBtn = IconButton(onPressed: onPressed, icon: icon);
    var longPressWidget = LongPressWidget(onLongPress: onLongPress, child: iconBtn);
    return longPressWidget;
  }//e build()
}//e ConfidenceBtn

/// Generates a row of confidence buttons with regular and long-press actions.
///
/// The [confidenceBtns] method takes the [currentConfidence] level and a
/// [setConfidence] callback function to update the confidence level. It creates
/// a row of three [ConfidenceBtn] widgets, each representing a different
/// confidence level (low, medium, high). The [onPressed] callback sets the
/// confidence level when the button is pressed, and the [onLongPress] callback
/// resets the confidence level to -1 when the button is long-pressed.
///
/// Example usage:
/// ```dart
/// Widget confidenceButtonsWidget = confidenceBtns(
///   currentConfidenceLevel,
///   (int confidenceLevel) {
///     // Handle setting confidence level logic.
///   },
/// );
/// ```
Widget confidenceBtns(currentConfidence, void Function(int p) setConfidence) {
  Widget expand(Widget child) {
    return Expanded(flex: 1, child: child);
  }
  var confidenceBtns = Row(children: [
    expand(ConfidenceBtn(
      icon: Icon(currentConfidence == 0? Icons.remove_circle : Icons.remove_circle_outline),
      onPressed: () => setConfidence(0),
      onLongPress: () => setConfidence(-1),
    )),
    expand(ConfidenceBtn(
      icon: Icon(currentConfidence == 1? Icons.circle : Icons.circle_outlined),
      onPressed: () => setConfidence(1),
      onLongPress: () => setConfidence(-1),
    )),
    expand(ConfidenceBtn(
      icon: Icon(currentConfidence == 2? Icons.add_circle : Icons.add_circle_outline),
      onPressed: () => setConfidence(2),
      onLongPress: () => setConfidence(-1),
    )),
  ]);
  return confidenceBtns;
}//e confidenceBtns


/// A stateful widget for creating a new flashcard.
///
/// The [CreateCardAlert] class is a stateful widget that displays an alert dialog
/// for creating a new flashcard. It takes an [appliedFilter] to pre-fill the deck
/// or tags based on the current context. The [onConfirm] callback is invoked when
/// the user confirms the creation of the flashcard, passing the key, deck, values,
/// and optional tags list.
///
/// Example usage:
/// ```dart
/// CreateCardAlert(
///   appliedFilter: "Deck1", // optional pre-filled deck or tags
///   onConfirm: (String key, String deck, List<String> values, [List<String>? tags]) {
///     // Handle flashcard creation logic.
///   },
/// )
/// ```
class CreateCardAlert extends StatefulWidget {

  final String appliedFilter;
  const CreateCardAlert({super.key, required this.onConfirm, this.appliedFilter = ""});

  final Function(String, String, List<String>, [List<String>?]) onConfirm;
  @override
  State<CreateCardAlert> createState() => _CreateCardAlertState();
}

/// State class for the [CreateCardAlert] widget.
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
        controller: TextEditingController(text: ""),
        decoration: InputDecoration(hintText: getString('hint_create_new_card_values_fake')),
        keyboardType: TextInputType.multiline,
        maxLines: null,
      ));
      values.add("");
    }
  }

  @override
  void initState() {
    if (widget.appliedFilter.startsWith('#')) {
      tags = widget.appliedFilter;
    } else {
    deck = widget.appliedFilter;
    }//e if else

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
      controller: TextEditingController(text: deck),
      onChanged: (t) => deck = t,
      decoration: InputDecoration(hintText: getString('hint_create_new_card_deck')),
      keyboardType: TextInputType.multiline,
      maxLines: null,
    );//e deckField
    tagField = TextField(
      controller: TextEditingController(text: tags),
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

/// Displays a popup for creating a new flashcard.
///
/// The [createCardPopup] method shows a dialog using [showDialog] with a
/// [CreateCardAlert] widget to allow users to create a new flashcard. It takes
/// the [context] for building the dialog, [onConfirm] callback for handling
/// flashcard creation, and an optional [appliedFilter] to pre-fill the deck or
/// tags in the flashcard creation form.
///
/// Example usage:
/// ```dart
/// createCardPopup(
///   context,
///   (String key, String deck, List<String> values, [List<String>? tags]) {
///     // Handle flashcard creation logic.
///   },
///   "Deck1", // optional pre-filled deck or tags
/// );
/// ```
void createCardPopup(
    BuildContext context,
    Function(String, String, List<String>, [List<String>?]) onConfirm,
    String appliedFilter,
  ) {
  // showDialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CreateCardAlert(onConfirm: onConfirm, appliedFilter: appliedFilter);
    }//e builder
  );//e showDialog
}//e createCardPopup

/// Displays an alert popup with custom title, message, and buttons.
///
/// The [alertPopup] method shows an alert dialog using [showDialog] with a
/// custom title, message, and buttons. It takes the [context] for building the
/// dialog, [title] and [message] for the alert content, and lists of [btnStrings]
/// and [btnActions] for the button labels and corresponding actions.
///
/// Example usage:
/// ```dart
/// alertPopup(
///   context,
///   "Error",
///   "An error occurred. Please try again.",
///   ["OK"],
///   [() {
///     // Handle OK button action.
///   }],
/// );
/// ```
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