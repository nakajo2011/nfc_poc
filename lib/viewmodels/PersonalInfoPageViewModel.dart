import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_poc/models/mynumber/KenmenInfoAPReader.dart';
import 'package:nfc_poc/models/providers/NFCProvider.dart';

class NFCState {
  final bool? isNFCSupported;
  String? stateMessage;
  String? pinCode;
  NFCState({this.isNFCSupported, this.stateMessage, this.pinCode});

  NFCState copyWith({bool? isNFCSupported, String? stateMessage, String? pinCode}) {
    bool? supported = isNFCSupported == null ? this.isNFCSupported : isNFCSupported;
    String? msg = stateMessage == null ? this.stateMessage : stateMessage;
    String? pcode = pinCode == null ? this.pinCode : pinCode;
    return NFCState(isNFCSupported: supported, stateMessage: msg, pinCode: pcode);
  }
}

/// NFCの読み取り状況を通知するためのNotifier
class PersonalInfoPageViewModel extends StateNotifier<NFCState> {
  NFCProvider _nfcProvider = NFCProvider();
  PersonalInfoPageViewModel() : super(NFCState(isNFCSupported: false, stateMessage: "ボタンを押してください。")) {
    _nfcProvider.setHandler((String s) => print);
    checkAvailable();
  }

  /// providerから通知を受け取るためのhandler
  void stateHandler(String message) {
    state = state.copyWith(stateMessage: message);
  }

  /// NFCとの通信を開始します。
  Future<void> connect(String pinCode) async {
    state = state.copyWith(stateMessage: "マイナンバーカードをタッチしてください。");
    final reader = KenmenInfoAPReader(pinCode);
    try {
      reader.verifyPinCode();
      String result = await _nfcProvider.connect(reader);
      state = state.copyWith(stateMessage: result);
    } catch(e) {
      if(e is PinCodeException) {
       state = state.copyWith(stateMessage: (e as PinCodeException).message);
      } else {
        state = state.copyWith(stateMessage: e.toString());
      }
    }
  }

  /// NFCが利用可能かチェックします。
  Future<void> checkAvailable() async {
    state = state.copyWith(isNFCSupported: await _nfcProvider.checkNFCAvailable());
  }

  void setPinCode(String code) {
    state = state.copyWith(pinCode: code);
  }
}