import 'dart:typed_data';

class SuicaResponse {
  Uint8List response;

  SuicaResponse({this.response});
}

class PollingResponse extends SuicaResponse {
  PollingResponse({Uint8List response}) : super(response: response);

  get IDm {
    return this.response.sublist(2, 10);
  }

  get PMm {
    return this.response.sublist(10, 18);
  }

  get isError {
    return this.response[1] == 0;
  }

  String toString() {
    return response.toString();
  }

  String toReadableResult() {
    String result = "polling結果:\n";
    result += "\tError: ${isError}\n";
    result += "\tIDm: ${dump(IDm)}\n";
    result += "\tPMm: ${dump(PMm)}\n";

    return result;
  }
}

class HistoryListResponse extends SuicaResponse {
  List<HistoryResponse> histories;

  HistoryListResponse() {
    histories = List<HistoryResponse>();
  }

  add(HistoryResponse item) {
    this.histories.add(item);
  }

  @override
  String toString() {
    return histories.toString();
  }
}

class HistoryResponse extends SuicaResponse {
  Uint8List rawData;

  HistoryResponse({Uint8List response}) : super(response: response) {
    if (this.response.length < 16) {
      throw ArgumentError("invalid response size. maybe happend read error.");
    }
    rawData =
        this.response.sublist(this.response.length - 16, this.response.length);
  }

  String toReadableResult() {
    String result = "履歴情報:\n";
    result += "\t端末: ${terminal}\n";
    result += "\t処理: ${process}\n";
    result += "\t日付: ${datetime}\n";
    result += "---------------------------\n";

    return result;
  }

  get terminal {
    int code = rawData[0];
    switch (code) {
      case 3:
        return "精算機";
      case 4:
        return "携帯型端末";
      case 5:
        return "車載端末";
      case 7:
        return "券売機";
      case 8:
        return "券売機";
      case 9:
        return "入金機";
      case 18:
        return "券売機";
      case 20:
        return "券売機等";
      case 21:
        return "券売機等";
      case 22:
        return "改札機";
      case 23:
        return "簡易改札機";
      case 24:
      case 25:
        return "窓口端末";
      case 26:
        return "改札端末";
      case 27:
        return "携帯電話";
      case 28:
        return "乗継精算機";
      case 29:
        return "連絡改札機";
      case 31:
        return "簡易入金機";
      case 70:
        return "VIEW ALTTE";
      case 72:
        return "VIEW ALTTE";
      case 199:
        return "物販端末";
      case 200:
        return "自販機";
      default:
        return "不明";
    }
  }

  get process {
    int code = rawData[1];
    switch (code) {
      case 1:
        return "運賃支払(改札出場)";
      case 2:
        return "チャージ";
      case 3:
        return "券購(磁気券購入)";
      case 4:
        return "精算";
      case 5:
        return "精算 (入場精算)";
      case 6:
        return "窓出 (改札窓口処理)";
      case 7:
        return "新規 (新規発行)";
      case 8:
        return "控除 (窓口控除)";
      case 13:
        return "バス (PiTaPa系)";
      case 15:
        return "バス (IruCa系)";
      case 17:
        return "再発 (再発行処理)";
      case 19:
        return "支払 (新幹線利用)";
      case 20:
        return "入A (入場時オートチャージ)";
      case 21:
        return "出A (出場時オートチャージ)";
      case 31:
        return "入金 (バスチャージ)";
      case 35:
        return "券購 (バス路面電車企画券購入)";
      case 70:
        return "物販";
      case 72:
        return "特典 (特典チャージ)";
      case 73:
        return "入金 (レジ入金)";
      case 74:
        return "物販取消";
      case 75:
        return "入物 (入場物販)";
      case 198:
        return "物現 (現金併用物販)";
      case 203:
        return "入物 (入場現金併用物販)";
      case 132:
        return "精算 (他社精算)";
      case 133:
        return "精算 (他社入場精算)";
      default:
        return "不明";
    }
  }

  get datetime {
    int date = response[4] * 256 + response[5];
    print("date=$date, ${response[4]}, ${response[5]}, toHex=${date.toRadixString(2)}");
    int year = (date >> 9) + 2000;
    int month = ((date >> 5) & 0x0F) + 1;
    int day = date & 0x1F;
    return "$year/$month/$day";
  }

  @override
  String toString() {
    // TODO: implement toString
    return toReadableResult();
  }
}

String dump(Uint8List buf) {
  return buf
      .map((e) => e.toRadixString(16).padLeft(2, "0").toUpperCase())
      .join(":");
}
