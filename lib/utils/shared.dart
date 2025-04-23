import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getUserIdFromToken() async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');

  if (accessToken != null) {
    try {
      final decodedToken = JwtDecoder.decode(accessToken);
      final id = decodedToken['sub'];
      return decodedToken['sub']; // Lấy userId từ token
    } catch (e) {
      print('Lỗi khi giải mã token: $e');
      return null;
    }
  } else {
    print('Không tìm thấy access_token');
    return null;
  }
}

Future<bool> isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  return token != null && token.isNotEmpty;
}

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('access_token');

  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
}
