import 'dart:convert';
import 'dart:io';

import 'package:flashpaws/flashcard.dart';
import 'package:flutterkat/flutterkat.dart';
import 'package:hive_flutter/hive_flutter.dart';

int _version = 0;

Future<void> update(int oldVersion, int newVersion) async {
  try {
    await _update(oldVersion, newVersion);
  } catch (e) {
    print("ERROR $_version > ${e.toString()}");
    exit(-1);
  }
}

Future<void> _update(int oldVersion, int newVersion) async {

  _version = 2024010400;
  if (oldVersion < _version) {
    print("DEBUG > Updating from $oldVersion to $_version");
    
    // Load the flashpaws box.
    await Hive.initFlutter('katapp');
    Box box = await Hive.openBox('flashpaws');

    // A list of loaded cards.
    List<Flashcard> cards = [];

    // For every card in the box, convert it from json, and add it to the list of cards.
    for (String json in box.get('flashcards')) {
      cards.add(Flashcard.fromJson(jsonDecode(json)));
    }//e for

    // For every card loaded, validate its deck and update it.
    for (Flashcard card in cards) {
      card.deck = Flashcard.validateDeckStr(card.deck);
    }//e for

    Flashcard.hiveBox = box;
    
    // Save the cards with the update applied.
    Flashcard.saveCards(cards);

    // Update old version to match this version.
    oldVersion = _version;
  }//e 2024010400



  flktSave('version', _version.toString());

}//e update()