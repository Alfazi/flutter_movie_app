import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'screens/movie_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/rental_list_screen.dart';
import 'controllers/auth_controller.dart';
import 'controllers/rental_controller.dart';
import 'controllers/movie_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('[APP] 🚀 Initializing Firebase...');
  try {
    await Firebase.initializeApp();
    print('[APP] ✅ Firebase initialized successfully');
  } catch (e) {
    print('[APP] ❌ Firebase initialization error: $e');
  }
  
  print('[APP] 🎮 Initializing GetX Controllers...');
  Get.put(AuthController());
  Get.put(RentalController());
  Get.put(MovieController());
  print('[APP] ✅ Controllers initialized');
  
  print('[APP] 🎬 Application starting...');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('[APP] Building GetMaterialApp with dark theme');
    return GetMaterialApp(
      title: 'Movie Rental',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/home', page: () => const MovieListScreen()),
        GetPage(name: '/rentals', page: () => const RentalListScreen()),
      ],
      home: const LoginScreen(),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
