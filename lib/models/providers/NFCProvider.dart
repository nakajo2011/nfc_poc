import 'dart:typed_data';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:nfc_poc/models/MyNumberCard.dart';
import 'package:nfc_poc/models/apdu/APDUCommunicator.dart';
import 'package:nfc_poc/models/apdu/APDUErrors.dart';
import 'package:x509/x509.dart';

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

  // マイナンバーカード にアクセスして自己証明書を読み取る
  Future<void> readSelfCert() async {
    if (await checkNFCAvailable()) {
      NfcManager _manager = NfcManager.instance;
      _manager.startSession(
          onDiscovered: readCertCallBack,
          alertMessage: "NFC Read Error!!!!",
          onError: (NfcError error) async {
            notify(
                "読み取り中にエラーが発生しました。info: ${error.message}, type: ${error.type}, details: ${error.details}");
          });
    } else {
      throw new Exception("NFCがOFFになっているか、未対応の端末です。");
    }
  }

  // マイナンバーカード にアクセスして券面情報を読み取る。
  Future<void> connect(String pinCode) async {
    this.pinCode = pinCode;
    if (this.pinCode!.length != 4) {
      notify("エラー:暗証番号の桁数が４桁ではありません。");
      return;
    }
    try {
      int.parse(this.pinCode!);
    } catch (e) {
      notify("エラー:暗証番号は数字４桁を入力してください。: $e");
    }

    if (await checkNFCAvailable()) {
      NfcManager _manager = NfcManager.instance;
      _manager.startSession(
          onDiscovered: nfcTagCallback,
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
      notify("NFCの読み取り中....");

      Ndef? ndef = Ndef.from(tag);
      IsoDep? isodep = IsoDep.from(tag);
      if(isodep == null) {
        notify("不明なNFCです。 ndef=${ndef}");
      } else {
        APDUCommunicator communicator = APDUCommunicator(isodep);
        // String certificatePEM =
        //     await CertificateAP(communicator).selectUserCertificate();
        // notify("NFCの読み取り終了: ${certificatePEM}");
        // for(int i=0; i<certificatePEM.length; i+=256) {
        //   int endIndex = i + 256 > certificatePEM.length ? certificatePEM.length : i + 256;
        //   print(certificatePEM.substring(i, endIndex));
        // }

        TextConfirmAP textAP = TextConfirmAP(communicator);
        String result = await textAP.readMyNumber(this.pinCode!);
        result += await textAP.readAttributes(this.pinCode!);
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
    } finally {
      NfcManager.instance.stopSession(); // 読み込み終了
      print("stop nfc scan.");
    }
  }

  // 自己証明書を読み取るためにマイナンバーカード とやり取りする処理。
  Future<void> readCertCallBack(NfcTag tag) async {
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
