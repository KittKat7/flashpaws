import 'dart:convert';

import 'package:flashpaws/multichoice_page.dart';
import 'package:flashpaws/practice_page.dart';
import 'package:flashpaws/review_page.dart';
import 'package:flashpaws/update.dart';
import 'package:flashpaws/widgets/flashcard_widget.dart';
import 'package:flutter/services.dart';

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
const String updateTimeStamp = String.fromEnvironment('buildTimeUTC', defaultValue: 'N/A');

const int version = 2024011300;

/// int version
Map<String, dynamic> metadata = {};



void main() async {
  await flutterkatInit();
  await initialize();
  flktRunApp(const MyApp());
}

/// initialize
/// This function initializes anything variables, like the hive box, that will be needed later on.
Future<void> initialize() async {
  // set language
  setLang(en_us.getLang);
  // Set aspect ratio
  setAspect(3, 4);
  // Initialize hive box.
  await Hive.initFlutter('katapp');
  box = await Hive.openBox('flashpaws');

  // Change from flkt version storage to hive version storage.
  if (flktLoad('version') != null) {
    box.put('metadata', json.encode(
      <String, dynamic>{'version': int.parse(flktLoad('version')!)}));
    await flktRemove('version');
  }//e if
  // Version update etc...
  if (!box.containsKey('metadata') || box.get('metadata').isEmpty
    || box.get('metadata')[0] is! String) {
    box.put('metedata', json.encode(<String, String>{'version': version.toString()}));
  } else {
    metadata = json.decode(box.get('metadata'));
    int savedVersion = metadata['version'];
    if (savedVersion < version) {
      await update(savedVersion, version);
    }//e if
  }//e if else
  
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
    Flashcard.saveCards(newCards);
  }//e if
  
  // For every card in the box, convert it from json, and add it to the list of cards.
  for (String json in box.get('flashcards')) {
    Flashcard.cards.add(Flashcard.fromJson(jsonDecode(json)));
  }//e for

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
    Drawer drawer = Drawer(
      child: ListView(
        padding: const EdgeInsets.only(top: 20),
        children: [
          Align(alignment: Alignment.center, child: TextBold(getString('header_settings_drawer', [updateTimeStamp]))),
          const Divider(),
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
            cardBtns(Flashcard.filteredCards, context, () => setState(() {})),
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