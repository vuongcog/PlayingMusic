// https://app.uizard.io/templates/rgoB690VYXFYaja4gVa9/preview
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:working_message_mobile/app/index.dart';
import 'package:working_message_mobile/objects/theme_provider.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (_) => ThemeProvider(), child: App()));
}
