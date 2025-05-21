// lib/main.dart
import 'package:agriplant/pages/FarmerDashboardPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import for locale initialization
import 'package:provider/provider.dart';

import 'pages/cartpage.dart';
import 'pages/checkout_page.dart';
import 'pages/onboarding_page.dart';
import 'provider/cart_provider.dart';
import 'provider/chat_provider.dart';
import 'screens/chat_screen.dart';

void main() async {
  // Initialize locale data before running the app
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        home: const OnboardingPage(),
        routes: {
          '/cart': (context) => const CartPage(),
          '/checkout': (context) => const CheckoutPage(),
          '/chat': (context) => const ChatScreen(),
          '/addProduct': (context) =>
              const FarmerDashboardPage(), // ✅ Route ajoutée
        },
      ),
    );
  }
}
