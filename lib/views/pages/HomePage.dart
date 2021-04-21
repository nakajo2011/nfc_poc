import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:nfc_poc/main.dart';
import 'package:nfc_poc/models/providers/NFCProvider.dart';
import 'package:nfc_poc/viewmodels/NFCNotifier.dart';
import 'package:nfc_poc/views/widgets/EasyTextField.dart';

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(10);

  void increment() {
    print("increment counter");
    state = state + 1;
  }
}

final counterProvider = StateNotifierProvider((_) => CounterNotifier());
final nfcProvider = StateNotifierProvider((_) => NFCNotifier());

class HomePage extends ConsumerWidget {
  HomePage({required Key key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final textFieldKey = GlobalKey<EasyTextFieldState>();
    final NFCNotifier nfc = watch(nfcProvider.notifier);

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

RaisedButton button(BuildContext context, final String title, final String nextPageName) {
  return RaisedButton(
    child: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    color: Colors.lightBlueAccent,
    textColor: Colors.white,
    onPressed: () => {Navigator.of(context).pushNamed(nextPageName)},
  );
}
