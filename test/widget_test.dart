// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collection/collection.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:nfc_manager/src/platform_tags/iso_dep.dart';

import 'package:nfc_poc/main.dart';
import 'package:nfc_poc/models/ByteConverter.dart';
import 'package:nfc_poc/models/MyNumberCard.dart';
import 'package:nfc_poc/models/apdu/APDUCommunicator.dart';
import 'package:typed_data/typed_data.dart';
import 'package:convert/convert.dart';

void main() {
  group('test', () {
    test('list split', () {
      List<int> datas = [1, 2, 3, 4, 5];
      Uint8List bytes = Uint8List.fromList(datas);
      int length = bytes.length;
      Uint8List subList = bytes.sublist(length-2, length);
      print(subList);
      print(datas.sublist(0, length-2));


      Uint8List successCode = Uint8List.fromList([0x90, 0x00]);
      List<int> returnCode = [0x90, 0x00];

      print(ListEquality().equals(returnCode, successCode));
      Uint8List bytesInt = Uint8List.fromList([0x01, 0, 0, 0]);
      print(bytesInt.buffer.asByteData().getInt32(0));
      print(bytesInt[0]);
      print(int16Bytes(65536));
    });

    test('parseAttributes', () {
      String testData = "ff 20 7d df 21 08 00 0e 00 20 00 71 00 7c df 22 0f e4 b8 ad e5 9f 8e e3 80 80 e5 85 83 e8 87 a3 df 23 4e e7 a6 8f e5 b2 a1 e7 9c 8c e9 a3 af e5 a1 9a e5 b8 82 e5 b9 b8 e8 a2 8b ef bc 95 ef bc 97 ef bc 96 e7 95 aa e5 9c b0 ef bc 95 e3 80 80 e3 82 b9 e3 83 9a e3 83 a9 e3 83 b3 e3 83 84 e3 82 a1 ef bc 91 e3 80 80 ef bc 92 ef bc 90 ef bc 92 df 24 08 31 39 37 39 30 35 31 37 df 25 01";
      Uint8List testDataBinary = Uint8List.fromList(testData.split(" ").map((c) => hex.decode(c)[0]).toList());
      TextConfirmAP textAp = TextConfirmAP(APDUCommunicator(null));
      Attributes attrs = textAp.parseAttributes(testDataBinary.sublist(3));
      print(attrs);
    });
  });
}