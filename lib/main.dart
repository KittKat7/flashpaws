import 'package:flutter/material.dart';
import 'package:flutterkat/flutterkat.dart';
import 'package:flutterkat/lang.dart';
import './lang/en_us.dart' as en_us;

void main() async {
	await initialize();
	flktRunApp(const MyApp());
}

/// initialize
/// This function initializes anything variables, like the hive box, that will be needed later on.
Future<void> initialize() async {
	setLang(en_us.getLang);
	// Initialize hive box.
	await Hive.initFlutter('katapp');
	box = await Hive.openBox('flashpaws');
	// Get a list of all the stored decks.
	for (String key in box.keys) {
		Deck.decks[key] = Deck.fromJson(jsonDecode(box.get(key)));
	}
	// Set up the default aspect ratio.
	setAspect(3, 4);
}

/// Stores data for all the page routes.
Map<String, List<dynamic>> pageRoutes = {
	'home': ['/', HomePage(title: getString('title'))],
	'deck': ['/deck', DeckPage(title: getString('title_deck'))],
	'flashcards': ['/flashcards', FlashcardPage(title: getString('title_flashcards'))]
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


class _HomePageState extends State<HomePage> {

	@override
	Widget build(BuildContext context) {
		/// All the buttons that corrospond to the Deskc.
		var children = [
			for (String name in Deck.decks.keys)
				ElevatedButton(
					style: ElevatedButton.styleFrom(
						minimumSize: const Size(double.infinity, double.infinity),
					),
					onPressed: () {Deck.currentDeckName = name; Navigator.pushNamed(context, getRoute('deck'));},
					onLongPress: () => setState(() => Deck.delDeck(name)),
					child: MarkD(name),
			)
		];
		
		// return
		return Scaffold(
			appBar: AppBar(
				title: TextBold(widget.title),
			),
			body: Aspect(child: Padding(padding: const EdgeInsets.only(top: 10),
			child: DeckTileGrid(children: children),
			)),
			floatingActionButton: FloatingActionButton(
				onPressed: () => enterTxtPopup(context, getString('prompt_create_new_deck'), (p0) => setState( () => Deck.addDeck(p0)),),
				tooltip: getString('tooltip_create_new_deck'),
				child: const Icon(Icons.add),
			), // This trailing comma makes auto-formatting nicer for build methods.
		);
	}
}