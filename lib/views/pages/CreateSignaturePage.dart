import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_poc/viewmodels/CreateSignaturePageViewModel.dart';
import 'package:nfc_poc/viewmodels/PersonalInfoPageViewModel.dart';
import 'package:nfc_poc/views/widgets/EasyTextField.dart';

/**
 * マイナンバーカードの利用者証明書に登録されている鍵を使って署名を生成する画面
 */
class CreateSignaturePage extends ConsumerWidget {
  final nfcProvider = StateNotifierProvider<CreateSignaturePageViewModel, SigState>((_) => CreateSignaturePageViewModel());

  CreateSignaturePage({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final pinCodeInputKey = GlobalKey<EasyTextFieldState>();
    final messageInputKey = GlobalKey<EasyTextFieldState>();
    final CreateSignaturePageViewModel nfc = watch(nfcProvider.notifier);
    final SigState state = watch(nfcProvider);
    final pinCode = state.pinCode == null ? "" : state.pinCode!;
    final message = state.message == null ? "" : state.message!;

    return Scaffold(
      appBar: AppBar(
        title: Text("署名作成"),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              EasyTextField(
                key: pinCodeInputKey,
                initialText: pinCode,
                hintText: "暗証番号4桁",
              ),
              EasyTextField(
                key: messageInputKey,
                initialText: message,
                hintText: "署名対象のメッセージ",
              ),
              readNfcButton(state.isNFCSupported!, () {
                String inputedCode = (pinCodeInputKey.currentState as EasyTextFieldState).controller!.text;
                String msg = (messageInputKey.currentState as EasyTextFieldState).controller!.text;
                print("$inputedCode, $msg");
                nfc.connect(inputedCode, msg);
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
