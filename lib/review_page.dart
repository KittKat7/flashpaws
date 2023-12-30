import 'package:flashpaws/flashcard.dart';
import 'package:flashpaws/review.dart';
import 'package:flashpaws/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutterkat/flutterkat.dart';
import 'package:flutterkat/graphics.dart';
import 'package:flutterkat/widgets.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key, required this.title});

  final String title;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}//e ReviewPage

class _ReviewPageState extends State<ReviewPage> {

  completeReview() {
    Navigator.of(context).popAndPushNamed(getRoute('reviewComplete'));
  }

  @override
  void initState() {
    Review.review = Review();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Review review = Review.review;

    var cardBtn = ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero))
      ),
      onPressed: () => setState(() => review.flipCard()),
      child: Padding(padding: const EdgeInsets.all(10), child: 
        !review.isShowingValue? Column(children: [
          MarkD(review.currentKey),
          TextItalic(review.currentDeck),
          const Divider()])
        : Column(children: [
          MarkD(review.currentKey),
          TextItalic(review.currentDeck),
          const Divider(),
          MarkD(review.currentValue)])
      )//e Padding()
    );
    
    var confidBtns = confidenceBtns(
      review.getConfidence(), (p) {
        setState(() => review.setConfidence(p));
        Flashcard.saveCards();
      }
    );

    var navBtns = Row(children: [
      Expanded(
        flex: 1,
        child: IconButton(
          onPressed: () => review.hasPrevCard()? setState(() => review.prevCard()) : null,
          icon: review.hasPrevCard()?
            const Icon(Icons.chevron_left) : const Icon(null)
        )
      ),
      Expanded(flex: 2, child: confidBtns),
      Expanded(
        flex: 1,
        child: IconButton(
          onPressed: () => review.hasNextCard()? setState(() => review.nextCard())
            : confirmPopup(context, "//TODO", "//TODO", completeReview),
          icon: review.hasNextCard()? const Icon(Icons.chevron_right) : const Icon(Icons.check)
        )
      ),
    ]);
    
    return Scaffold(
      appBar: AppBar(
        title: TextBold("${widget.title} - ${review.index + 1}/${review.length}"),
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

  @override
  Widget build(BuildContext context) {
    Map<String, num> results = Review.review.getData();

    return Scaffold(
      appBar: AppBar(
        title: TextBold(title),
        centerTitle: true,
      ),
      body: Aspect(child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Align(alignment: Alignment.center, child: SingleChildScrollView(child: 
        MarkD(getString('txt_review_stats', [results['points'], results['total'], results['percent']]))
      )))),
    );
  }//e build()
}//e ReviewCompletePage
