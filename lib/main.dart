import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:nfc_poc/views/pages/MyNumberPage.dart';
import 'package:nfc_poc/views/pages/HomePage.dart';
import 'package:nfc_poc/views/pages/SuicaPage.dart';

const String MyNumberPageName = "myNumber";
const String SuicaPageName = "Suica";

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'Flutter Demo Home Page'),
      routes: <String, WidgetBuilder> {
        MyNumberPageName: (BuildContext context) => new MyNumberPage(title: 'マイナンバー読み取り'),
        SuicaPageName: (BuildContext context) => new SuicaPage(title: 'Suicaの読み取り')
      },
    );
  }
}
