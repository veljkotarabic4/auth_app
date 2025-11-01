import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/connectivity_service.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool connected = await ConnectivityService.hasInternetConnection();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..tryAutoLogin()),
      ],
      child: ConnectivityListener(
        child: MyApp(connected: connected),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool connected;
  const MyApp({super.key, required this.connected});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Note & Do',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      initialRoute: connected
          ? (auth.isLoggedIn ? '/home' : '/login')
          : '/no-internet',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/no-internet': (context) => const NoInternetScreen(),
      },
    );
  }
}

// 🔹 Dinamička provera konekcije
class ConnectivityListener extends StatefulWidget {
  final Widget child;
  const ConnectivityListener({super.key, required this.child});

  @override
  State<ConnectivityListener> createState() => _ConnectivityListenerState();
}

class _ConnectivityListenerState extends State<ConnectivityListener> {
  bool _hasConnection = true;

  @override
  void initState() {
    super.initState();
    ConnectivityService.connectionStream.listen((connected) {
      if (mounted) {
        setState(() => _hasConnection = connected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasConnection) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.wifi_off, color: Colors.white, size: 100),
              SizedBox(height: 20),
              Text(
                "Nema internet konekcije",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              SizedBox(height: 10),
              Text(
                "Proveri mrežu i pokušaj ponovo.",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }
    return widget.child;
  }
}

// 🔹 Ekran bez konekcije pri pokretanju app-a
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.wifi_off, color: Colors.white, size: 100),
            SizedBox(height: 20),
            Text(
              "Nema internet konekcije",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              "Proveri mrežu i pokreni aplikaciju ponovo.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}