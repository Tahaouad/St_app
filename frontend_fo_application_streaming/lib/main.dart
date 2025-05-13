import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend_fo_application_streaming/data/providers/auth_provider.dart';
import 'package:frontend_fo_application_streaming/data/providers/content_provider.dart';
import 'package:frontend_fo_application_streaming/data/providers/home_provider.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/auth/login_screen.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/home/home_page.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/welcome/welcome_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ContentProvider()),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(),
        ), // Added HomeProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoroccanFlix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
