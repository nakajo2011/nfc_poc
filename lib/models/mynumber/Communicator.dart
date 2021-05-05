
import 'dart:typed_data';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

typedef StateHandlerCB = void Function(String stateMessage);

abstract class Communicator {
  // マイナンバーとの読み取り状況を伝えるためのHandler
  StateHandlerCB? stateHandler;

  Communicator({this.stateHandler});

  // マイナンバーの読み取り状況を通知する
  void notify(String message) {
    if (this.stateHandler != null) this.stateHandler!(message);
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
        notify("不明なNFCです。 ndef=${isodep}");
      } else {
        await process(isodep);
      }
    } finally {
      NfcManager.instance.stopSession(); // 読み込み終了
      print("stop nfc scan.");
    }
  }

  // サブクラスが実装すべきマイナンバーカードとの固有の通信処理
  Future<void> process(IsoDep isoDep);
}