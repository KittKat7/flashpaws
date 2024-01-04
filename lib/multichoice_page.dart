import 'dart:async';

import 'package:flashpaws/flashcard.dart';
import 'package:flashpaws/multichoice.dart';
import 'package:flashpaws/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutterkat/flutterkat.dart';
import 'package:flutterkat/graphics.dart';
import 'package:flutterkat/theme.dart';
import 'package:flutterkat/widgets.dart';

class AnswerButton extends StatelessWidget {

  final String text;
  final bool? isSelectedAnswer;
  final Color? backgroundColor;
  final void Function() onPressed;
  final void Function()? onLongPress;

  const AnswerButton({
    super.key, 
    required this.text,
    required this.onPressed,
    this.onLongPress,
    this.isSelectedAnswer,
    this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    late Color bgColor;

    if (backgroundColor != null) {
      bgColor = backgroundColor!;
    } else if (isSelectedAnswer ?? false) {
      bgColor = getTheme(context).colorScheme.primary;
    } else {
      bgColor = getTheme(context).colorScheme.surface;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: expand(ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(15),
          backgroundColor: bgColor,
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0))),
        ),
        onPressed: onPressed,
        onLongPress: onLongPress,
        child: Markd(text))
    ));
  }//e build()

}//e AnswerButton

class MultiChoicePage extends StatefulWidget {

  const MultiChoicePage({super.key, required this.title});

  final String title;

  @override
  State<MultiChoicePage> createState() => _MultiChoicePageState();
}//e MultiChoicePage

class _MultiChoicePageState extends State<MultiChoicePage> {

  String filter = Flashcard.filter.join('/');
  MultiChoice test = MultiChoice();

  Duration timeElapsed = Duration();
  String get timeElapsedStr {
    return timeElapsed.toString().substring(0, timeElapsed.toString().length - 7);
  }

  Stopwatch stopwatch = Stopwatch()..start();

  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    stopwatch.stop();
    super.dispose();
  }

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => timeElapsed = stopwatch.elapsed);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Map<String, dynamic> cardData = test.getCard();

    String id = cardData['id']!;
    String key = cardData['key']!;
    List<String> values = cardData['values'];

    var txtID = padLeftRight(TextItalic(id), 15);
    // TODO BUG - Text key can extend offscreen
    var txtKey = padLeftRight(HeaderMarkd(key), 15);

    List<Widget> answerBtnList = [];

    for (String v in values) {
      bool isSelectedAnswer = test.getEnteredAnswer() == v;
      answerBtnList.add(
        AnswerButton(
          text: v,
          isSelectedAnswer: isSelectedAnswer,
          onPressed: () => setState(() => test.answerCard(v)),
          onLongPress: () => isSelectedAnswer? setState(() => test.answerCard(null)) : null)
      );//e add
    }//e for

    var answerBtns = Column(mainAxisSize: MainAxisSize.min, children: answerBtnList);

    var keyWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        txtKey,
        txtID,
        const ThickDivider(),
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
      Expanded(flex: 2, child: Center(child: Markd(timeElapsedStr, scale: 1.5,))),
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
                test.endTime = DateTime.now();
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

    Map<String, dynamic> results = test.getResults();
    num points = results['points']!;
    num total = results['total']!;
    num percent = (results['percent']!*100).round();

    answeredCards.add(
      Markd(getString('txt_multichoice_stats', [points, total, percent]))
    );

    answeredCards.add(const Text(""));

    for (Flashcard card in test.deck) {
      List<Widget> cardList = [];
      cardList.add(padLeftRight(HeaderMarkd(card.key), 15));
      cardList.add(padLeftRight(TextItalic(card.deck), 15));
      cardList.add(const ThickDivider());
    // TODO BUG - Text key can extend offscreen

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
            buttonColor = getTheme(context).colorScheme.error;
          }
        } else {
          if (ans == card.values[0]) {
            icon = getString('ico_check');
            buttonColor = getTheme(context).colorScheme.error;
          }
        }
        answers.add(
          AnswerButton(
            text: "$icon $ans",
            onPressed: () {},
            backgroundColor: buttonColor)
        );//e add
      }//e for
      cardList.addAll(answers);
      cardList.add(const Text(""));
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
      bottomNavigationBar: BottomAppBar(child: Center(
        child: Markd(
          results['duration']!.toString().substring(0, results['duration']!.toString().length - 7),
          scale: 1.5,))),
    );
  }//e build()
}//e MultiChoiceResultPage
