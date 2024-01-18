part of '../widgets.dart';


/// A Flutter widget representing a customizable card button.
///
/// This [CardButton] widget displays a [Flashcard] within an [ElevatedButton] that
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
class CardButton extends StatefulWidget {
  /// The card to be displayed.
  final Flashcard card;
  /// The function to run when the button is pressed.
  final void Function() onPressed;
  final void Function(BuildContext) onLongPress;

  /// Constructor
  const CardButton({super.key, required this.card, required this.onPressed, required this.onLongPress});

  @override
  State<CardButton> createState() => _CardButtonState();
}//e CardBtn

class _CardButtonState extends State<CardButton> {
  bool isCardFlipped = false;

  @override
  Widget build(BuildContext context) {

    Color bgColor = isCardFlipped? Theme.of(context).colorScheme.primary : Theme.of(context).canvasColor;

    String tags = widget.card.deck;
    for (String tag in widget.card.tagsList) {
      tags += " - $tag";
    }//e for

    List<Widget> children = [];

    if (isCardFlipped) {
      children.add(
        Align(alignment: Alignment.centerLeft, child: Markd(widget.card.values[0]))
      );
    } else {
      children.addAll([
        Align(alignment: Alignment.centerLeft, child: Markd(widget.card.key)),
        Align(alignment: Alignment.centerLeft, child: Markd('*${tags.trim()}*'))
      ]);
    }

    return Row(children: [
      Expanded(child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 1, right: 1),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.all(10),
            backgroundColor: bgColor,
            side: BorderSide(width: 1, color: colorScheme(context).primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => setState(() => isCardFlipped = !isCardFlipped),
          onLongPress: () { widget.onPressed(); /*widget.onLongPress(context);*/ },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children
            // [
            //   Markd(widget.card.key),
            //   // Italisized string of the deck and tags.
            //   Markd('*${tags.trim()}*'),
            //   const ThickDivider(),
            //   Markd(widget.card.values[0])
            // ]
          )
        ),
      ))
    ]);
  }//e Build
}


class CardButtonColumn extends StatelessWidget {
  
  final void Function() updateState;
  final List<Flashcard> cards;
  
  const CardButtonColumn({super.key, required this.cards, required this.updateState});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    // for every card in the list of cards, create a button, and add it to a list.
    for (Flashcard card in cards) {
      children.add(
        CardButton(
          card: card,
          onPressed: () { flashcardWidgetPopup(context: context, card: card, superSetState: updateState); },
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
  }//e build()
}//e CardButtonColumn

/// Generates a widget containing card buttons for the given list of [Flashcard]s.
///
/// The [cardBtns] method takes a list of [Flashcard]s and a callback function
/// [updateState]. For each card in the list, it creates a [CardButton] with
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
Widget cardBtns(List<Flashcard> cards, BuildContext context, void Function() updateState) {
  List<Widget> children = [];
  
  // for every card in the list of cards, create a button, and add it to a list.
  for (Flashcard card in cards) {
    children.add(
      CardButton(
        card: card,
        onPressed: () { flashcardWidgetPopup(context: context, card: card, superSetState: updateState); },
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