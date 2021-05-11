import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:nfc_poc/models/MyNumberCard.dart';
import 'package:nfc_poc/models/apdu/APDUCommunicator.dart';
import 'package:nfc_poc/models/mynumber/Communicator.dart';
import 'package:x509/x509.dart';

// 利用者用証明書を読み取るためのreaderクラス
class SelfCertificateReader extends Communicator {
  SelfCertificateReader()
      : super();

  // 自己証明書を読み取るためにマイナンバーカード とやり取りする処理。
  Future<void> process(IsoDep isoDep) async {
    print("readCertCallBack started");
    try {
      APDUCommunicator communicator = APDUCommunicator(isoDep);
      String certificatePEM =
          await CertificateAP(communicator).selectUserCertificate();
      completer.complete("NFCの読み取り終了: ${parsePem(certificatePEM).first}");
      for (int i = 0; i < certificatePEM.length; i += 256) {
        int endIndex =
            i + 256 > certificatePEM.length ? certificatePEM.length : i + 256;
        print(certificatePEM.substring(i, endIndex));
      }
    } catch (e, stackTrace) {
      completer.completeError("NFCの読み取りでエラーが発生しました。 ${e.toString()}", stackTrace);
      print(stackTrace.toString());
    }
  }
}
