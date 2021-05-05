import 'dart:typed_data';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:nfc_poc/models/MyNumberCard.dart';
import 'package:nfc_poc/models/apdu/APDUCommunicator.dart';
import 'package:x509/x509.dart';

typedef StateHandlerCB = void Function(String stateMessage);

// 利用者用証明書を読み取るためのreaderクラス
class SelfCertificateReader {
  StateHandlerCB? stateHandler;

  SelfCertificateReader({this.stateHandler});

  void notify(String message) {
    if (this.stateHandler != null) this.stateHandler!(message);
  }

  // 自己証明書を読み取るためにマイナンバーカード とやり取りする処理。
  Future<void> nfcTagCallback(NfcTag tag) async {
    print("readCertCallBack started");
    try {
      if(tag.data['isodep']['historicalBytes'] == null) {
        tag.data['isodep']['historicalBytes'] = Uint8List.fromList([0x00]);
      }
      tag.data.entries.forEach((element) {
        print("Tag.entries: ${element.key}: ${element.value.toString()}");
      });
      notify("NFCの読み取り中....");

      IsoDep? isodep = IsoDep.from(tag);
      if(isodep == null) {
        notify("不明なNFCです。 nfcTag=${tag}");
      } else {
        APDUCommunicator communicator = APDUCommunicator(isodep);
        String certificatePEM =
        await CertificateAP(communicator).selectUserCertificate();
        notify("NFCの読み取り終了: ${parsePem(certificatePEM).first}");
        for (int i = 0; i < certificatePEM.length; i += 256) {
          int endIndex = i + 256 > certificatePEM.length
              ? certificatePEM.length
              : i + 256;
          print(certificatePEM.substring(i, endIndex));
        }
      }
    } catch (e, stackTrace) {
      notify("NFCの読み取りでエラーが発生しました。 ${e.toString()}");
      print(stackTrace.toString());
    } finally {
      NfcManager.instance.stopSession(); // 読み込み終了
      print("stop nfc scan.");
    }
  }
}