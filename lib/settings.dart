import 'package:flashpaws/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutterkat/flutterkat.dart';
import 'package:flutterkat/theme.dart';
import 'package:flutterkat/widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title});

  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextBold(widget.title),
      ),
      body: Aspect(child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SingleChildScrollView(child: Align(alignment: Alignment.center, child: Column(children: [
          ElevatedButton(onPressed: () =>  themeMenuPopup(context), child: MarkD(getString('btn_theme_brightness_menu'))),
          ElevatedButton(onPressed: () =>  getColorTheme(context).cycleColor(), child: MarkD(getString('btn_cycle_theme_color')))
        ])))
      )),
    );
  }
}