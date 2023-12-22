import 'package:flashpaws/flashcard.dart';
import 'package:flashpaws/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutterkat/flutterkat.dart';
import 'package:flutterkat/theme.dart';
import 'package:flutterkat/widgets.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key, required this.title});

  final String title;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}//e ReviewPage

class _ReviewPageState extends State<ReviewPage> {

  List<Flashcard> deck = Flashcard.getShuffledFilteredCards();

  int index = 0;
  bool isShowingValue = false;
  bool valueHasShown = false;

  @override
  Widget build(BuildContext context) {
    Flashcard currentCard = deck[index];

    flipCard() {setState(() {
      isShowingValue = !isShowingValue;
      valueHasShown = true;
    });}//e flipCard()

    nextCard() {setState(() {
      isShowingValue = false;
      valueHasShown = false;
      if (index < deck.length - 1) {
        index++;
      } else {
        Navigator.of(context).popAndPushNamed(getRoute('reviewComplete'));
      }
    });}//e nextCard()

    prevCard() {setState(() {
      isShowingValue = false;
      valueHasShown = false;
      if (index > 0) {
        index--;
      }
    });}//e prevCard()

    setConfidence(int cnfdnc) {setState(() {
      currentCard.confidence = cnfdnc;
    });}//e setConfidence()

    var cardBtn = ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero))
      ),
      onPressed: () => flipCard(),
      child: Padding(padding: EdgeInsets.all(10), child: 
        !isShowingValue? Column(children: [MarkD(currentCard.key), Divider()])
        : Column(children: [MarkD(currentCard.key), Divider(), MarkD(currentCard.values[0])])
      )//e Padding()
    );
    
    var confidenceBtns = Row(children: [
      Expanded(flex: 1, child: IconButton(
        onPressed: () => currentCard.confidence == 0? setConfidence(-1) : setConfidence(0),
        color: Colors.red,
        icon: Icon(currentCard.confidence == 0? Icons.remove_circle : Icons.remove_circle_outline)
      )),
      Expanded(flex: 1, child: IconButton(
        onPressed: () => currentCard.confidence == 1? setConfidence(-1) : setConfidence(1),
        color: Colors.grey[400],
        icon: Icon(currentCard.confidence == 1?  Icons.circle : Icons.circle_outlined)
      )),
      Expanded(flex: 1, child: IconButton(
        onPressed: () => currentCard.confidence == 2? setConfidence(-1) : setConfidence(2),
        color: Colors.green,
        icon: Icon(currentCard.confidence == 2? Icons.add_circle : Icons.add_circle_outline)
      )),
    ]);

    var navBtns = Row(children: [
      Expanded(
        flex: 1,
        child: IconButton(onPressed: () => prevCard(), icon: Icon(Icons.chevron_left))
      ),
      Expanded(
        flex: 1,
        child: IconButton(onPressed: () => nextCard(), icon: Icon(Icons.chevron_right))
      ),
    ]);
    
    return Scaffold(
      appBar: AppBar(
        title: TextBold(widget.title),
      ),
      body: Aspect(child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Align(alignment: Alignment.center, child: SingleChildScrollView(child: Column(children: [
          // ITEMS:
          // complete/total
          
          // Card
          cardBtn,
          // Rating slider
          if (valueHasShown) confidenceBtns,
          // Back / Forward arrows
        ]
      ))))),
      bottomNavigationBar: BottomAppBar(child: navBtns),
    );
  }//e build
}//e  _ReviewPageState

class ReviewCompletePage extends StatefulWidget {
  const ReviewCompletePage({super.key, required this.title});

  final String title;

  @override
  State<ReviewCompletePage> createState() => _ReviewCompletePageState();
}

class _ReviewCompletePageState extends State<ReviewCompletePage> {

  List<Flashcard> deck = Flashcard.filteredCards;

  int score = 0;
  double percentScore = 0;

  @override
  Widget build(BuildContext context) {
    for (Flashcard c in deck) {
      if (c.confidence != -1) {
        score += c.confidence;
      }
    }
    percentScore = (score / (deck.length * 2)) * 100;

    return Scaffold(
      appBar: AppBar(
        title: TextBold(widget.title),
      ),
      body: Aspect(child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SingleChildScrollView(child: 
        MarkD("**STATS:**  \n**Score:** $score / ${deck.length * 2}  \n**Percent:** $percentScore")
      ))),
    );
  }
}