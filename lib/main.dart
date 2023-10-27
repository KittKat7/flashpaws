import 'package:flutter/material.dart';
import 'package:flutterkat/flutterkat.dart';
import 'package:flutterkat/lang.dart';
import 'package:flutterkat/graphics.dart';
import 'package:flutterkat/widgets.dart';
import 'package:flutterkat/theme.dart' as theme;
import 'package:hive_flutter/hive_flutter.dart';
import './lang/en_us.dart' as en_us;

late Box box;

const int version = 2023102700;

void main() async {
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

  
  

	setLang(en_us.getLang);
	// Initialize hive box.
	await Hive.initFlutter('katapp');
	box = await Hive.openBox('flashpaws');

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
			body: Aspect(child: Padding(padding: const EdgeInsets.only(top: 10), child: null ?? null,)),
			floatingActionButton: FloatingActionButton(
				onPressed: () => enterTxtPopup(context, getString('prompt_create_new_deck'), (p0) => print("//TODO add a deck"),),
				tooltip: getString('tooltip_create_new_deck'),
				child: const Icon(Icons.add),
			), // This trailing comma makes auto-formatting nicer for build methods.
		);
	}
}