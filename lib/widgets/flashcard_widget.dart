
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

  /// Whether this is a new card.
  late bool isNewCard;
  /// Whether in editing mode.
  late bool isEditing;
  /// Whether the card has been edited.
  late bool isEdited;

  // Current data, may or may not be modified.
  late String key;
  late List<String> values;
  late String deck;
  late String tagsStr;

  // Old data, used to determine whether changes have been made.
  late final String oldKey;
  late final List<String> oldValues;
  late final String oldDeck;
  late final String oldTagsStr;

  // Fields for the data.
  late Widget keyField;
  late List<Widget> valueFields;
  late Widget deckField;
  late Widget tagField;

  @override
  void initState() {
    // Initialize values.
    if (widget.card == null) {
      // If new card.
      isNewCard = true;
      // card = Flashcard('', '', ['']);
      String filter = Flashcard.filterString.length > 1? Flashcard.filterString : '';
      String deckFilter = '';
      String tagFilter = '';
      if (filter.startsWith('/')) {
        deckFilter = filter;
      } else if (filter.startsWith('#')) {
        tagFilter = filter;
      }
      key = '';
      oldKey = '';
      values = ['', ''];
      oldValues = ['', ''];
      deck = deckFilter;
      oldDeck = deckFilter;
      tagsStr = tagFilter;
      oldTagsStr = tagFilter;
    } else {
      // If existing card.
      isNewCard = false;
      key = widget.card!.key;
      oldKey = widget.card!.key;
      values = widget.card!.values + [''];
      oldValues = widget.card!.values + [''];
      deck = widget.card!.deck;
      oldDeck = widget.card!.deck;
      tagsStr = widget.card!.tagsStr;
      oldTagsStr = widget.card!.tagsStr;
    }//e if else

    isEditing = widget.initIsEditing;
    isEdited = false;
    valueFields = [];

    // Create the text fields
    keyField = TextField(
      controller: TextEditingController(text: key),
      onChanged: (t) { key = t; _checkForChange(); },
      decoration: InputDecoration(hintText: getString('hint_create_new_card_key')),
      keyboardType: TextInputType.multiline,
      maxLines: null,
    );//e keyField
    valueFields.add(TextField(
      controller: TextEditingController(text: values[0]),
      onChanged: (t) { setState(() => _updateValues(0, t)); _checkForChange(); },
      decoration: InputDecoration(hintText: getString('hint_create_new_card_values')),
      keyboardType: TextInputType.multiline,
      maxLines: null,
    ));//e valueFields
    for (int i = 1; i < values.length; i++) {
      valueFields.add(TextField(
        controller: TextEditingController(text: values[i]),
        onChanged: (t) { setState(() => _updateValues(i, t)); _checkForChange(); },
        decoration: InputDecoration(hintText: getString('hint_create_new_card_values_fake')),
        keyboardType: TextInputType.multiline,
        maxLines: null,
      ));//e valueFields
    }//e for
    deckField = TextField(
      controller: TextEditingController(text: deck),
      onChanged: (t) { deck = t; _checkForChange(); },
      decoration: InputDecoration(hintText: getString('hint_create_new_card_deck')),
      keyboardType: TextInputType.multiline,
      maxLines: null,
    );//e deckField
    tagField = TextField(
      controller: TextEditingController(text: tagsStr),
      onChanged: (t) { tagsStr = t; _checkForChange(); },
      decoration: InputDecoration(hintText: getString('hint_create_new_card_tags')),
      keyboardType: TextInputType.multiline,
      maxLines: null,
    );//e tagField
    super.initState();
  }//e initState()

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
        controller: TextEditingController(text: ''),
        decoration: InputDecoration(hintText: getString('hint_create_new_card_values_fake')),
        keyboardType: TextInputType.multiline,
        maxLines: null,
      ));
      values.add("");
    }//e if
  }//e _updateValues()

  bool _checkForChange() {
    bool changed = false;
    if (!changed && key != oldKey) { changed = true; }
    if (!changed && values != oldValues + ['']) { changed = true; }
    if (!changed && deck != oldDeck) { changed = true; }
    if (!changed && tagsStr != oldTagsStr) { changed = true; }

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

      /// The modified card.
      Flashcard modCard = Flashcard(key, deck, values, tagsStr.split(' '));

      /// Runs the actual saving functions.
      void saveConfirmed() {
        setState(() {
          // if (!isNewCard) {
          //   Flashcard.removeCard(widget.card!);
          // }
          Flashcard.newCard(key, deck, values, tagsStr.split(' '));
        });
        // Update the list of filtered flashcards. This will update and show the changes that have
        // been made.
        Flashcard.setFilter(null);
        // Update the state up the parent widget to see the changes.
        widget.superSetState();
        // Pop the flashcard widget.
        Navigator.pop(context);
      }//e saveConfirmed()

      // Check for duplicate.
      // If the key or deck (what ids the card) has been modified, check to see if a card exists
      // with the same key. If so, ask the user if they want to overwrite it. Otherwise, save the
      // flashcard.
      if ((key != oldKey || deck != oldDeck) && Flashcard.cards.contains(modCard)) {
        confirmPopup(
          context,
          getString('header_card_conflict_overwrite'),
          getString('msg_card_conflict_overwrite'),
          () {
            // Save the card.
            saveConfirmed();
          });
      } else {
        saveConfirmed();
      }//e if else
      
    }//e save()

    /// Cancels viewing the card.
    /// If the card was edited, a confirmation popup will display letting the user know there where
    /// changes, confirming that will exit the card view, not saving the changes.
    void cancel() {
      if (isEdited) {
        confirmPopup(
          context,
          getString('header_confirm_cancel_modify'),
          getString('msg_confirm_cancel_modify'),
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