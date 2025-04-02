import 'dart:ui';

Color hextToColor(String hex) {
  hex = hex.replaceFirst('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex'; // Thêm Alpha mặc định nếu thiếu
  }
  return Color(int.parse(hex, radix: 16)); // Chuyển thành số nguyên
}
