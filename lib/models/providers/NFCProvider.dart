
import 'dart:async';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_poc/models/mynumber/Communicator.dart';

/**
 * デバイスのNFC機器とやりとりするクラス。
 */
typedef StateHandlerCB = void Function(String stateMessage);

class NFCProvider {
  StateHandlerCB? stateHandler;
  String? pinCode;

  void setHandler(StateHandlerCB handler) {
    this.stateHandler = handler;
  }

  void notify(String message) {
    if (this.stateHandler != null) this.stateHandler!(message);
  }

  Future<bool> checkNFCAvailable() async {
    bool res = false;
    // 端末がNFCに対応しているかbool型で返ってくる（true:対応 false:非対応）
    NfcManager _manager = NfcManager.instance;
    bool isAvailable = await _manager.isAvailable();
    print("NFC available is: ${isAvailable}");
    return isAvailable;
  }

  // マイナンバーカード にアクセスして情報を読み取る
  Future<String> connect(Communicator reader) async {
    if (await checkNFCAvailable()) {
      NfcManager _manager = NfcManager.instance;
      _manager.startSession(
          onDiscovered: reader.nfcTagCallback,
          alertMessage: "NFC Read Error!!!!",
          onError: (NfcError error) async {
            reader.onError(
                "読み取り中にエラーが発生しました。info: ${error.message}, type: ${error.type}, details: ${error.details}");
          });
      return reader.future;
    } else {
      throw new Exception("NFCがOFFになっているか、未対応の端末です。");
    }
  }
}
