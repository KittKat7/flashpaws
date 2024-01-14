
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flashpaws/flashcard.dart';
import 'package:flashpaws/update.dart';
import 'package:flashpaws/widgets/overwrite_confirm_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

late Box hiveBox;

Future<void> writeToFile(String outputFile, String content) async {
  final file = File(outputFile);
  await file.writeAsString(content);
}//e writeToFile()

Future<String> readFromFile(String inputFile) async {
  final file = File(inputFile);
  return await file.readAsString();
}//e readFromFile()

Future<String?> pickOutFile() async {
  String downloadDir = "${(await getDownloadsDirectory())?.path}/";

  String? outputFile = await FilePicker.platform.saveFile(
    dialogTitle: 'Please select an output file:',
    fileName: 'output-file.pdf',
    initialDirectory: downloadDir
  );
  return outputFile;
}//e pickOutFile()

Future<String?> pickInFile() async {
  String downloadDir = "${(await getDownloadsDirectory())?.path}/";

  String? inputFile = (await FilePicker.platform.pickFiles(
    allowMultiple: false,
    initialDirectory: downloadDir,
    allowedExtensions: ['json', 'flshpws-json']
  ))?.paths[0];
  return inputFile;
}//e pickInFile()

Future<void> saveTestFile() async {
  String? outputFile = await pickOutFile();

  if (outputFile == null) return;

  List<String> flashcardsEncoded = hiveBox.get('flashcards');
  List flashcards = 
    [for (String card in flashcardsEncoded) json.decode(card)];
    // [for (String card in flashcardsEncoded) Flashcard.fromJson(json.decode(card))];

  String metadataEncoded = hiveBox.get('metadata');
  Map<String, dynamic> metadata = json.decode(metadataEncoded);
  String content = json.encode({'metadata': metadata, 'flashcards': flashcards});

  await writeToFile(outputFile, content);
}//e saveTestFile()

Future<void> exportCardsJson(Map<String, dynamic> metadata, List<Flashcard> cards) async {
  String? outputFile = await pickOutFile();

  if (outputFile == null) return;

  // List<Flashcard> flashcards = 
  //   [for (Flashcard card in cards) card.toJson()];
  //   [for (String card in flashcardsEncoded) Flashcard.fromJson(json.decode(card))];

  String content = json.encode({'metadata': metadata, 'flashcards': cards});

  await writeToFile(outputFile, content);
}//e exportCardsJson()

Future<void> importCardsJson(context, Function() onLoadComplete) async {
  String? inputFile = await pickInFile();

  if (inputFile == null) return;

  Map<String, dynamic> content = json.decode(await readFromFile(inputFile));
  Map<String, dynamic> metadata = content['metadata'];
  // Check to see if imported json is up to date.
  if (metadata['version'] < appVersion) {
    
  }//e if

  List<dynamic> flashcardsEncoded = content['flashcards'];
  List<Flashcard> flashcards =
    [for (dynamic card in flashcardsEncoded) Flashcard.fromJson(card)];

  bool? overwriteAll;
  for (Flashcard card in flashcards) {
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
    }//e if
    Flashcard.addCard(card);
  }//e for
  Flashcard.saveCards();
  onLoadComplete();
}//e importCardsJson()



