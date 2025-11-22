import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/halaman_login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const AplikasiApotek());
}

class AplikasiApotek extends StatelessWidget {
  const AplikasiApotek({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apotek Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFF0067),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF0067),
          primary: const Color(0xFFFF0067),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFFFF0067),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HalamanLogin(),
    );
  }
}
