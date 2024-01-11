
import 'package:flashpaws/flashcard.dart';
import 'package:flashpaws/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutterkat/flutterkat.dart';
import 'package:flutterkat/graphics.dart';
import 'package:flutterkat/widgets.dart';

void flashcardWidgetPopup({
    required BuildContext context,
    Flashcard? card,
    bool isEditing = false,
    required Function() superSetState
  }) {
  // showDialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return FlashcardWidget(card: card, initIsEditing: isEditing, superSetState: superSetState);
    }//e builder
  );//e showDialog
}//e createCardPopup

class FlashcardWidget extends StatefulWidget {

  final Flashcard? card;
  final bool initIsEditing;
  final Function() superSetState;

  const FlashcardWidget({super.key, this.card, required this.initIsEditing, required this.superSetState});

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {

  late bool isNewCard;
  late bool isEditing;
  late bool isEdited;

  late Flashcard card;

  late String key;
  late List<String> values;
  late String deck;
  late String tagsStr;

  late Widget keyField;
  late List<Widget> valueFields;
  late Widget deckField;
  late Widget tagField;

  /// Updates the values entered by the user.
  /// 
  /// Takes [n] and [text] and updates the data in [values] at index [n]. If [n] and is the same as
  /// [values.length - 1] and [text] is not empty, then it adds an additional TextField to
  /// [valueFields] and adds another blank string to [values] to serve as a place holder until text
  /// is entered into that TextField.
  void _updateValues(int n, String text) {
    // TODO add dynamic removal of empty TextFields. - CODE below does not work correctly.
    // BUG - Creating flashcard, 'Fake Answer' text fields stop auto adding.
    // if (text.isEmpty && n != 0 && false) {
    //   values.removeAt(n);
    //   valueFields.removeAt(n);
    //   return;
    // }//e if
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
    }//e if
  }//e _updateValues()

  @override
  void initState() {
    if (widget.card == null) {
      isNewCard = true;
      card = Flashcard('', '', ['']);
    } else {
      isNewCard = false;
      card = widget.card!;
    }
    isEditing = widget.initIsEditing;
    isEdited = false;

    // initialize values
    key = card.key;
    values = card.values + [''];
    deck = card.deck;
    tagsStr = card.tagsStr;

    valueFields = [];

    // Create the text fields
    keyField = TextField(
      controller: TextEditingController(text: key),
      onChanged: (t) { key = t; checkForChange(); },
      decoration: InputDecoration(hintText: getString('hint_create_new_card_key')),
      keyboardType: TextInputType.multiline,
      maxLines: null,
    );//e keyField
    valueFields.add(TextField(
      controller: TextEditingController(text: values[0]),
      onChanged: (t) { setState(() => _updateValues(0, t)); checkForChange(); },
      decoration: InputDecoration(hintText: getString('hint_create_new_card_values')),
      keyboardType: TextInputType.multiline,
      maxLines: null,
    ));//e valueFields
    for (int i = 1; i < values.length; i++) {
      valueFields.add(TextField(
        controller: TextEditingController(text: values[i]),
        onChanged: (t) { setState(() => _updateValues(i, t)); checkForChange(); },
        decoration: InputDecoration(hintText: getString('hint_create_new_card_values_fake')),
        keyboardType: TextInputType.multiline,
        maxLines: null,
      ));//e valueFields
    }//e for
    deckField = TextField(
      controller: TextEditingController(text: deck),
      onChanged: (t) { deck = t; checkForChange(); },
      decoration: InputDecoration(hintText: getString('hint_create_new_card_deck')),
      keyboardType: TextInputType.multiline,
      maxLines: null,
    );//e deckField
    tagField = TextField(
      controller: TextEditingController(text: tagsStr),
      onChanged: (t) { tagsStr = t; checkForChange(); },
      decoration: InputDecoration(hintText: getString('hint_create_new_card_tags')),
      keyboardType: TextInputType.multiline,
      maxLines: null,
    );//e tagField

    super.initState();
  }//e initState()

  bool checkForChange() {
    bool changed = false;
    if (!changed && key != card.key) { changed = true; }
    if (!changed && values != card.values + ['']) { changed = true; }
    if (!changed && deck != card.deck) { changed = true; }
    if (!changed && tagsStr != card.tagsStr) { changed = true; }

    isEdited = changed;
    // if (changed != isEdited) setState(() => isEdited = changed);
    // print(changed);
    // print("'$deck' vs '${widget.card.deck}'");
    return changed;
  }


  @override
  Widget build(BuildContext context) {
    Widget keyText;
    List<Widget> valueText = [];
    Widget deckText;
    Widget tagText;

    // If this widget is in editing mode, set the field widgets to be displayed in markdown.
    // Otherwise build it with the fields being editable text fields.
    if (!isEditing) {
      keyText = Markd(key);
      for (String value in values) {
        valueText.add(
          Markd(value)
        );
      }//e for
      deckText = TextItalic(deck);
      tagText = TextItalic(tagsStr);
    } else {
      keyText = keyField;
      valueText = valueFields;
      deckText = deckField;
      tagText = tagField;
    }

    
    
    Widget keyContainer = Column(mainAxisSize: MainAxisSize.min, children: [
      TextBold(getString('term/question')),
      keyText
    ],);

    Widget valueContainer = Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      TextBold(getString('definition/answer'))] + valueText
    );

    Widget deckContainer = Column(mainAxisSize: MainAxisSize.min, children: [
      TextBold(getString('deck')),
      deckText
    ],);

    Widget tagContainer = Column(mainAxisSize: MainAxisSize.min, children: [
      TextBold(getString('tags')),
      tagText
    ],);

    Widget divider() {
      if (!isEditing) {
        return const ThinDivider();
      } else {
        return const SizedBox();
      }
    }//e divider

    Widget column = Column(mainAxisSize: MainAxisSize.min, children: [
      keyContainer,
      divider(),
      valueContainer,
      divider(),
      deckContainer,
      divider(),
      tagContainer
    ],);

    /// Saves the modified card.
    /// Performs all validation checks and then saved the modified card.
    void save() {
      // Check for empty key.
      if (key.isEmpty) {
        alertPopup(
          context,
          getString('err_hdr_create_empty_key'),
          getString('err_msg_create_empty_key'),
          [getString('confirm')],
          [(){}]);
        return;
      }//e if
      // Check for empty values.
      if (values[0].isEmpty) {
        alertPopup(
          context,
          getString('err_hdr_create_empty_values'),
          getString('err_msg_create_empty_values'),
          [getString('confirm')],
          [(){}]);
        return;
      }//e if
      
      // Validate key.
      key = Flashcard.validateKey(key);
      // Validate values.
      values = Flashcard.validateValues(values);
      // Validate deck.
      deck = Flashcard.validateDeckStr(deck);
      // Validate tags.
      tagsStr = Flashcard.validateTagStr(tagsStr);

      Flashcard modCard = Flashcard(key, deck, values, tagsStr.split(' '));

      @override
      void save() {
        setState(() {
          Flashcard.newCard(key, deck, values, tagsStr.split(' '));
          if (!isNewCard) {
            Flashcard.removeCard(widget.card!);
          }
        });
        widget.superSetState();
        Navigator.pop(context);
      }

      // Check for duplicate
      if (key != card.key || deck != card.deck) {
        if (Flashcard.cardIDExists(modCard.id)) {
          confirmPopup(
            context,
            "DUPLICATE",
            "DUPLICATE",
            () => save());
        } else {
          save();
        }//e if else
      } else {
        save();
      }//e if else

      
    }//e save()

    /// Cancels viewing the card.
    /// If the card was edited, a confirmation popup will display letting the user know there where
    /// changes, confirming that will exit the card view, not saving the changes.
    void cancel() {
      if (isEdited) {
        confirmPopup(
          context,
          "CONFERM",
          "CONFIRM",
          () => Navigator.of(context).pop()
        );
      } else {
        Navigator.of(context).pop();
      }
    }//e cancel()

    /// Changes the view into editing mode.
    void edit() {
      setState(() => isEditing = true);
    }//e edit()

    /// Changes the view into preview mode (markdown mode).
    void preview() {
      setState(() => isEditing = false);
    }//e preview()

    Widget cancelBtn = TextButton(
      onPressed: cancel,
      child: Text(getString('cancel')));
    Widget saveBtn = TextButton(
      onPressed: save,
      child: Text(getString('save')));
    Widget editBtn = TextButton(
      onPressed: edit,
      child: Text(getString('edit')));
    Widget previewBtn = TextButton(
      onPressed: preview,
      child: Text(getString('preview')));

    List<Widget> actionBtns = [];
    if (isEditing) {
      actionBtns = [
        cancelBtn,
        previewBtn,
        saveBtn,
      ];
    } else {
      actionBtns = [
        cancelBtn,
        editBtn,
        saveBtn,
      ];
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        cancel();
      },
      child: Aspect(
        child: AlertDialog(
          title: Center(child: HeaderMarkd(getString('flashcard'))),
          content: SingleChildScrollView(child: column),
          actions: actionBtns
        )
      )
    );
  }
}