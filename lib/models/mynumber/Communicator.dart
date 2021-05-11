
import 'dart:async';
import 'dart:typed_data';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

typedef StateHandlerCB = void Function(String stateMessage);

abstract class Communicator {
  // マイナンバーとの読み取り状況を伝えるためのHandler
  Completer<String> completer = Completer<String>();

  Communicator();

  Future<String> get future => completer.future;

  // マイナンバーの読み取り状況を通知する
  void notify(String message) {
  }

  // NFCとのやりとり時に呼ばれるコールバック関数
  Future<void> nfcTagCallback(NfcTag tag) async {
    try {
      // TODO: NFCManagerが、null-safety対応のために、各フィールドを全て必須としているため、nullフィールドがあれば0の値を入れるための処理。
      if (tag.data['isodep']['historicalBytes'] == null) {
        tag.data['isodep']['historicalBytes'] = Uint8List.fromList([0x00]);
      }
      tag.data.entries.forEach((element) {
        print("Tag.entries: ${element.key}: ${element.value.toString()}");
      });
      tag.data.entries.forEach((element) {
        print("Tag.entries: ${element.key}: ${element.value.toString()}");
      });
      IsoDep? isodep = IsoDep.from(tag);
      if (isodep == null) {
        completer.complete("不明なNFCです。 ndef=${isodep}");
      } else {
        await process(isodep);
      }
    } finally {
      await NfcManager.instance.stopSession(alertMessage: "alert", errorMessage: "error"); // 読み込み終了
      print("stop nfc scan.");
    }
  }

  /// NFCとの通信中に発生したエラーを通知する
  void onError(Object _error, [StackTrace? stackTrace]) {
    completer.completeError(_error, stackTrace);
  }

  // サブクラスが実装すべきマイナンバーカードとの固有の通信処理
  Future<void> process(IsoDep isoDep);
}