import 'dart:typed_data';

abstract class APDUCommand {
  const APDUCommand();
  /// return command byte format
  Uint8List get payload;
  toHex(num) => num.toRadixString(16).padLeft(2, "0");
  String get dumpPayload => payload.map(toHex).join(":");
}

/// コマンドデータなし、レスポンスデータなしのコマンド
class APDUCommand1 extends APDUCommand {
  const APDUCommand1(this.cla, this.ins, this.p1, this.p2) : super();
  /// クラスバイト(1byte)
  final int cla;
  /// 命令バイト(1byte)
  final int ins;
  /// パラメータバイト1(1byte)
  final int p1;
  /// パラメータバイト2(1byte)
  final int p2;

  @override
  Uint8List get payload => Uint8List.fromList([cla, ins, p1, p2]);
}

/// コマンドデータなし、レスポンスデータありのコマンド
class APDUCommand2 extends APDUCommand {
  const APDUCommand2(this.cla, this.ins, this.p1, this.p2, this.le) : super();
  /// クラスバイト(1byte)
  final int cla;
  /// 命令バイト(1byte)
  final int ins;
  /// パラメータバイト1(1byte)
  final int p1;
  /// パラメータバイト2(1byte)
  final int p2;
  /// レスポンスデータの期待される最大サイズ(1 or 3byte)
  final int le;

  @override
  Uint8List get payload => Uint8List.fromList([cla, ins, p1, p2, le]);
}

/// コマンドデータあり、レスポンスデータなしのコマンド
class APDUCommand3 extends APDUCommand {
  APDUCommand3(this.cla, this.ins, this.p1, this.p2, this.data) {
    this.lc = this.data.length;
  }
  /// クラスバイト(1byte)
  final int cla;
  /// 命令バイト(1byte)
  final int ins;
  /// パラメータバイト1(1byte)
  final int p1;
  /// パラメータバイト2(1byte)
  final int p2;
  /// コマンドデータの長さ(1 or 3byte)
  int? lc;
  /// コマンドデータ
  final Uint8List data;

  @override
  Uint8List get payload => Uint8List.fromList([cla, ins, p1, p2, lc!, ...data]);

}

/// コマンドデータあり、レスポンスデータありのコマンド
class APDUCommand4 extends APDUCommand {
  APDUCommand4(this.cla, this.ins, this.p1, this.p2, this.data, this.le) {
    this.lc = this.data.length;
  }
  /// クラスバイト(1byte)
  final int cla;
  /// 命令バイト(1byte)
  final int ins;
  /// パラメータバイト1(1byte)
  final int p1;
  /// パラメータバイト2(1byte)
  final int p2;
  /// コマンドデータの長さ(1 or 3byte)
  int? lc;
  /// コマンドデータ
  Uint8List data;
  /// レスポンスデータの期待される最大サイズ(1 or 3byte)
  final int le;

  @override
  Uint8List get payload => Uint8List.fromList([cla, ins, p1, p2, lc!, ...data, le]);

}