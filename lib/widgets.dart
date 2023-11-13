import 'package:flashpaws/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:flutterkat/widgets.dart';
Widget deckBtns(List<String> decks, BuildContext context, State state) {
  List<Widget> children = [];
  // add btns for lower level decks
  children.add(
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).cardColor),
        onPressed: () { Flashcard.setFilter([]); state.setState(() {});},
        child: MarkD("All")
      )
    );
  for (int i = 0; i < Flashcard.filter.length; i++) {
    String str = "";
    String subd = Flashcard.filter[i];
    for (int j = 0; j < i; j++) {
      str += "${Flashcard.filter[j]}/";
    } str += Flashcard.filter[i];
    children.add(
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).cardColor),
        onPressed: () { Flashcard.setFilter(str.split("/")); state.setState(() {});},
        child: MarkD(subd)
      )
    );
  }
  
  for (String deck in decks) {
    children.add(
      ElevatedButton(onPressed: () { Flashcard.pushFilter(deck); state.setState(() {});}, child: MarkD(deck))
    );
  }
  Widget grid = GridView.count(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 4, children: children,);
  return grid;
}

/*
const DeckTileGrid({
		super.key,
		required this.children,
	});

	final List<ElevatedButton> children;

	@override
	Widget build(BuildContext context) {
		return GridView.count(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, children: children,);
	}
*/

