import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:nfc_poc/models/ByteConverter.dart';
import 'package:nfc_poc/models/apdu/APDUCommand.dart';
import 'package:nfc_poc/models/apdu/APDUErrors.dart';

/**
 * APDU通信を行うクラス
 * @see https://www.nmda.or.jp/nmda/ic-card/iso10536/sec4.html
 */
class APDUCommunicator {
  APDUCommunicator(this.isoDep);
  IsoDep? isoDep;

  /// 指定されたAPDU のコマンドを実行します。
  /// 実行結果を APDUResponseとして返します。
  /// 読み取り結果がエラーの場合はExceptionを発生させます。
  Future<APDUResponse> read(APDUCommand command) async {
    print("command=${command.dumpPayload}");

    Uint8List res = await isoDep!.transceive(data: command.payload);
    APDUResponse response =  APDUResponse(res);

    print(response);
    if(response.isError) response.throwException();
    return response;
  }

  Future<Uint8List> readBigBinary(int length) async {
    Uint8List buf = Uint8List(length);
    for (int i = 0; i < length; i += 256) {
      int perLength = length - i;
      if (perLength > 256) perLength = 256;

      APDUResponse res = await this.read(APDUCommands.readBinary(int16Bytes(i), perLength));
      print("perLength=${perLength}, readBytes=${res.bodyBytes!.length}");
      buf.setAll(i, res.bodyBytes!);
      print("buf.length=${buf.length}");
    }
    return buf;
  }

}

class APDUResponse {
  static const List<int> SUCCESS_CODE = [0x90, 0x00];
  APDUResponse(Uint8List nfcRes) {
    if(nfcRes == null || nfcRes.length < 2) {
      // responseが正しく受け取れてないので-1を入れておく（未定義エラー）
      this.responseCode = Uint8List.fromList([0xff, 0xff]);
    } else if(nfcRes.length == 2) {
      responseCode = nfcRes;
    } else {
      int length = nfcRes.length;
      bodyBytes = nfcRes.sublist(0, length-2);
      responseCode = nfcRes.sublist(length-2, length);
    }
  }

  bool get isSuccess {
    return ListEquality().equals(SUCCESS_CODE, this.responseCode);
  }
  bool get isError => !isSuccess;
  bool get hasBody => bodyBytes != null && bodyBytes!.length > 0;

  Uint8List? bodyBytes;
  Uint8List? responseCode;
  
  void throwException() {
    throw APDUException.fromAPDUResponse(this);
  }

  toHex(num) => num.toRadixString(16).padLeft(2, "0");
  @override
  String toString() {
    String code = responseCode!.map(toHex).join(":");
    String body = bodyBytes == null ? "null" : bodyBytes!.map((e) => toHex(e)).join(" ");
    return "APDUResponse: isSuccess=${isSuccess}, code=${code}, body=${body}";
  }
}

class APDUCommands {
  static final selectMF = selectEF([0x3f, 0x00]);
  static final selectDefaultAID = selectDF([0xE8, 0x28, 0xBD, 0x08, 0x0F]);

  static APDUCommand selectEF(List<int> efid) {
    return APDUCommand3(0x00, 0xa4, 0x02, 0x0c, Uint8List.fromList(efid));
  }
  /// ファイル制御情報（file control information）を要求してEFを選択します。
  static APDUCommand selectEFWithFCI(List<int> efid) {
    return APDUCommand3(0x00, 0xa4, 0x02, 0x00, Uint8List.fromList(efid));
  }
  static APDUCommand selectDF(List<int> dfName) {
    return APDUCommand3(0x00, 0xa4, 0x04, 0x0c, Uint8List.fromList(dfName));
  }

  static APDUCommand readBinary(Uint8List start, int length) {
    return APDUCommand2(0x00, 0xB0, start[0], start[1], length);
  }

  static APDUCommand lookup() {
    return APDUCommand1(0x00, 0x20, 0x00, 0x80);
  }

  static APDUCommand verify(List<int> pin) {
    return APDUCommand3(0x00, 0x20, 0x00, 0x80, Uint8List.fromList(pin));
  }
}