// lib/main.dart
// lib/main.dart
import 'package:agriplant/pages/BuyerDashboardPage.dart';
import 'package:agriplant/pages/ExpertDashboardPage.dart';
import 'package:agriplant/pages/FarmerDashboardPage.dart';
import 'package:agriplant/pages/cartpage.dart';
import 'package:agriplant/pages/checkout_page.dart';
import 'package:agriplant/pages/onboarding_page.dart';
import 'package:agriplant/provider/cart_provider.dart';
import 'package:agriplant/provider/chat_provider.dart';
import 'package:agriplant/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final user = FirebaseAuth.instance.currentUser;

  runApp(MyApp(
    startPage: user != null ? const HomePage() : const OnboardingPage(),
  ));
}

class MyApp extends StatelessWidget {
  final Widget startPage;
  const MyApp({super.key, required this.startPage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Agriplant',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.light,
        home: startPage,
        routes: {
          '/cart': (context) => const CartPage(),
          '/checkout': (context) => const CheckoutPage(),
          '/chat': (context) => const ChatScreen(),
          '/addProduct': (context) => const FarmerDashboardPage(),
          '/onboarding': (context) => const OnboardingPage(),
          '/expert-dashboard': (context) => const ExpertDashboardPage(),
          '/buyer-dashboard': (context) => const BuyerDashboardPage(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}
