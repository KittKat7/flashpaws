import 'dart:convert';
import 'package:flashpaws/lib/inout_desktop.dart';
import 'package:flashpaws/lib/inout_mobile.dart';
import 'package:flashpaws/lib/inout_web.dart';
import 'package:flashpaws/widgets.dart';
import 'package:flutterkat/platform.dart';

import 'package:flashpaws/flashcard.dart';
import 'package:flashpaws/update.dart';
import 'package:hive_flutter/hive_flutter.dart';

late Box hiveBox;


/// Export [cards] to JSON format and save it to the device.
/// 
/// Takes [cards] and [metadata] and converts it to JSON as a String. Determines which platform the
/// app is running on, and used the appropriate methods to save the file for that platform.
Future<void> exportCardsJson(Map<String, dynamic> metadata, List<Flashcard> cards) async {

  // This is what will be writen to the file. Encode the metadata and cards into a map into json.
  String content = json.encode({'metadata': metadata, 'flashcards': cards});

  // If the app is running on web, run the save method for web apps.
  if (GetPlatform.isWeb) {
    // Write the contents to 'flashcards.json'.
    writeToFileWeb('flashcards.json', content);
  }//e if web

  // Else if the app is running on a desktop platform, run the save method for desktop apps.
  else if (GetPlatform.isDesktop) {
    pickWriteFileDesktop(content);
  }//e if desktop

  // Else if the app is running on a mobile platform, run the save method for mobile apps.
  else if (GetPlatform.isMobile) {
    pickAndWriteToFileMobile('flashcards.json', content);
  }//e if mobile
}//e exportCardsJson()


/// User selects a file and import the cards into app storage.
/// 
/// Prompts the user to select a file to import from, then reads the data from that file and decodes
/// the JSON into Flashcards. If an imported card already exists, asks the user to decide whether to
/// overwrite the existing card, or to skip importing the new card.
/// [context] is used to display the popup notifying the user of the conflict of cards. The
/// [onLoadComplete] function is run after the import is successful. This function should likely be
/// setState(() {}) of the calling widget. This will allow the widget to update the list of cards it
/// is displaying.
Future<void> importCardsJson(context, Function() onLoadComplete) async {
  
  // The content from the file as a String.
  String? contentString;

  // If the app is running as a web app, run the web specific method to pick and read from a file.
  if (GetPlatform.isWeb) {
    contentString = await readFromFileWeb();
  }//e if web app

  // Else if the app is running as a desktop app, run the desktop specific method to pick and read
  // from a file.
  else if (GetPlatform.isDesktop) {
    contentString = await pickReadFileDesktop();
  }//e if desktop app

  // Else if the app is running as a mobile app, run the mobile specific method to pick and read
  // from a file.
  else if (GetPlatform.isMobile) {
    contentString = await pickReadFileMobile();
  }//e if mobile app

  // If [contentString] is null, then the pick file or read operation was canceled, possibly by the
  // user. In that case, return without attempting to import.
  if (contentString == null) return;

  // Decode the String loaded from the file into a Map.
  Map<String, dynamic> content = json.decode(contentString);
  // Decode the metadata from the content Map.
  Map<String, dynamic> metadata = content['metadata'];

  // Check to see if imported JSON is up to date with current app formatting.
  if (metadata['version'] < appVersion) {
    
  }//e if version is out of date

  // Get the JSON type encoded flashcards. Currently encoded as a List<Map<dynamic, dynamic>>? not
  // sure.
  List<dynamic> flashcardsEncoded = content['flashcards'];
  // For every JSON flashcard in the list, convert it to a Flashcard type and add it to the 
  // [flashcards] list.
  List<Flashcard> flashcards =
    [for (dynamic card in flashcardsEncoded) Flashcard.fromJson(card)];

  // Default is null, but if this is set by the user during a card conflict, this will store the
  // decision, and it will be applied to all future conflicts during this import operation.
  bool? overwriteAll;
  // For every Flashcard in [flashcards] check to see if there is a conflict, if [overwriteAll] is
  // set, follow that, otherwise prompt the user as to whether to overwrite or not. If there is no
  // conflict, or the user decides to overwrite, add the Flashcard to the list of cards in the app.
  for (Flashcard card in flashcards) {

    // If [card] allready exists, and overwrite all is NOT true, determine whether to overwrite.
    // Else if overwrite all is true, remove the stored card, then add the new one.
    if (Flashcard.cards.contains(card) && overwriteAll != true) {
      // If overwriteAll is set to false, skip over adding and move on to the next card.
      if (overwriteAll == false) continue;

      // A temp variable to check whether to apply overwrite to all future conflicts.
      bool applyToAll = false;
      // Whether this card should overwrite.
      bool overwriteThis = await overwriteConfirmAlertPopup(context, (a) => applyToAll = a, card.id);
      // If applyToAll is true, overwriteAll will be updated to match which ever choice is selected
      // for this card.
      if (applyToAll) overwriteAll = overwriteThis;
      // If NOT overwriteThis, continue and skip overwriting. Otherwise, remove the original card
      // before adding the new one.
      if (!overwriteThis) {
        continue;
      } else {
        Flashcard.cards.remove(card);
      }//e if else
    } else if (overwriteAll == true) {
      Flashcard.cards.remove(card);
    }//e if else if
    Flashcard.addCard(card);
  }//e for
  
  // Save the flashcards, and run [onLoadComplete].
  Flashcard.saveCards();
  onLoadComplete();
}//e importCardsJson()



