import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_poc/main.dart';

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(10);

  void increment() {
    print("increment counter");
    state = state + 1;
  }
}

class HomePage extends ConsumerWidget {
  HomePage({required Key key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              button(context, '券面情報読み取り', PersonalInfoPageName),
              button(context, '利用者証明書読み取り', SelfCertPageName),
            ],
          ),
        ),
      ),
    );
  }
}

ElevatedButton button(BuildContext context, final String title, final String nextPageName) {
  return ElevatedButton(
    child: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    style: ElevatedButton.styleFrom(
      primary: Colors.lightBlueAccent, //change background color of button
      onPrimary: Colors.white, //change text color of button
    ),
    onPressed: () => {Navigator.of(context).pushNamed(nextPageName)},
  );
}
