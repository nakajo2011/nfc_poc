import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_poc/views/pages/CreateSignaturePage.dart';
import 'package:nfc_poc/views/pages/HomePage.dart';
import 'package:nfc_poc/views/pages/PersonalInfoPage.dart';
import 'package:nfc_poc/views/pages/SelfCertPage.dart';

const String PersonalInfoPageName = "personalInfo";
const String SelfCertPageName = "selfCert";
const String CreateSignaturePageName = "createSig";

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
      home: HomePage(key: GlobalKey(), title: 'Flutter Demo Home Page'),
      routes: <String, WidgetBuilder> {
        PersonalInfoPageName: (BuildContext context) => PersonalInfoPage(key: GlobalKey(), title: '券面情報読み取り'),
        SelfCertPageName: (BuildContext context) => SelfCertPage(key: GlobalKey(), title: '自己証明書の読み取り'),
        CreateSignaturePageName: (BuildContext context) => CreateSignaturePage(key: GlobalKey()),
      },
    );
  }
}
