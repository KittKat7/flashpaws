import 'package:flashpaws/flashcard.dart';
import 'package:flashpaws/multichoice.dart';
import 'package:flutter/material.dart';
import 'package:flutterkat/flutterkat.dart';
import 'package:flutterkat/graphics.dart';
import 'package:flutterkat/theme.dart';
import 'package:flutterkat/widgets.dart';

class MultiChoicePage extends StatefulWidget {

  const MultiChoicePage({super.key, required this.title});

  final String title;

  @override
  State<MultiChoicePage> createState() => _MultiChoicePageState();
}//e MultiChoicePage

class _MultiChoicePageState extends State<MultiChoicePage> {

  String filter = Flashcard.filter.join('/');
  MultiChoice test = MultiChoice();

  @override
  Widget build(BuildContext context) {

    Map<String, dynamic> cardData = test.getCard();

    String id = cardData['id']!;
    String key = cardData['key']!;
    List<String> values = cardData['values'];

    var txtID = TextItalic(id);
    // TODO BUG - Text key can extend offscreen
    var txtKey = Transform.scale(scale: 1.5, child: MarkD(key));

    List<Widget> answerBtnList = [];

    for (String v in values) {
      answerBtnList.add(
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(15),
              backgroundColor: test.getEnteredAnswer() == v? 
                getTheme(context).colorScheme.primary : getTheme(context).colorScheme.surface,
              shape: const BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0))),
            ),
            onPressed: () => setState(() => test.answerCard(v)),
            onLongPress: () => test.getEnteredAnswer() == v?
              setState(() => test.answerCard(null)) : null,
            child: MarkD(v))
        )
      );//e add
    }//e for

    var answerBtns = Column(mainAxisSize: MainAxisSize.min, children: answerBtnList);

    var keyWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        txtKey,
        const Divider(indent: 1, endIndent: 1),
        txtID,
        const Text(""),
        answerBtns
      ],
    );

    var navBtns = Row(children: [
      Expanded(
        flex: 1,
        child: IconButton(
          onPressed: () => test.hasPrevCard() ? setState(() => test.prevCard()) : null,
          icon: test.hasPrevCard() ?
            const Icon(Icons.chevron_left) : const Icon(Icons.circle_outlined)
        )
      ),
      const Expanded(flex: 2, child: SizedBox()),
      Expanded(
        flex: 1,
        child: IconButton(
          onPressed: () => test.hasNextCard() ?
            setState(() => test.nextCard()) :
            confirmPopup(
              context,
              getString('header_finish_test'),
              getString('msg_finish_test'),
              () {
                MultiChoice.test = test;
                // Navigator.of(context).pop();
                Navigator.of(context).popAndPushNamed(
                  getRoute('multichoiceResult'));
              }),
          icon: test.hasNextCard() ?
            const Icon(Icons.chevron_right) : const Icon(Icons.check)
        )
      ),
    ]);

    return Scaffold(
      appBar: AppBar(
        // TODO BUG - Text in title extends off screen
        title: TextBold(widget.title),
        centerTitle: true,
      ),
      body: Aspect(child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Align(alignment: Alignment.center, child:
          SingleChildScrollView(child: keyWidget))
        )),
      bottomNavigationBar: BottomAppBar(child: navBtns),
    );
  }//e build
}//e  _MultiChoicePageState



class MultiChoiceResultPage extends StatelessWidget {
  MultiChoiceResultPage({super.key, required this.title});

  final String title;

  final List<Flashcard> deck = Flashcard.filteredCards;

  @override
  Widget build(BuildContext context) {

    MultiChoice test = MultiChoice.test!;

    List<Widget> answeredCards = [];

    Map<String, num> results = test.getResults();
    num points = results['points']!;
    num total = results['total']!;
    num percent = (results['percent']!*100).round();

    answeredCards.add(
      MarkD(getString('txt_multichoice_stats', [points, total, percent]))
    );

    answeredCards.add(const Text(""));

    for (Flashcard card in test.deck) {
      List<Widget> cardList = [];
      cardList.add(TextItalic(card.id));
      cardList.add(const Divider(indent: 1, endIndent: 1));
    // TODO BUG - Text key can extend offscreen
      cardList.add(Transform.scale(scale: 1.5, child: MarkD(card.key)));

      List<Widget> answers = [];
      
      for (String ans in test.values[card.id]!) {
        String icon = "";
        Color buttonColor = getTheme(context).colorScheme.surface;
        if (ans == test.userAnswers[card.id]) {
          if (ans == card.values[0]) {
            icon = getString('ico_check');
            buttonColor = getTheme(context).colorScheme.primary;

          } else {
            icon = getString('ico_cross');
            buttonColor = getTheme(context).colorScheme.primary;
          }
        } else {
          if (ans == card.values[0]) {
            icon = getString('ico_mark');
            buttonColor = getTheme(context).colorScheme.error;
          }
        }
        answers.add(
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(15),
                backgroundColor: buttonColor,
                shape: const BeveledRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0))),
              ),
              onPressed: () {},
              child: MarkD("$icon $ans"))
          )
        );//e add
      }//e for
      cardList.addAll(answers);
      answeredCards.add(Column(mainAxisSize: MainAxisSize.min, children: cardList));
    }//e for

    return Scaffold(
      appBar: AppBar(
        // TODO BUG - Text in title extends off screen
        title: TextBold(title),
        centerTitle: true,
      ),
      body: Aspect(child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Align(alignment: Alignment.center, child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: answeredCards)
      )))),
    );
  }//e build()
}//e MultiChoiceResultPage
