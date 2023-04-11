import 'package:anime_watch/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';

class HiddenDrawer extends StatefulWidget {
  const HiddenDrawer({super.key});

  @override
  State<HiddenDrawer> createState() => _HiddenDrawerState();
}

class _HiddenDrawerState extends State<HiddenDrawer> {
  late List<ScreenHiddenDrawer> _pages;

  @override
  void initState() {
    _pages = [
      ScreenHiddenDrawer(
          ItemHiddenMenu(
              colorLineSelected: Colors.deepPurple.shade800,
              name: 'Aniboy',
              baseStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              selectedStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          const HomePage()),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenu(
      boxShadow: [
        BoxShadow(
          color: Colors.deepPurple.shade800,
          spreadRadius: 1,
          offset: const Offset(-3, 0),
          blurRadius: 25,
        )
      ],
      tittleAppBar: const Text(
        'Aniboy',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actionsAppBar: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 10,
            width: 50,
            decoration: BoxDecoration(
                color: Colors.green,
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(10)),
            child: const Center(
              child: Text(
                'Ads',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 10,
            width: 100,
            decoration: BoxDecoration(
                color: Colors.amberAccent,
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(10)),
            child: const Center(
              child: Text(
                'Pre-release',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
        )
      ],
      backgroundColorAppBar: Colors.black,
      slidePercent: 50,
      elevationAppBar: 0,
      verticalScalePercent: 100,
      backgroundColorMenu: Colors.deepPurple.shade100,
      screens: _pages,
      initPositionSelected: 0,
    );
  }
}
