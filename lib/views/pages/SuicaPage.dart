import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:nfc_poc/viewmodels/NFCNotifier.dart';
import 'package:nfc_poc/viewmodels/SuicaNotifier.dart';
import 'package:nfc_poc/views/widgets/EasyTextField.dart';

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(10);

  void increment() {
    print("increment counter");
    state = state + 1;
  }
}

final counterProvider = StateNotifierProvider((_) => CounterNotifier());
final suicaProvider = StateNotifierProvider((_) => SuicaNotifier());

class SuicaPage extends ConsumerWidget {
  SuicaPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final textFieldKey = GlobalKey<EasyTextFieldState>();
    final SuicaNotifier nfc = watch(suicaProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              readNfcButton(watch(suicaProvider.state).isNFCSupported, () {
                nfc.connect();
              }),
              Text(
                'NFCサポート: ${watch(suicaProvider.state).isNFCSupported ? "OK" : "NFCがOFFになっています。"}',
              ),
              Expanded(
                child: Container(
                  constraints: BoxConstraints.expand(),
                  margin: EdgeInsets.all(16),
                  decoration: boxShadowDecoration(),
                  child: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text('${watch(suicaProvider.state).stateMessage}')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration boxShadowDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(10)),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 5,
        blurRadius: 7,
        offset: Offset(0, 3), // changes position of shadow
      ),
    ],
  );
}

Container boxShadow(Widget child) {
  return Container(
    child: child,
    margin: EdgeInsets.only(left: 30, top: 100, right: 30, bottom: 50),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 7,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
    ),
  );
}

RaisedButton readNfcButton(bool nfcAvailable, Function func) {
  Color bcolor = nfcAvailable ? Colors.lightBlueAccent : Colors.black12;
  return RaisedButton(
    child: const Text(
      'Suicaの読み取り',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    color: bcolor,
    textColor: Colors.white,
    onPressed: nfcAvailable ? func : null,
  );
}
