import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:nfc_poc/models/providers/NFCProvider.dart';
import 'package:nfc_poc/viewmodels/NFCNotifier.dart';
import 'package:nfc_poc/views/widgets/EasyTextField.dart';

/**
 * 券面情報を読み取るための画面
 * 4桁の暗証番号を使って、マイナンバー、名前、住所、生年月日、性別をマイナンバーカード から読み出す。
 */
class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(10);

  void increment() {
    print("increment counter");
    state = state + 1;
  }
}

final counterProvider = StateNotifierProvider((_) => CounterNotifier());
final nfcProvider = StateNotifierProvider<NFCNotifier, NFCState>((_) => NFCNotifier());

class PersonalInfoPage extends ConsumerWidget {
  PersonalInfoPage({required Key key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final textFieldKey = GlobalKey<EasyTextFieldState>();
    final NFCNotifier nfc = watch(nfcProvider.notifier);
    final NFCState state = watch(nfcProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              EasyTextField(
                key: textFieldKey,
                initialText: state.pinCode!,
              ),
              readNfcButton(state.isNFCSupported!, () {
                String inputedCode = (textFieldKey.currentState as EasyTextFieldState).controller!.text;
                nfc.setPinCode(inputedCode);
                print(inputedCode);
                nfc.connect(inputedCode);
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

RaisedButton readNfcButton(bool nfcAvailable, void Function()? func) {
  Color bcolor = nfcAvailable ? Colors.lightBlueAccent : Colors.black12;
  return RaisedButton(
    child: const Text(
      'マイナンバーカードの読み取り',
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
