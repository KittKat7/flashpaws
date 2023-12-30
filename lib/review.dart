import 'package:flashpaws/flashcard.dart';
import 'package:flashpaws/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutterkat/flutterkat.dart';
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
      child: Padding(padding: const EdgeInsets.all(10), child: 
        !isShowingValue? Column(children: [
          MarkD(currentCard.key),
          TextItalic(currentCard.deck),
          const Divider()])
        : Column(children: [
          MarkD(currentCard.key),
          TextItalic(currentCard.deck),
          const Divider(),
          MarkD(currentCard.values[0])])
      )//e Padding()
    );
    
    var confidBtns = confidenceBtns(currentCard, (p) { setConfidence(p); Flashcard.saveCards(); });

    var navBtns = Row(children: [
      Expanded(
        flex: 1,
        child: IconButton(
          onPressed: () => index != 0 ? prevCard() : nextCard(),
          icon: index != 0 ? const Icon(Icons.chevron_left) : const Icon(Icons.chevron_right)
        )
      ),
      Expanded(flex: 2, child: confidBtns),
      Expanded(
        flex: 1,
        child: IconButton(
          onPressed: () => nextCard(),
          icon: index < deck.length-1? const Icon(Icons.chevron_right) : const Icon(Icons.check)
        )
      ),
    ]);
    
    return Scaffold(
      appBar: AppBar(
        title: TextBold("${widget.title} - ${deck.indexOf(currentCard)}/${deck.length}"),
        centerTitle: true,
      ),
      body: Aspect(child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Align(alignment: Alignment.center, child:
          SingleChildScrollView(child: cardBtn)
        ))),
      bottomNavigationBar: BottomAppBar(child: navBtns),
    );
  }//e build
}//e  _ReviewPageState

class ReviewCompletePage extends StatelessWidget {
  ReviewCompletePage({super.key, required this.title});

  final String title;

  final List<Flashcard> deck = Flashcard.filteredCards;

  @override
  Widget build(BuildContext context) {
    int score = 0;
    double percentScore = 0;

    for (Flashcard c in deck) {
      if (c.confidence != -1) {
        score += c.confidence;
      }//e if
    }//e for
    percentScore = ((score / 2) / deck.length) * 100;

    return Scaffold(
      appBar: AppBar(
        title: TextBold(title),
        centerTitle: true,
      ),
      body: Aspect(child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Align(alignment: Alignment.center, child: SingleChildScrollView(child: 
        MarkD(getString('txt_review_stats', [(score / 2), deck.length, percentScore.round()]))
      )))),
    );
  }//e build()
}//e ReviewCompletePage
