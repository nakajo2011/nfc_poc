import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:nfc_poc/models/suica/SuicaCommands.dart';
import 'package:nfc_poc/models/suica/SuicaResponse.dart';

/**
 * SuicaとデバイスのNFCリーダーとやりとりするクラス。
 */
typedef StateHandlerCB = void Function(String stateMessage);

class SuicaProvider {
  StateHandlerCB stateHandler;
  String pinCode;

  void setHandler(StateHandlerCB handler) {
    this.stateHandler = handler;
  }

  void notify(String message) {
    if (this.stateHandler != null) this.stateHandler(message);
  }

  Future<bool> checkNFCAvailable() async {
    bool res = false;
    // 端末がNFCに対応しているかbool型で返ってくる（true:対応 false:非対応）
    NfcManager _manager = NfcManager.instance;
    bool isAvailable = await _manager.isAvailable();
    print("NFC available is: ${isAvailable}");
    return isAvailable;
  }

  Future<void> connect() async {
    if (await checkNFCAvailable()) {
      NfcManager _manager = NfcManager.instance;
      _manager.startSession(
          onDiscovered: nfcTagCallback,
          pollingOptions: Set.from([NfcPollingOption.iso18092]),
          alertMessage: "NFC Read Error!!!!",
          onError: (NfcError error) async {
            notify(
                "読み取り中にエラーが発生しました。info: ${error.message}, type: ${error.type}, details: ${error.details}");
          });
    } else {
      throw new Exception("NFCがOFFになっているか、未対応の端末です。");
    }
  }

  Future<void> nfcTagCallback(NfcTag tag) async {
    print("nfcTagCallback started");
    try {
      tag.data.entries.forEach((element) {
        print("Tag.entries: ${element.key}: ${element.value.toString()}");
      });
      notify("Suicaの読み取り中....");
      NfcF nfcF = NfcF.from(tag);

      // PollingResponse pollingRes = await polling(nfcF);
      // print(pollingRes);
      // print(pollingRes.toReadableResult());
      // String result = pollingRes.toReadableResult();

      String result = "";
      HistoryListResponse rweRes = await readWithoutEncryption(nfcF);
      print("rweRes=${rweRes}");
      result += "Read: ${rweRes}";
      notify(result);
    } catch (e, stackTrace) {
      notify("SuicaCの読み取りでエラーが発生しました。 ${e.toString()}");
      print(stackTrace.toString());
    } finally {
      NfcManager.instance.stopSession(); // 読み込み終了
      print("stop nfc scan.");
    }
  }
}
