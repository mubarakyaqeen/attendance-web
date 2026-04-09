import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

// ✅ NEW IMPORTS (for your pages)
import 'pages/landing_page.dart';
import 'pages/download_page.dart';
import 'pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ✅ KEEP YOUR ORIGINAL SPLASH FLOW
      home: const SplashFadeWrapper(
        child: SplashScreen(),
      ),

      // ✅ ADD ROUTES (NEW)
      routes: {
        '/landing': (context) => const LandingPage(),
        '/download': (context) => const DownloadPage(),
        '/app': (context) => const LoginPage(),
      },
    );
  }
}

class SplashFadeWrapper extends StatefulWidget {
  final Widget child;

  const SplashFadeWrapper({super.key, required this.child});

  @override
  State<SplashFadeWrapper> createState() => _SplashFadeWrapperState();
}

class _SplashFadeWrapperState extends State<SplashFadeWrapper> {
  double opacity = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => opacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: opacity,
      child: widget.child,
    );
  }
}