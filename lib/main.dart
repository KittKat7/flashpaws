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
      print("//TODO VERSION MISMATH CODE EXECURE HERE");
    }
  } else {
    flktSave('version', version.toString());
  }

  // set language
	setLang(en_us.getLang);
	// Initialize hive box.
	await Hive.initFlutter('katapp');
	box = await Hive.openBox('flashpaws');

  if (!box.containsKey('flashcards')) box.put('flashcards', []);
  // load from hive //TODO
  List<Flashcard> tmpCards = List<Flashcard>.from(box.get('flashcards'));
  //TODO remove
  tmpCards = [
    Flashcard("card1", ["1"], "odd", "", ["taga"]),
    Flashcard("card2", ["2"], "even", "", ["taga"]),
    Flashcard("card3", ["3"], "odd", "", ["tagb"]),
    Flashcard("card4", ["4"], "even", "", ["tagb"]),
    Flashcard("card5", ["5"], "odd", "", ["tagc"]),
    Flashcard("card6", ["6"], "even", "", ["tagc"]),
    Flashcard("card7", ["7"], "odd", "", ["tagd"]),
  ];
  for (Flashcard c in tmpCards) {
    // Add flashcard to deck
    // if the referenced deck already exists add the card to it
    // else create the deck, then add the card to it.
    if (decks.containsKey(c.deck)) {
      decks[c.deck]!.add(c);
    } else {
      decks[c.deck] = [c];
    } // end if else

    // Add the card to any tagGroups
    for (String t in c.tags) {
      // if The tagGroup already exists, add the card to it.
      // else Create the tagGroup with the card in it
      if (tagGroups.containsKey(t)) {
        tagGroups[t]!.add(c);
      } else {
        tagGroups[t] = [c];
      } // end if else
    } // end for


    if (c.topic.isNotEmpty) {
      if (topics.containsKey(c.topic)) {
        topics[c.topic]!.add(c.deck);
      } else {
        topics[c.topic] = [c.deck];
      } // end if else
    } // end if
  } // end for

	// Set up the default aspect ratio.
	setAspect(3, 4);
}

/// Stores data for all the page routes.
Map<String, List<dynamic>> pageRoutes = {
	'home': ['/', HomePage(title: getString('title'))],
// 	'deck': ['/deck', DeckPage(title: getString('title_deck'))],
// 	'flashcards': ['/flashcards', FlashcardPage(title: getString('title_flashcards'))]
};

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
		return Scaffold(
			appBar: AppBar(
				title: TextBold(widget.title),
			),
			body: Aspect(child: Padding(padding: const EdgeInsets.only(top: 10), child: deckBtns(List.from(decks.keys)))),
			floatingActionButton: FloatingActionButton(
				onPressed: () => enterTxtPopup(context, "getString('prompt_create_new_deck')", (p0) => print("//TODO add a deck $p0"),),
				tooltip: "getString('tooltip_create_new_deck')",
				child: const Icon(Icons.add),
			), // This trailing comma makes auto-formatting nicer for build methods.
		);
	}
}