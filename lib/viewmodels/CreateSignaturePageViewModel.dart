import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_poc/models/mynumber/KenmenInfoAPReader.dart';
import 'package:nfc_poc/models/mynumber/SIgnatureCreator.dart';
import 'package:nfc_poc/models/providers/NFCProvider.dart';

class SigState {
  final bool? isNFCSupported;
  String? message;
  String? stateMessage;
  String? pinCode;
  SigState({this.isNFCSupported, this.stateMessage, this.pinCode, this.message});

  SigState copyWith({bool? isNFCSupported, String? stateMessage, String? pinCode, String? newMessage}) {
    bool? supported = isNFCSupported == null ? this.isNFCSupported : isNFCSupported;
    String? msg = stateMessage == null ? this.stateMessage : stateMessage;
    String? pcode = pinCode == null ? this.pinCode : pinCode;
    String? message = newMessage == null ? this.message : newMessage;
    return SigState(isNFCSupported: supported, stateMessage: msg, pinCode: pcode, message: message);
  }
}

/// 署名作成画面のViewModel
class CreateSignaturePageViewModel extends StateNotifier<SigState> {
  NFCProvider _nfcProvider = NFCProvider();
  CreateSignaturePageViewModel() : super(SigState(isNFCSupported: false, stateMessage: "ボタンを押してください。")) {
    _nfcProvider.setHandler(stateHandler);
    checkAvailable();
  }

  /// providerから通知を受け取るためのhandler
  void stateHandler(String message) {
    state = state.copyWith(stateMessage: message);
  }

  /// NFCとの通信を開始します。
  Future<void> connect(String pinCode, String msg) async {
    state = state.copyWith(pinCode: pinCode, newMessage: msg, stateMessage: "マイナンバーカードをタッチしてください。");
    final sigCreator = SignatureCreator(pinCode, msg);
    try {
      sigCreator.verify();
      String result = await _nfcProvider.connect(sigCreator);
      state = state.copyWith(stateMessage: result);
    } catch(e) {
      if(e is PinCodeAndMsgException) {
       state = state.copyWith(stateMessage: (e as PinCodeAndMsgException).message);
      } else {
        state = state.copyWith(stateMessage: e.toString());
      }
    }
  }

  /// NFCが利用可能かチェックします。
  Future<void> checkAvailable() async {
    state = state.copyWith(isNFCSupported: await _nfcProvider.checkNFCAvailable());
  }
}