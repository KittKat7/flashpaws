import 'package:flashpaws/inout.dart';
import 'package:flashpaws/metadata.dart';
import 'package:flashpaws/update.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutterkat/flutterkat.dart';
import 'package:flutterkat/lang.dart';
import 'package:flutterkat/graphics.dart';
import 'package:flutterkat/widgets.dart';
import 'flashcard.dart';
import 'package:flutterkat/theme.dart' as theme;
import './lang/en_us.dart' as en_us;

const String updateTimeStamp = String.fromEnvironment('buildTimeUTC', defaultValue: 'N/A');

void main() async {
  await flutterkatInit('flashpaws');
  await initialize();
  flktRunApp(const MyApp());
}//e main()

/// This function initializes anything variables, like the hive box, that will be needed later on.
Future<void> initialize() async {
  // SharedPreferences.setPrefix('flashpaws');
  prefs = await SharedPreferences.getInstance();

  loadMetadata();

  // Initialize app version.
  setAppVersion(2024011300);

  // set language
  setLang(en_us.getLang);
  // Set aspect ratio
  setAspect(3, 4);
  // Initialize hive box.

  List<Flashcard> savedCards = loadCards();
  
  // If there are no prexisting cards, or something was saved incorrectly and not saved as a String,
  // create the list of introduction flashcards.
  if (savedCards.isEmpty) {
    // List of new flashcards to be added.
    List<Flashcard> newCards = [
      // Flashcard for how to make a new card.
      Flashcard(
        key: getString('introcard_how_to_new_card'),
        deck: '/introduction/',
        values: [getString('introcard_how_to_new_card_answer')],
      ),
      // Flashcard for how to sort cards.
      Flashcard(
        key: getString('introcard_how_to_sort_cards'),
        deck: '/introduction/',
        values: [getString('introcard_how_to_sort_cards_answer')],
      ),
      // Flashcard for how to practice the flashcards.
      Flashcard(
        key: getString('introcard_how_to_practice'),
        deck: '/introduction/',
        values: [getString('introcard_how_to_practice_answer')],
      ),
    ];//e newCards
    
    // Save flashcards.
    saveCards(newCards);
  }//e if
  
  Flashcard.cards = loadCards();

  // Initialize the filter to be empty.
  Flashcard.setFilter([]);
}//e initialize()

/// Stores data for all the page routes.
Map<String, List<dynamic>> pageRoutes = {
  'home': ['/', HomePage(title: getString('title'))],
  'review': ['/review/', ReviewPage(title: getString('reviewPage'))],
  'reviewComplete': ['/review/complete/', ReviewCompletePage(title: getString('reviewCompletePage'))],
  'practice': ['/practice/', PracticePage(title: getString('practicePage'))],
  'multichoice': ['/multichoice/', MultiChoicePage(title: getString('multichoicePage'))],
  'multichoiceResult': ['/multichoice/result/', MultiChoiceResultPage(title: getString('multichoiceResultPage'))],
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
      themeMode: theme.getThemeMode(context),
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
    // The drawer to be displayed on the overview page.
    Drawer drawer = Drawer(
      child: ListView(
        padding: const EdgeInsets.only(top: 20),
        children: [
          Align(alignment: Alignment.center, child: TextBold(getString('header_settings_drawer', [updateTimeStamp]))),
          const Divider(),
          // Import export buttons.
          // Export JSON
          ElevatedButton(
            onPressed: () => importCardsJson(context, () => setState(() => Flashcard.setFilter(null))),
            child: Markd(getString('btn_import_json'))),
          ElevatedButton(
            onPressed: () => exportCardsJson(metadata, Flashcard.filteredCards),
            child: Markd(getString('btn_export_json'))),
          const Divider(),
          // Theme settings buttons.
          ElevatedButton(
            onPressed: () => themeModePopup(context),
            child: Markd(getString('btn_theme_brightness_menu'))),
          ElevatedButton(
            // onPressed: () => getColorTheme(context).cycleColor(),
            onPressed: () => themeColorPopup(context),
            child: Markd(getString('btn_theme_color_menu')))
        ]
      )
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (p0) { 
        if (Flashcard.filter.isNotEmpty) {
          setState(() => Flashcard.popFilter());
        } else {
          confirmPopup(
            context,
            getString('header_exit_app'),
            getString('msg_confirm_app_exit'),
            () => SystemChannels.platform.invokeMethod('SystemNavigator.pop')
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(builder: (context) {
            return IconButton(icon: const Icon(Icons.menu), onPressed: () { 
              // Navigator.of(context).pushNamed(getRoute('settings'));
              Scaffold.of(context).openDrawer(); 
            });
          }),
          title: TextBold(widget.title),
          centerTitle: true,
        ),
        drawer: drawer,
        body: Aspect(child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SingleChildScrollView(child: Column(children: [
            startBtns(),
            deckBtns(Flashcard.filteredDecks, () => setState(() {})),
            CardButtonColumn(cards: Flashcard.filteredCards, updateState: () => setState(() {})),
            // cardBtns(Flashcard.filteredCards, context, () => setState(() {})),
            const Text(""),
          ]
        )))),
        floatingActionButton: FloatingActionButton(
          // onPressed: () => createCardPopup(
          //   context,
          //   (p0, p1, p2, [p3]) {
          //     Flashcard.newCard(p0, p1, p2, p3);
          //     setState(() => Flashcard.setFilter(Flashcard.filter));
          //   },
          //   Flashcard.filter.join('/')
          // ),
          onPressed: () => flashcardWidgetPopup(
            context: context,
            superSetState: () => setState(() {}),
            isEditing: true),
          tooltip: getString('tooltip_create_card'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}