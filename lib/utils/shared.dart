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
