part of '../widgets.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key, required this.title});

  final String title;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}//e ReviewPage

class _ReviewPageState extends State<ReviewPage> {

  completeReview() {
    Navigator.pop(context);
    Navigator.push(context, genRoute(ReviewCompletePage(title: "")));
    // Navigator.of(context).popAndPushNamed(getRoute('reviewComplete'));
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
          Marked(review.currentKey),
          SimpleText(review.currentDeck, isItalic: true),
          const Divider()])
        : Column(children: [
          Marked(review.currentKey),
          SimpleText(review.currentDeck, isItalic: true),
          const Divider(),
          Marked(review.currentValue)])
      )//e Padding()
    );
    
    var confidBtns = confidenceBtns(
      review.confidence, (p) {
        setState(() => review.setConfidence(p));
        saveCards();
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
          onPressed: () => review.hasNextCard()? setState(() => review.nextCard()) :
            confirmPopup(
              context,
              getLang('header_finish_review'),
              getLang('msg_finish_review'),
              completeReview),
          icon: review.hasNextCard()? const Icon(Icons.chevron_right) : const Icon(Icons.check)
        )
      ),
    ]);
    
    return Scaffold(
      appBar: AppBar(
        title: SimpleText("${widget.title} - ${review.index + 1}/${review.length}", isBold: true,),
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
        title: SimpleText(title, isBold: true),
        centerTitle: true,
      ),
      body: Aspect(child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Align(alignment: Alignment.center, child: SingleChildScrollView(child: 
        Marked(getLang('txt_review_stats', [results['points'], results['total'], results['percent']]))
      )))),
    );
  }//e build()
}//e ReviewCompletePage
