part of '../widgets.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key, required this.title});

  final String title;

  @override
  State<PracticePage> createState() => _PracticePageState();
}//e PracticePage

class _PracticePageState extends State<PracticePage> {

  @override
  void initState() {
    Practice.practice = Practice();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    Practice practice = Practice.practice;

    var cardBtn = ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero))
      ),
      onPressed: () => setState(() => practice.flipCard()),
      child: Padding(padding: const EdgeInsets.all(10), child: 
        !practice.isShowingValue? Column(children: [
          Markd(practice.currentKey),
          TextItalic(practice.currentDeck),
          const Divider()])
        : Column(children: [
          Markd(practice.currentKey),
          TextItalic(practice.currentDeck),
          const Divider(),
          Markd(practice.currentValue)])
      )//e Padding()
    );
    
    var confidBtns = confidenceBtns(practice.confidence, (p) {
      setState(() => practice.setConfidence(p));
      saveCards();
    });

    var navBtns = Row(children: [
      const Expanded(
        flex: 1,
        child: SizedBox()
      ),
      Expanded(flex: 2, child: confidBtns),
      Expanded(
        flex: 1,
        child: IconButton(
          onPressed: () => setState(() => practice.nextCard()),
          icon: const Icon(Icons.chevron_right)
        )
      ),
    ]);
    
    return Scaffold(
      appBar: AppBar(
        title: TextBold(getString('practicePage', [practice.cardsPracticed])),
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
