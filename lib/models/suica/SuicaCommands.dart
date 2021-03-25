import 'dart:typed_data';

import 'package:nfc_manager/platform_tags.dart';
import 'package:nfc_poc/models/suica/SuicaResponse.dart';

final int POLLING_COMMAND_BYTE = 0x00;
final Uint8List SYSTEM_CODE = Uint8List.fromList([0xFE, 0x00]);

Uint8List _pollingCommand() {
  List<int> buf = [];
  buf.add(6);
  buf.add(POLLING_COMMAND_BYTE);
  buf.add(SYSTEM_CODE[0]);
  buf.add(SYSTEM_CODE[1]);
  buf.add(0x01); // システムコードを要求
  buf.add(0xFF); // 応答可能な最大スロット数

  return Uint8List.fromList(buf);
}

Future<PollingResponse> polling(NfcF nfcF) async {
  Uint8List res = await nfcF.transceive(data: _pollingCommand());
  return PollingResponse(response: res);
}

final int REQUEST_SERVICE_COMMAND_BYTE = 0x02;

Uint8List requestServiceCommand(Uint8List idm, List<int> serviceCode) {
  List<int> buf = [];
  buf.add(0); // 仮の値。最後に置き直す。このコマンド全体のバイト数
  buf.add(REQUEST_SERVICE_COMMAND_BYTE); // コマンドバイト
  buf.addAll(idm); // idm (8byte)
  buf.add(0x01); // ノード数
  buf.addAll(serviceCode); // ノードコードリスト

  buf[0] = buf.length;
  return Uint8List.fromList(buf);
}

final int REQUEST_RESPONSE_COMMAND_BYTE = 0x04;

Uint8List requestResponseCommand(Uint8List idm) {
  List<int> buf = [];
  buf.add(0); // 仮の値。最後に置き直す。このコマンド全体のバイト数
  buf.add(REQUEST_RESPONSE_COMMAND_BYTE); // コマンドバイト
  buf.addAll(idm); // idm (8byte)

  buf[0] = buf.length;
  return Uint8List.fromList(buf);
}

final int READ_WITHOUT_ENCRYPTION_COMMAND_BYTE = 0x06;
final Uint8List SERVICE_CODE = Uint8List.fromList([0x09, 0x0F]);
final List<int> BLOCK_LIST = [0x80, 0x00];

Uint8List readWithoutEncCommand(Uint8List idm) {
  List<int> buf = [];
  buf.add(0); // 仮の値。最後に置き直す。このコマンド全体のバイト数
  buf.add(READ_WITHOUT_ENCRYPTION_COMMAND_BYTE); // コマンドバイト
  buf.addAll(idm); // idm (8byte)
  buf.add(0x01); // サービス数
  buf.add(SERVICE_CODE[1]); // サービスコードリスト (2m byte.　今回は１個しか指定しないから2byte)
  buf.add(SERVICE_CODE[0]); // サービスコードリスト (2m byte.　今回は１個しか指定しないから2byte)
  buf.add(0x01); // ブロック数
  buf.addAll(BLOCK_LIST); // ブロックリスト

  buf[0] = buf.length;
  return Uint8List.fromList(buf);
}

Future<HistoryListResponse> readWithoutEncryption(NfcF nfcF) async {
  Uint8List command = readWithoutEncCommand(nfcF.identifier);
  Uint8List response = Uint8List.fromList([0]);
  HistoryListResponse result = HistoryListResponse();
  int commandOffsetIndex = command.length - 1;
  int blockOffset = command[commandOffsetIndex];
  while (response != null) {
    try {
      response = await nfcF.transceive(data: command);
      print("response data=${response}");
      result.add(HistoryResponse(response: response));
      blockOffset++;
      command[commandOffsetIndex] = blockOffset;
    } on ArgumentError catch (e) {
      print("error: ${e.message}");
      break;
    }
  }

  print("result=${result}");
  return result;
}