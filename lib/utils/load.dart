import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

Future<Uint8List> loadAssetImage(String path) async {
  ByteData data = await rootBundle.load(path);
  return data.buffer.asUint8List();
}
