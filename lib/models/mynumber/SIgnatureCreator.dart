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

  SignatureCreator(this.pinCode, this.msg)
      : super();

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

  toHex(num) => num.toRadixString(16).padLeft(2, "0");

  // 券面情報を読み取る処理
  @override
  Future<void> process(IsoDep isoDep) async {
    try {
      // notify("NFCの読み取り中....");
      // notify("実装中。。。。");
      APDUCommunicator communicator = APDUCommunicator(isoDep);
      List<int> sign =
      await CertificateAP(communicator).createSignature(pinCode, msg!);
      completer.complete("署名： size=${sign.length} \nbody: ${sign.map((e) => toHex(e)).join(":")}");
    } catch (e, stackTrace) {
      if (e is InvalidPINException) {
        completer.completeError("４桁の暗証番号が違います。残り試行回数：${(e as InvalidPINException).retry}回");
      } else {
        completer.completeError("NFCの読み取りでエラーが発生しました。ボタンを押してやり直してください。 ${e.toString()}", stackTrace);
        print(stackTrace.toString());
      }
    }
  }
}
