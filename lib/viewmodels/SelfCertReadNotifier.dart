import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_poc/models/mynumber/SelfCertificateReader.dart';
import 'package:nfc_poc/models/providers/NFCProvider.dart';

class SelfCertState {
  final bool? isNFCSupported;
  String? stateMessage;
  SelfCertState({this.isNFCSupported, this.stateMessage});

  SelfCertState copyWith({isNFCSupported, stateMessage}) {
    bool supported = isNFCSupported == null ? this.isNFCSupported : isNFCSupported;
    String msg = stateMessage == null ? this.stateMessage : stateMessage;
    return SelfCertState(isNFCSupported: supported, stateMessage: msg);
  }
}

/// マイナンバーカード から自己証明書の読み取りを通知するためのNotifier
class SelfCertReadNotifier extends StateNotifier<SelfCertState> {
  NFCProvider _nfcProvider = NFCProvider();
  SelfCertReadNotifier() : super(SelfCertState(isNFCSupported: false, stateMessage: "ボタンを押してください。")) {
    _nfcProvider.setHandler(stateHandler);
    checkAvailable();
  }

  /// providerから通知を受け取るためのhandler
  void stateHandler(String message) {
    state = state.copyWith(stateMessage: message);
  }

  /// NFCとの通信を開始します。
  Future<void> connect() async {
    state = state.copyWith(stateMessage: "マイナンバーカードをタッチしてください。");
    var reader = SelfCertificateReader(stateHandler: stateHandler);
    await _nfcProvider.readSelfCert(reader);
    return;
  }

  /// NFCが利用可能かチェックします。
  Future<void> checkAvailable() async {
    state = state.copyWith(isNFCSupported: await _nfcProvider.checkNFCAvailable());
  }
}