import 'package:flutter_riverpod/all.dart';
import 'package:nfc_poc/models/providers/NFCProvider.dart';
import 'package:nfc_poc/models/providers/SuicaProvider.dart';

class SuicaState {
  final bool isNFCSupported;
  String stateMessage;
  SuicaState({this.isNFCSupported, this.stateMessage});

  SuicaState copyWith({isNFCSupported, stateMessage, pinCode}) {
    bool supported = isNFCSupported == null ? this.isNFCSupported : isNFCSupported;
    String msg = stateMessage == null ? this.stateMessage : stateMessage;
    return SuicaState(isNFCSupported: supported, stateMessage: msg);
  }
}

/// Suicaの読み取り状況を通知するためのNotifier
class SuicaNotifier extends StateNotifier<SuicaState> {
  SuicaProvider _suicaProvider;
  SuicaNotifier() : super(SuicaState(isNFCSupported: false, stateMessage: "ボタンを押してください。")) {
    _suicaProvider =  SuicaProvider();
    _suicaProvider.setHandler(stateHandler);
    checkAvailable();
  }

  /// providerから通知を受け取るためのhandler
  void stateHandler(String message) {
    state = state.copyWith(stateMessage: message);
  }

  /// NFCとの通信を開始します。
  Future<void> connect() async {
    state = state.copyWith(stateMessage: "Suicaをタッチしてください。");
    await _suicaProvider.connect();
    return;
  }

  /// NFCが利用可能かチェックします。
  Future<void> checkAvailable() async {
    state = state.copyWith(isNFCSupported: await _suicaProvider.checkNFCAvailable());
  }

  void setPinCode(String code) {
    state = state.copyWith(pinCode: code);
  }
}