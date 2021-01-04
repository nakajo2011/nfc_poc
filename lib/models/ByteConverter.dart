import 'dart:typed_data';

Uint8List int32Bytes(int value) =>
    Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.big);

Uint8List int16Bytes(int value) =>
    Uint8List(2)..buffer.asByteData().setInt16(0, value, Endian.big);