import 'dart:typed_data';
import 'package:flutter/material.dart';

class BluetoothService {
  Future<bool> isAvailable() async => false;

  Future<List<String>> getDevices() async => [];

  Future<void> connect(String address) async {
    throw UnimplementedError('Bluetooth non disponible');
  }

  Future<void> printBytes(Uint8List bytes) async {
    throw UnimplementedError('Bluetooth non disponible');
  }

  Future<void> printPdf(Uint8List pdfBytes) async {
    throw UnimplementedError('Bluetooth non disponible');
  }

  Future<void> disconnect() async {}
}
