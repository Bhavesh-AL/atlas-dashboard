import 'package:atlas_dashboard/bloc/auth_bloc.dart';
import 'package:atlas_dashboard/screens/dashboard_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/bloc/dashboard_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA5LcOSNJ5GWyQzcUZn74HxPiOzMCTd3vI",
      appId: "1:717114993968:web:1e40da38d88a78227f2cf5",
      messagingSenderId: "717114993968",
      projectId: "al-atlas-992b1",
      databaseURL: "https://al-atlas-992b1-default-rtdb.asia-southeast1.firebasedatabase.app",
      storageBucket: "al-atlas-992b1.firebasestorage.app",
    ),
  );

  runApp(const AtlasDashboardApp());
}

class AtlasDashboardApp extends StatelessWidget {
  const AtlasDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            FirebaseAuth.instance,
            FirebaseDatabase.instance.ref(),
          ),
        ),
        BlocProvider(
          create: (context) => DashboardBloc()..add(LoadDashboardData()),
        ),
      ],
      child: MaterialApp(
        title: 'ATLAS Dashboard',
        theme: AppTheme.darkTheme,
        home: const _AppBackground(
          child: DashboardWrapper(),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// This widget creates the background for the glassmorphism effect
class _AppBackground extends StatelessWidget {
  final Widget child;
  const _AppBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. The Background Gradient/Image
          Container(decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient)),
          // To use an image, uncomment this and add to pubspec assets:
          // Image.asset(
          //   'assets/images/background.png',
          //   fit: BoxFit.cover,
          //   width: double.infinity,
          //   height: double.infinity,
          // ),

          // 2. The App Content
          child,
        ],
      ),
    );
  }
}
