import 'dart:io';
import 'dart:typed_data';

import 'package:nfc_poc/models/apdu/APDUCommunicator.dart';

/// APDU通信で発生した例外
///
/// @see https://www.nmda.or.jp/nmda/ic-card/iso10536/sec4.html
class APDUException extends IOException {
  APDUException(this.sw1, this.sw2) {
    this.message = _message();
  }

  int sw1;
  int sw2;
  String? message;

  static APDUException fromAPDUResponse(APDUResponse response) {
    Uint8List code = response.responseCode!;
    if(code[0] == 0x63) {
      return new InvalidPINException(code[0], code[1]);
    }
    return APDUException(code[0], code[1]);
  }

  String toString() {
    String code = [sw1, sw2].map((sw) => sw.toRadixString(16)).join(":");
    return "エラーコード=${code} ${this.message}";
  }

  /// https://www.nmda.or.jp/nmda/ic-card/iso10536/sec4.html「表4.17 ステータスコードとその意味」　より
  String? _message() {
    switch (sw1) {
      case 0x62:
        switch (sw2) {
          case 0x81:
            return "出力データに異常がある。";
          case 0x83:
            return "DFが閉塞している。";
        }
        return "警告処理。不揮発性メモリの状態が変化していない。";
      case 0x64:
        switch (sw2) {
          case 0x00:
            return "ファイル制御情報に誤りがある。";
        }
        return "警告処理。不揮発性メモリの状態が変化していない。";
      case 0x65:
        switch (sw2) {
          case 0x81:
            return "メモリへの書き込みが失敗した。";
        }
        return "警告処理。不揮発性メモリの状態が変化している。";
      case 0x67:
        switch (sw2) {
          case 0x00:
            return "検査誤り。Lcフィールド及び／又はLeフィールドが間違っている。";
        }
        return "警告処理。未定義のレスポンスコード。";
      case 0x68:
        switch (sw2) {
          case 0x81:
            return "指定された論理チャンネル番号によるアクセス機能を提供しない。";
          case 0x82:
            return "メッセージ安全保護機能を提供しない。";
        }
        return "検査誤り。CLAの機能が提供されない。";
      case 0x69:
        switch (sw2) {
          case 0x81:
            return "ファイル構造と矛盾したコマンドである。";
          case 0x82:
            return "セキュリティステータスが満足されない。";
          case 0x84:
            return "参照されたIEFが閉塞している。";
          case 0x85:
            return "コマンドの使用条件が満足されない。";
          case 0x86:
            return "カレントEFがない。";
        }
        return "検査誤り。コマンドは許されない。";
      case 0x6A:
        switch (sw2) {
          case 0x80:
            return "データフィールドのタグが正しくない。";
          case 0x81:
            return "機能を提供しない。";
          case 0x82:
            return "アクセス対象のファイルがない。";
          case 0x83:
            return "アクセス対象のレコードがない。";
          case 0x84:
            return "ファイル内に十分なメモリ容量がない。";
          case 0x85:
            return "Lcの値がTLV構造に矛盾している。";
          case 0x86:
            return "P1-P2の値が正しくない。";
          case 0x87:
            return "Lcの値がP1-P2に矛盾している。";
          case 0x88:
            return "参照されたキーが正しく設定されていない。";
        }
        return "検査誤り。間違ったパラメータP1,P2。";
      case 0x6B:
        if(sw2 == 0x00) {
          return "検査誤り。EF範囲外にオフセット指定した。";
        }
        return "警告処理。未定義のレスポンスコード。";
      case 0x6D:
        if(sw2 == 0x00) {
          return "検査誤り。INSが提供されていない。";
        }
        return "警告処理。未定義のレスポンスコード。";
      case 0x6E:
        if(sw2 == 0x00) {
          return "検査誤り。CLAが提供されていない。";
        }
        return "警告処理。未定義のレスポンスコード。";
      case 0x6F:
        if(sw2 == 0x00) {
          return "検査誤り。自己診断異常。";
        }
        return "警告処理。未定義のレスポンスコード。";
    }
  }
}

/// PINコードの検証に失敗した時にスローされる例外
class InvalidPINException extends APDUException {
  InvalidPINException(int sw1, int sw2) : super(sw1, sw2) {
    if (sw2 == 0x00) {
      this.retry = -1;
      this.message = "照合不一致。";
    } else if(sw2 == 0x81) {
      this.message = "ファイルが今回の書き込みによって一杯になった。";
    } else if(sw2 >= 0xC0 && sw2 < 0xD0){
      this.retry = sw2 - 0xc0;
      this.message = "照合不一致。残り再試行回数 ${retry}回";
    } else {
      this.message = "警告処理。不揮発性メモリの状態が変化している。";
    }
  }

  int retry = -1;
}
