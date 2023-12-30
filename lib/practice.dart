import 'package:flashpaws/flashcard.dart';
import 'package:flashpaws/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutterkat/flutterkat.dart';
import 'package:flutterkat/widgets.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key, required this.title});

  final String title;

  @override
  State<PracticePage> createState() => _PracticePageState();
}//e PracticePage

class _PracticePageState extends State<PracticePage> {

  List<Flashcard> deck = Flashcard.getShuffledFilteredCards();

  bool isShowingValue = false;
  bool valueHasShown = false;
  int cardsPracticed = 0;

  @override
  Widget build(BuildContext context) {
    Flashcard currentCard = deck[0];

    flipCard() {setState(() {
      isShowingValue = !isShowingValue;
      valueHasShown = true;
    });}//e flipCard()

    nextCard() {setState(() {
      isShowingValue = false;
      valueHasShown = false;
      Flashcard currCard = currentCard;
      deck = deck.sublist(1);
      deck.shuffle();
      deck.add(currCard);
      cardsPracticed++;
    });}//e nextCard()

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
      const Expanded(
        flex: 1,
        child: SizedBox()
      ),
      Expanded(flex: 2, child: confidBtns),
      Expanded(
        flex: 1,
        child: IconButton(
          onPressed: () => nextCard(),
          icon: const Icon(Icons.chevron_right)
        )
      ),
    ]);
    
    return Scaffold(
      appBar: AppBar(
        title: TextBold(getString('practicePage', [cardsPracticed])),
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
}//e  _PracticePageState

// class PracticeCompletePage extends StatefulWidget {
//   const PracticeCompletePage({super.key, required this.title});

//   final String title;

//   @override
//   State<PracticeCompletePage> createState() => _PracticeCompletePageState();
// }

// class _PracticeCompletePageState extends State<PracticeCompletePage> {

//   List<Flashcard> deck = Flashcard.filteredCards;

//   int score = 0;
//   double percentScore = 0;

//   @override
//   Widget build(BuildContext context) {
//     for (Flashcard c in deck) {
//       if (c.confidence != -1) {
//         score += c.confidence;
//       }
//     }
//     percentScore = (score / (deck.length * 2)) * 100;

//     return Scaffold(
//       appBar: AppBar(
//         title: TextBold(widget.title),
//       ),
//       body: Aspect(child: Padding(
//         padding: const EdgeInsets.only(top: 10),
//         child: SingleChildScrollView(child: 
//         MarkD("**STATS:**  \n**Score:** $score / ${deck.length * 2}  \n**Percent:** $percentScore")
//       ))),
//     );
//   }
// }