import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:nfc_poc/models/MyNumberCard.dart';
import 'package:nfc_poc/models/apdu/APDUCommunicator.dart';
import 'package:nfc_poc/models/apdu/APDUErrors.dart';
import 'package:nfc_poc/models/mynumber/Communicator.dart';
import 'package:nfc_poc/models/mynumber/KenmenInfoAPReader.dart';

class PinCodeAndMsgException implements Exception {
  String message;

  PinCodeAndMsgException(this.message);
}

// 券面情報APから券面情報を取得するためのReaderクラス
class SignatureCreator extends Communicator {
  String pinCode;
  String? msg;

  SignatureCreator(this.pinCode, this.msg, StateHandlerCB? handler)
      : super(stateHandler: handler);

  // pinCodeとmsgが入力されているかチェック
  void verify() {
    if (this.pinCode.length != 4) {
      throw PinCodeAndMsgException("エラー:暗証番号の桁数が４桁ではありません。");
    }
    try {
      int.parse(this.pinCode);
    } catch (e) {
      throw PinCodeAndMsgException("エラー:暗証番号は数字４桁を入力してください。: $e");
    }
    if (this.msg == null) {
      throw PinCodeAndMsgException("エラー:署名対象のメッセージを入力してください。");
    }
  }

  // 券面情報を読み取る処理
  @override
  Future<void> process(IsoDep isoDep) async {
    try {
      notify("NFCの読み取り中....");
      notify("実装中。。。。");
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
