import 'dart:convert';

import 'widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutterkat/flutterkat.dart';
import 'package:flutterkat/lang.dart';
import 'package:flutterkat/graphics.dart';
import 'package:flutterkat/widgets.dart';
import 'flashcard.dart';
import 'package:flutterkat/theme.dart' as theme;
import 'package:hive_flutter/hive_flutter.dart';
import './lang/en_us.dart' as en_us;

late Box box;

const int version = 2023102700;

void main() async {
  await flutterkatInit();
  await initialize();
  flktRunApp(const MyApp());
}

/// initialize
/// This function initializes anything variables, like the hive box, that will be needed later on.
Future<void> initialize() async {
  // Check `version` with the saved version. If there is a mismatch, //TODO fix the version mismatch.
  String? savedVerionTmp = flktLoad('version');
  if (savedVerionTmp != null) {
    int savedVersion = int.parse(savedVerionTmp);
    if (savedVersion != version) {
      print("//TODO VERSION MISMATH CODE EXECUTE HERE");
    }
  } else {
    flktSave('version', version.toString());
  }

  // set language
  setLang(en_us.getLang);
  // Set aspect ratio
  setAspect(3, 4);
  // Initialize hive box.
  await Hive.initFlutter('katapp');
  box = await Hive.openBox('flashpaws');
  
  // Instanciate the hiveBox variable of Flashcard
  Flashcard.hiveBox = box;

  // If there are no prexisting cards, or something was saved incorrectly and not saved as a String,
  // create the list of introduction flashcards.
  if (!box.containsKey('flashcards') || box.get('flashcards').isEmpty
    || box.get('flashcards')[0] is! String) {
    // List of new flashcards to be added.
    List<Flashcard> newCards = [
      // Flashcard for how to make a new card.
      Flashcard(
        getString('introcard_how_to_new_card'),
        'introduction',
        [getString('introcard_how_to_new_card_answer')],
        []
      ),
      // Flashcard for how to sort cards.
      Flashcard(
        getString('introcard_how_to_sort_cards'),
        'introduction',
        [getString('introcard_how_to_sort_cards_answer')],
        []
      ),
      // Flashcard for how to practice the flashcards.
      Flashcard(
        getString('introcard_how_to_practice'),
        'introduction',
        [getString('introcard_how_to_practice_answer')],
        []
      ),
    ];//e newCards
    
    // Save flashcards.
    Flashcard.saveCards(newCards);
  }//e if
  
  // For every card in the box, convert it from json, and add it to the list of cards.
  for (String json in box.get('flashcards')) {
    Flashcard.cards.add(Flashcard.fromJson(jsonDecode(json)));
  }//e for
  
  // // TODO remove temp data
  // Flashcard.cards = [
  //   Flashcard("Temp Card 1", "deck1/layer1/", ["Answer 1","Answer B 1"], ["#learned/good"]),
  //   Flashcard("Temp Card 2", "deck1/layer2/", ["Answer 2","Answer B 2"], ["#learned/good"]),
  //   Flashcard("Temp Card 3", "deck2abcd/layer1/", ["Answer 1","Answer B 1"], ["#learned/good"]),
  //   Flashcard("Temp Card 4", "deck2abcd/layer2/", ["Answer 2","Answer B2 "], ["#learned/good"]),
  //   Flashcard("Temp Card 5", "deck3/layer1/", ["Answer 1","Answer B 1"]),
  //   Flashcard("Temp Card 6", "deck3/layer2/", ["Answer 2","Answer B 2"]),
  //   Flashcard("Temp Card 7", "deck4/layer1/", ["Answer 1","Answer B 1"], ["#learned/med"]),
  //   Flashcard("Temp Card 8", "deck4/layer2/", ["Answer 2","Answer B 2"]),
  //   Flashcard("Temp Card 9", "deck5/layer1/", ["Answer 1","Answer B 1"]),
  //   Flashcard("Temp Card 10", "deck5/layer2/", ["Answer 2","Answer B 2"]),
  //   Flashcard("Temp Card 11", "deck6/layer1/", ["Answer 1","Answer B 1"], ["#learned/bad"]),
  //   Flashcard("Temp Card 12", "deck6/layer2/", ["Answer 2","Answer B 2"]),
  //   Flashcard("Temp Card 13", "deck7/layer1/", ["Answer 1","Answer B 1"], ["#smile/happy"]),
  //   Flashcard("Temp Card 14", "deck7/layer2/", ["Answer 2","Answer B 2"], ["#smile/happy"]),
  //   Flashcard("Temp Card 15", "deck8/layer1/", ["Answer 1","Answer B 1"], ["#learned/bad"]),
  //   Flashcard("Temp Card 16", "deck8/layer2/", ["Answer 2","Answer B 2"], ["#smile"]),
  //   Flashcard("Temp Card 17", "deck9/layer1/", ["Answer 1","Answer B 1"], ["#smile"]),
  //   Flashcard("Temp Card 18", "deck9/layer2/", ["Answer 2","Answer B 2"], ["#smile"]),
  //   Flashcard("Temp Card 19", "deck10/layer1/", ["Answer 1","Answer B 1"], ["#smile"]),
  //   Flashcard("Temp Card 20", "deck10/layer2/", ["Answer 2","Answer B 2"]),
  // ];

  // Initialize the filter to be empty.
  Flashcard.setFilter([]);
}//e initialize()

/// Stores data for all the page routes.
Map<String, List<dynamic>> pageRoutes = {
  'home': ['/', HomePage(title: getString('title'))],
// 	'deck': ['/deck', DeckPage(title: getString('title_deck'))],
// 	'flashcards': ['/flashcards', FlashcardPage(title: getString('title_flashcards'))]
};

/// MyApp
/// The app :)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: getString('title'),
      theme: theme.getLightTheme(context),
      darkTheme: theme.getDarkTheme(context),
      themeMode: ThemeMode.system,
      // home: const HomePage(title: 'Flutter Demo Home Page'),
      routes: genRoutes(pageRoutes),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (p0) => Flashcard.popFilter(),
      child: Scaffold(
        appBar: AppBar(
          title: TextBold(widget.title),
        ),
        body: Aspect(child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SingleChildScrollView(child: Column(children: [
            startBtns(),
            deckBtns(Flashcard.filteredDecks, () => setState(() {})),
            cardBtns(Flashcard.filteredCards, () => setState(() {})),
            const Text(""),
          ]
        )))),
        floatingActionButton: FloatingActionButton(
          onPressed: () => createCardPopup(
            context,
            getString('header_create_new_card'),
            (p0, p1, p2, [p3]) { Flashcard.newCard(p0, p1, p2, p3); setState(() {});},
          ),
          tooltip: getString('tooltip_create_card'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}