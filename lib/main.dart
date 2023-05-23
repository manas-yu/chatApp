import 'package:chat/screens/auth.dart';
import 'package:chat/screens/chat.dart';
import 'package:chat/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Define your seed colors.
const Color primarySeedColor = Color(0xFF6750A4);
const Color secondarySeedColor = Color(0xFF3871BB);
const Color tertiarySeedColor = Color(0xFF6CA450);
final kDarkColorscheme = SeedColorScheme.fromSeeds(
  brightness: Brightness.dark,
  primaryKey: primarySeedColor,
  secondaryKey: secondarySeedColor,
  tertiaryKey: tertiarySeedColor,
  tones: FlexTones.vivid(Brightness.dark),
);
final kColorScheme =
    ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 63, 17, 177));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: kColorScheme,
      ),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: kDarkColorscheme,
      ),

      // themeMode: ThemeMode.system,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            return const ChatScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
