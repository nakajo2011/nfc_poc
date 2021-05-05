import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:nfc_poc/models/ByteConverter.dart';
import 'package:nfc_poc/models/apdu/APDUCommand.dart';
import 'package:nfc_poc/models/apdu/APDUCommunicator.dart';
import 'package:nfc_poc/models/apdu/APDUErrors.dart';

/// マイナンバーカード
class MyNumberCard {
  static const List<int> APPLICATION_DATA = [0, 0, 65, 224];
  static const List<int> PROTOCOL_INFO = [179, 129, 161];

  MyNumberCard(this.nfcB, this.isoDep);

  NfcB nfcB;
  IsoDep isoDep;

  /// マイナンバーカード のNFC tag稼働かをチェックします。
  /// マイナンバーカード のICチップ(=tag)の規格はNFC-Type4Bなので、タッチしたカードがType4Bであることをチェックする。
  static bool isMyNumberCard(NfcTag tag) {
    NfcB? nfcB = NfcB.from(tag);
    IsoDep? isoDep = IsoDep.from(tag);
    if (nfcB == null || isoDep == null) {
      // NFC-Type4B => NFC Type-B + ISO-DEP(=Tag Type-4)なので両方満たしてない場合はマイナンバーカード ではない。
      return false;
    }
    return isMyNumberApplicationData(nfcB) && isMyNumberProtocolInfo(nfcB);
  }

  static MyNumberCard? from(NfcTag tag) {
    if (!isMyNumberCard(tag)) return null;
    return MyNumberCard(NfcB.from(tag)!, IsoDep.from(tag)!);
  }

  static isMyNumberApplicationData(NfcB nfcB) =>
      nfcB.applicationData == Uint8List.fromList(MyNumberCard.APPLICATION_DATA);

  static isMyNumberProtocolInfo(NfcB nfcB) =>
      nfcB.protocolInfo == Uint8List.fromList(MyNumberCard.PROTOCOL_INFO);
}

class MyNumberCardExtendedAPDUCommand {
  // マイナンバーカードでの署名生成命令
  static APDUCommand computeDigitalSignature(List<int> msgData) {
    return APDUCommand4(0x80, 0x2a, 0x00, 0x80, Uint8List.fromList(msgData), 0);
  }
}

/// 券面入力補助AP
/// マイナンバーなどを入力した時に、入力した値が間違っていないかをチェックするためのAPとのこと。
/// 入力させるより素直にマイナンバーかざして読み取った方が早いんだけど。。。
class TextConfirmAP {
  TextConfirmAP(this.communicator);

  APDUCommunicator communicator;

  /// 券面入力補助AP D3:93:F0:00:26:01:00:00:00:01
  final List<int> DFID = [
    0xD3,
    0x92,
    0x10,
    0x00,
    0x31,
    0x00,
    0x01,
    0x01,
    0x04,
    0x08
  ];

  /// 券面事項入力補助用PIN [0x00, 0x11]
  final List<int> textPinEF = [0x00, 0x11];

  /// 券面事項入力補助用PIN(A) [0x00, 0x14]
  final List<int> pinAEF = [0x00, 0x14];

  /// 券面事項入力補助用PIN(B) [0x00, 0x15]
  final List<int> pinBEF = [0x00, 0x15];

  /// マイナンバー [0x00, 0x01]
  final List<int> myNumberEF = [0x00, 0x01];

  /// 基本４情報 [0x00, 0x02]
  final List<int> attributesEF = [0x00, 0x02];

  /// 署名 [0x00, 0x03]
  final List<int> signEF = [0x00, 0x03];

  /// 証明書 [0x00, 0x04]
  final List<int> certificateEF = [0x00, 0x04];

  /// 基本情報 [0x00 0x05] - APの情報とかなのかな？
  final List<int> basicInfoEF = [0x00, 0x05];

  /// 券面入力補助PINの残り試行回数をチェック
  Future<int> lookupPIN() async {
    await communicator.read(APDUCommands.selectDF(DFID));
    await communicator.read(APDUCommands.selectEF(textPinEF));
    try {
      APDUResponse res = await communicator.read(APDUCommands.lookup());
      print("res=${res.toString()}");
      return 0;
    } catch (e) {
      print(e.toString());
      InvalidPINException pinEx = e as InvalidPINException;
      return pinEx.retry;
    }
  }

  /// 券面入力補助PINを解除
  Future<String> _verifyPIN(String pinCode) async {
    await communicator.read(APDUCommands.selectDF(DFID));
    await communicator.read(APDUCommands.selectEF(textPinEF));
    APDUResponse res =
        await communicator.read(APDUCommands.verify(pinCode.codeUnits));
    print("res=${res.toString()}");
    return "PINの解除に成功しました。";
  }

  /// PINを解除してマイナンバーを取得します。
  Future<String> readMyNumber(String pinCode) async {
    await this._verifyPIN(pinCode);
    await communicator.read(APDUCommands.selectEF(myNumberEF));
    APDUResponse res = await communicator
        .read(APDUCommands.readBinary(Uint8List.fromList([0x00, 0x00]), 17));
    print(res.toString());
    return "\n\tマイナンバー：${String.fromCharCodes(res.bodyBytes!.sublist(3, 15))}";
  }

  /// PINを解除して基本４情報を取得します。
  Future<String> readAttributes(String pinCode) async {
    print("readAtributes start");

    await this._verifyPIN(pinCode);
    await communicator.read(APDUCommands.selectEF(attributesEF));
    APDUResponse res = await communicator
        .read(APDUCommands.readBinary(Uint8List.fromList([0x00, 0x00]), 7));
    print("res=${res.toString()}");
    ASN1Length asn1Length = ASN1Length.decodeLength(
        res.bodyBytes!.sublist(1)); // libasn1 がtag.id=31に対応してないので、1byteずらしてあげる。
    print("data.length=${asn1Length.length}");
    Uint8List infoBytes = await communicator
        .readBigBinary(asn1Length.length + asn1Length.valueStartPosition);

    return "\n\t基本情報：${parseAttributes(infoBytes.sublist(asn1Length.valueStartPosition + 1))}";
  }

  Attributes parseAttributes(Uint8List buf) {
    int position = 0;
    List<Uint8List> attrBufs = [];
    while (position < buf.length) {
      int tag = buf[position];
      int tagId = tag & 0x1F;
      if (tagId == 0x1F) {
        // tag is 31 then next byte is the tag kind.
        position++; //slide to next byte because libasn1 is not support tag id 31.
        tagId = buf[position];
      }
      print("tagId=$tagId");
      Uint8List target = buf.sublist(position);
      if (tagId == 37) {
        // tag.id=37はsexで1byteデータなのでASN.1に変換せずそのまま取り出す。
        attrBufs.add(buf.sublist(position+1));
        position += 2;
      } else {
        ASN1Length asn1length = ASN1Length.decodeLength(target);
        Uint8List data =
            target.sublist(asn1length.valueStartPosition, asn1length.valueStartPosition + asn1length.length);
        position += asn1length.valueStartPosition + asn1length.length;
        attrBufs.add(data);
      }
    }
    return Attributes(
        attrBufs[0], attrBufs[1], attrBufs[2], attrBufs[3], attrBufs[4]);
  }
}

class Attributes {
  Attributes(this.header, Uint8List nameBytes, Uint8List addressBytes,
      Uint8List birthBytes, Uint8List sexBytes) {
    this.name = utf8.decode(nameBytes);
    this.address = utf8.decode(addressBytes);
    this.birth = String.fromCharCodes(birthBytes);
    this.sex = sexBytes[0];
  }

  Uint8List header;
  String? name; // utf8
  String? address; // utf8
  String? birth; // ascii numbers
  int? sex; // ascii id

  String toString() {
    return "名前: $name\n" + "住所: $address\n" + "生年月日: $birth\n" + "性別: $sex\n";
  }
}

class CertificateAP {
  CertificateAP(this.communicator);

  APDUCommunicator communicator;

  // 電子証明書DF D3:92:F0:00:26:01:00:00:00:01
  final List<int> DFID = [
    0xD3,
    0x92,
    0xF0,
    0x00,
    0x26,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01
  ];

  /// 利用者用証明書
  final List<int> userCertificateEFID = [0x00, 0x0A];

  /// 利用者用証明書用PIN
  final List<int> certPinEFID = [0x00, 0x18];

  /// 利用者用鍵
  final List<int> userPrivKeyEFID = [0x00, 0x17];


  static final String PEM_CERT_START = "-----BEGIN CERTIFICATE-----\n";
  static final String PEM_CERT_END = "\n-----END CERTIFICATE-----\n";

  /// 利用者用証明書を取得します。
  Future<String> selectUserCertificate() async {
    await communicator.read(APDUCommands.selectDF(DFID));
    await communicator.read(APDUCommands.selectEF(userCertificateEFID));
    APDUResponse resp = await communicator
        .read(APDUCommands.readBinary(Uint8List.fromList([0x00, 0x00]), 4));

    ASN1Length asn1Length = ASN1Length.decodeLength(resp.bodyBytes!);
    // TLVなので、TL部分(=4byte)を足したものが全体のデータサイズ
    int dataLength = asn1Length.length + asn1Length.valueStartPosition;
    print("length=${dataLength}");
    Uint8List buf = await readBigBinary(dataLength);
    print("buf=$buf");
    return toPem(buf);
  }

  /// PINを解除して利用者用証明書の鍵で署名を作成します。
  Future<Uint8List> createSignature(String pinCode, String msg) async {
    await this._verifyPIN(pinCode); //PINコードを解除
    await communicator.read(APDUCommands.selectEF(userPrivKeyEFID)); // 利用者用鍵を選択
    APDUResponse res = await communicator
        .read(MyNumberCardExtendedAPDUCommand.computeDigitalSignature(msg.codeUnits));
    print("complete generate sign.");
    return res.bodyBytes!;
  }

  ///  利用者証明書のPINを解除
  Future<String> _verifyPIN(String pinCode) async {
    await communicator.read(APDUCommands.selectDF(DFID));
    await communicator.read(APDUCommands.selectEF(certPinEFID));
    APDUResponse res =
    await communicator.read(APDUCommands.verify(pinCode.codeUnits));
    print("res=${res.toString()}");
    print("success verify pincode!");
    return "PINの解除に成功しました。";
  }

  Future<Uint8List> readBigBinary(int length) async {
    Uint8List buf = Uint8List(length);
    for (int i = 0; i < length; i += 256) {
      int perLength = length - i;
      if (perLength > 256) perLength = 256;

      APDUResponse res = await communicator
          .read(APDUCommands.readBinary(int16Bytes(i), perLength));
      print("perLength=${perLength}, readBytes=${res.bodyBytes!.length}");
      buf.setAll(i, res.bodyBytes!);
      print("buf.length=${buf.length}");
    }
    return buf;
  }

  String toPem(Uint8List cert) =>
      PEM_CERT_START + base64Encode(cert) + PEM_CERT_END;
}
