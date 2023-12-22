import 'package:flashpaws/flashcard.dart';
import 'package:flashpaws/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutterkat/theme.dart';
import 'package:flutterkat/widgets.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key, required this.title});

  final String title;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}//e ReviewPage

class _ReviewPageState extends State<ReviewPage> {

  bool isShowingValue = false;
  bool valueHasShown = false;
  Flashcard currentCard = Flashcard("K", "D", ["V"]);

  @override
  Widget build(BuildContext context) {
    
    var cardBtn = ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero))
      ),
      onPressed: () => setState(() { isShowingValue = !isShowingValue; valueHasShown = true; }),
      child: Padding(padding: EdgeInsets.all(10), child: 
        !isShowingValue? Column(children: [MarkD(currentCard.key), Divider()])
        : Column(children: [MarkD(currentCard.key), Divider(), MarkD(currentCard.values[0])])
      )//e Padding()
    );
    
    var confidenceBtns = Row(children: [
      Expanded(flex: 1, child: IconButton(
        onPressed: () => print("cnfdnc 0"),
        icon: currentCard.confidence == 0? Icon(Icons.remove_circle) : Icon(Icons.remove_circle_outline)
      )),
      Expanded(flex: 1, child: IconButton(
        onPressed: () => print("cnfdnc 1"),
        icon: currentCard.confidence == 1? Icon(Icons.circle) : Icon(Icons.circle_outlined)
      )),
      Expanded(flex: 1, child: IconButton(
        onPressed: () => print("cnfdnc 2"),
        icon: currentCard.confidence == 2? Icon(Icons.add_circle) : Icon(Icons.add_circle_outline)
      )),
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
    );
  }//e build
}//e  _ReviewPageState