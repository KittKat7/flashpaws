import 'package:flutter/material.dart';
import 'package:flutterkat/widgets.dart';
Widget deckBtns(List<String> decks) {
  List<Widget> children = [];
  for (String deck in decks) {
    children.add(
      FilledButton(onPressed: () => print("hello"), child: MarkD(deck))
    );
  }
  Widget grid = GridView.count(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, children: children,);
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

