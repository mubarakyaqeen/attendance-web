import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

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
      home: const SplashFadeWrapper(
        child: SplashScreen(),
      ),
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