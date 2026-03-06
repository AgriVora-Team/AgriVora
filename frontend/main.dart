import 'package:flutter/material.dart';

// 🌿 UI pages (your base flow)
import 'pages/welcome_page.dart';
import 'pages/permission_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/role_select_page.dart';
import 'pages/home_page.dart';

import 'pages/soil_analysis_page.dart';
import 'pages/manual_soil_analysis_page.dart';

// 🧪 Dev1 scan flow
import 'scan_flow/start_scan_screen.dart';

// ✅ Added pages from main2.dart (CHANGE paths if your files are in another folder)
import 'pages/crop_recom_page.dart';
import 'pages/profile_page.dart';
import 'pages/crop_overview_page.dart';
import 'pages/map_page.dart';
import 'pages/ai_chat_page.dart';

/// ------------------
/// ScanSession model
/// ------------------
class ScanSession {
  final String scanId;
  final DateTime timestamp;

  // GPS
  final double? latitude;
  final double? longitude;

  // pH
  final double? ph;

  // Image
  final String? imagePath;
  final String? imageUrl;

  // CNN texture output
  final String? textureLabel;
  final double? textureConfidence;

  // External APIs
  final Map<String, dynamic>? soilgrids;
  final Map<String, dynamic>? weather;

  // RF recommender output
  final List<RecommendationResult> results;
  final List<String> tips;

  ScanSession({
    required this.scanId,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.ph,
    this.imagePath,
    this.imageUrl,
    this.textureLabel,
    this.textureConfidence,
    this.soilgrids,
    this.weather,
    List<RecommendationResult>? results,
    List<String>? tips,
  })  : results = results ?? const [],
        tips = tips ?? const [];

  factory ScanSession.empty(String scanId) {
    return ScanSession(
      scanId: scanId,
      timestamp: DateTime.now(),
    );
  }

  ScanSession copyWith({
    double? latitude,
    double? longitude,
    double? ph,
    String? imagePath,
    String? imageUrl,
    String? textureLabel,
    double? textureConfidence,
    Map<String, dynamic>? soilgrids,
    Map<String, dynamic>? weather,
    List<RecommendationResult>? results,
    List<String>? tips,
  }) {
    return ScanSession(
      scanId: scanId,
      timestamp: timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ph: ph ?? this.ph,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      textureLabel: textureLabel ?? this.textureLabel,
      textureConfidence: textureConfidence ?? this.textureConfidence,
      soilgrids: soilgrids ?? this.soilgrids,
      weather: weather ?? this.weather,
      results: results ?? this.results,
      tips: tips ?? this.tips,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scanId': scanId,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'ph': ph,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'textureLabel': textureLabel,
      'textureConfidence': textureConfidence,
      'soilgrids': soilgrids,
      'weather': weather,
      'results': results.map((r) => r.toJson()).toList(),
      'tips': tips,
    };
  }
}

class RecommendationResult {
  final String crop;
  final double score;
  final List<String> reasons;

  RecommendationResult({
    required this.crop,
    required this.score,
    required this.reasons,
  });

  Map<String, dynamic> toJson() {
    return {
      'crop': crop,
      'score': score,
      'reasons': reasons,
    };
  }
}

/// ------------------
/// ENTRY POINT
/// ------------------
void main() {
  final testSession = ScanSession.empty('test_001');
  // ignore: avoid_print
  print(testSession.toJson());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgriVora',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),

      // First screen (your base flow)
      home: const WelcomePage(),

      // Routes (merged)
      routes: {
        // ✅ Base routes
        '/permission': (_) => const PermissionPage(),
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignUpPage(),
        '/role': (_) => const RoleSelectPage(),
        '/home': (_) => const HomePage(),

        '/soil-analysis': (_) => const SoilAnalysisPage(),
        '/manual-soil': (_) => const ManualSoilAnalysisPage(),
        '/start-scan': (_) => const StartScanScreen(),

        // ✅ Added routes from main2.dart (aliases too)
        '/crop-recom': (_) => const CropRecomPage(),
        '/crop_recom_page': (_) => const CropRecomPage(),

        '/profile': (_) => const ProfilePage(),
        '/profile_page': (_) => const ProfilePage(),

        '/ai-chat': (_) => const AIChatPage(),
        '/ai_chat': (_) => const AIChatPage(),

        '/map': (_) => const MapPage(),
        '/map_page': (_) => const MapPage(),

        '/crop-overview': (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments as Map<String, dynamic>?;
          return CropOverviewPage(
            name: args?['name'] ?? 'Crop',
            scientific: args?['scientific'] ?? 'Species',
            image: args?['image'] ?? 'assets/images/tomato.png',
          );
        },
        '/crop_overview': (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments as Map<String, dynamic>?;
          return CropOverviewPage(
            name: args?['name'] ?? 'Crop',
            scientific: args?['scientific'] ?? 'Species',
            image: args?['image'] ?? 'assets/images/tomato.png',
          );
        },

        // Alias to keep compatibility with main2 naming
        '/soil_analysis': (_) => const SoilAnalysisPage(),
      },
    );
  }
}
