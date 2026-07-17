import 'package:flutter/material.dart';

import 'homepage.dart';
import 'streetmode.dart';
import 'warning.dart';
import 'denied.dart';

import 'notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();

  runApp(const WaspadaOjol());
}

class WaspadaOjol extends StatelessWidget {
  const WaspadaOjol({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "WaspadaOjol",

      theme: ThemeData(
        fontFamily: "Roboto",

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff197A43)),

        useMaterial3: true,
      ),

      initialRoute: "/",

      routes: {
        "/": (context) => const HomePage(),

        "/streetmode": (context) => const StreetMode(),

        "/warning": (context) => const WarningPage(),

        "/denied": (context) => const DeniedPage(),
      },
    );
  }
}
