
import 'dart:convert';
import 'dart:io';
import 'package:flashpaws/widgets.dart';
import 'package:flutterkat/platform.dart';
import 'package:universal_html/html.dart' as html;

import 'package:file_picker/file_picker.dart';
import 'package:flashpaws/flashcard.dart';
import 'package:flashpaws/update.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

late Box hiveBox;

void writeToFileWeb(String outputFile, String content) {
  final encodedContent = base64.encode(utf8.encode(content));
  final dataUri = 'data:text/plain;charset=utf-8;base64,$encodedContent';
  // ignore: unused_local_variable
  final anchorElement = html.AnchorElement(href: dataUri)
    ..setAttribute('download', outputFile)
    ..click();
}

Future<String> readFromFileWeb() async {
  // Create an input element
  final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  
  // Allow only text file types
  // uploadInput.accept = 'text/plain';
  
  // Trigger the file selection dialog
  uploadInput.click();
  
  // Wait for the user to select a file
  await uploadInput.onChange.first;
  
  // Access the selected file
  final file = uploadInput.files!.first;
  
  // Create a FileReader
  final reader = html.FileReader();
  
  // Read the file content as text
  reader.readAsText(file);
  
  // Wait for the file to be read
  await reader.onLoad.first;
  
  // Get the text content as a String
  final text = reader.result as String;
  
  return text;
}//e readFromFileWeb()



Future<void> writeToFileDesktop(String outputFile, String content) async {
  final file = File(outputFile);
  await file.writeAsString(content);
}//e writeToFileDesktop()

Future<String> readFromFileDesktop(String inputFile) async {
  final file = File(inputFile);
  return await file.readAsString();
}//e readFromFileDesktop()

Future<String?> pickOutFileDesktop() async {
  String downloadDir = "${(await getDownloadsDirectory())?.path}/";

  String? outputFile = await FilePicker.platform.saveFile(
    dialogTitle: 'Please select an output file:',
    fileName: 'output-file.pdf',
    initialDirectory: downloadDir
  );
  return outputFile;
}//e pickOutFileDesktop()

Future<String?> pickInFileDesktop() async {
  String downloadDir = "${(await getDownloadsDirectory())?.path}/";

  String? inputFile = (await FilePicker.platform.pickFiles(
    allowMultiple: false,
    initialDirectory: downloadDir,
    type: FileType.custom,
    allowedExtensions: ['json', 'flshpws-json']
  ))?.paths[0];
  return inputFile;
}//e pickInFileDesktop()

Future<void> pickWriteFileDesktop(String content) async {
  // Get the outputFile as the path for the file to be written.
  String? outputFile = await pickOutFileDesktop();
  // If the user cancels, outputFile will be null, in this case: return.
  if (outputFile == null) return;
  // Write the contents to the file outputFile.
  await writeToFileDesktop(outputFile, content);
}//e pickWriteFileDecktop()

Future<String?> pickReadFileDesktop() async {
  String? inputFile = await pickInFileDesktop();

  if (inputFile == null) return null;

  return await readFromFileDesktop(inputFile);
}

Future<void> pickAndWriteToFileMobile(String name, String content) async {
    try {
      // Allow the user to pick a directory
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) return;
      // Specify the file path within the selected directory
      String filePath = '${selectedDirectory}/$name';

      // Open the file in write mode
      File file = File(filePath);
      IOSink sink = file.openWrite(mode: FileMode.write);

      // Write content to the file
      sink.write(content);

      // Close the file
      await sink.close();

      print('File written successfully at: $filePath');

    } catch (e) {
      // Handle exceptions if any
      print('Error picking and writing file: $e');
    }
  }



Future<void> exportCardsJson(Map<String, dynamic> metadata, List<Flashcard> cards) async {

  // List<Flashcard> flashcards = 
  //   [for (Flashcard card in cards) card.toJson()];
  //   [for (String card in flashcardsEncoded) Flashcard.fromJson(json.decode(card))];
  String content = json.encode({'metadata': metadata, 'flashcards': cards});

  // If the user is on a web platform.
  if (GetPlatform.isWeb) {
    // Write the contents to 'flashcards.json'.
    writeToFileWeb('flashcards.json', content);
  }//e if web
  // If the user is on a desktop platform.
  else if (GetPlatform.isDesktop) {
    pickWriteFileDesktop(content);
  }//e if desktop

  else if (GetPlatform.isMobile) {
    pickAndWriteToFileMobile('flashcards.json', content);
  }//e if mobile
}//e exportCardsJson()

Future<void> importCardsJson(context, Function() onLoadComplete) async {
  String? contentString;

  if (GetPlatform.isWeb) {
    contentString = await readFromFileWeb();
  }

  else if (GetPlatform.isDesktop) {
    contentString = await pickReadFileDesktop();
  }

  else if (GetPlatform.isMobile) {
    contentString = await pickReadFileDesktop();
  }

  if (contentString == null) return;


  Map<String, dynamic> content = json.decode(contentString);
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



