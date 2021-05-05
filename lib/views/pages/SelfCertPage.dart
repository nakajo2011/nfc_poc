import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_poc/viewmodels/SelfCertPageViewModel.dart';

/**
 * 自己証明書を読み取るためのページ
 *
 */
class SelfCertPage extends ConsumerWidget {
  final certReader = StateNotifierProvider<SelfCertPageViewModel, SelfCertState>((_) => SelfCertPageViewModel());

  SelfCertPage({required Key key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    print("this=${this.hashCode}");
    final SelfCertPageViewModel reader = watch(certReader.notifier);
    final SelfCertState state = watch(certReader);

    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              readNfcButton(state.isNFCSupported!, () {
                reader.connect();
              }),
              Text(
                'NFCサポート: ${state.isNFCSupported! ? "OK" : "NFCがOFFになっています。"}',
              ),
              Expanded(
                child: Container(
                  constraints: BoxConstraints.expand(),
                  margin: EdgeInsets.all(16),
                  decoration: boxShadowDecoration(),
                  child: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text('${state.stateMessage}')),
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

ElevatedButton readNfcButton(bool nfcAvailable, void Function()? func) {
  Color bcolor = nfcAvailable ? Colors.lightBlueAccent : Colors.black12;
  return ElevatedButton(
    child: const Text(
      'マイナンバーカードの読み取り',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    style: ElevatedButton.styleFrom(
      primary: bcolor, //change background color of button
      onPrimary: Colors.white, //change text color of button
    ),
    onPressed: nfcAvailable ? func : null,
  );
}
