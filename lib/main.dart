import 'package:anime_watch/pages/terms.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:anime_watch/widgets/hidden_drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLovinMAX.initialize(
      'ckFF4xBqSCd2idT6c02JklHrbWXkZPW8sGhdeWS25bQKEa6LMWIRIK60L9AOCmEw8T2Lahv5ia4w7MlBLscnIH');

  SharedPreferences pref = await SharedPreferences.getInstance();
  bool firstTime = pref.getBool('firstTime') ?? true;
  runApp(MyApp(
    firstTime: firstTime,
  ));
}

class MyApp extends StatelessWidget {
  bool firstTime;
  MyApp({super.key, required this.firstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: firstTime ? const Terms() : const HiddenDrawer(),
    );
  }
}
