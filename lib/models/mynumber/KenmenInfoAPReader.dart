
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:nfc_poc/models/MyNumberCard.dart';
import 'package:nfc_poc/models/apdu/APDUCommunicator.dart';
import 'package:nfc_poc/models/apdu/APDUErrors.dart';
import 'package:nfc_poc/models/mynumber/Communicator.dart';

class PinCodeException implements Exception {
  String message;

  PinCodeException(this.message);
}

// 券面情報APから券面情報を取得するためのReaderクラス
class KenmenInfoAPReader extends Communicator {
  String pinCode;

  KenmenInfoAPReader(this.pinCode, StateHandlerCB? handler)
      : super(stateHandler: handler);

  // pinCodeが数字４桁で渡されているかチェックする。
  void verifyPinCode() {
    if (this.pinCode.length != 4) {
      throw PinCodeException("エラー:暗証番号の桁数が４桁ではありません。");
    }
    try {
      int.parse(this.pinCode);
    } catch (e) {
      throw PinCodeException("エラー:暗証番号は数字４桁を入力してください。: $e");
    }
  }

  // 券面情報を読み取る処理
  @override
  Future<void> process(NfcTag tag) async {
    try {
      notify("NFCの読み取り中....");

      Ndef? ndef = Ndef.from(tag);
      IsoDep? isodep = IsoDep.from(tag);
      if (isodep == null) {
        notify("不明なNFCです。 ndef=${ndef}");
      } else {
        APDUCommunicator communicator = APDUCommunicator(isodep);
        TextConfirmAP textAP = TextConfirmAP(communicator);
        String result = await textAP.readMyNumber(this.pinCode);
        result += await textAP.readAttributes(this.pinCode);
        int remainingCount = await textAP.lookupPIN();
        result += "券面入力補助PIN 残り試行回数：${remainingCount}回";
        notify("NFCの読み取り終了：${result}");
      }
    } catch (e, stackTrace) {
      if (e is InvalidPINException) {
        notify("４桁の暗証番号が違います。残り試行回数：${(e as InvalidPINException).retry}回");
      } else {
        notify("NFCの読み取りでエラーが発生しました。 ${e.toString()}");
        print(stackTrace.toString());
      }
    }
  }
}
