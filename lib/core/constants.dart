import 'package:flutter/material.dart';

/// App-wide constants.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'GymOS';
  static const String appTagline = 'AI-Powered Gym Management';
  static const String appVersion = '0.1.0';

  // Supabase Table Names
  static const String profilesTable = 'profiles';
  static const String gymsTable = 'gyms';
  static const String gymMembersTable = 'gym_members';
  static const String clientsTable = 'clients';
  static const String membershipsTable = 'memberships';
  static const String subscriptionsTable = 'subscriptions';

  // Storage Buckets
  static const String avatarsBucket = 'avatars';
  static const String gymLogosBucket = 'gym-logos';
  static const String progressPhotosBucket = 'progress-photos';

  // Limits
  static const int basicMaxClients = 50;
  static const int proMaxClients = 200;
  static const int basicMaxTrainers = 1;
  static const int proMaxTrainers = 5;

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 350);
  static const Duration slowAnimation = Duration(milliseconds: 600);

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
}

/// App color palette — dark-first premium aesthetic.
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF6C63FF); // Electric violet
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42E8);

  // Accent
  static const Color accent = Color(0xFF00E5A0); // Neon mint
  static const Color accentLight = Color(0xFF4DFFCB);
  static const Color accentDark = Color(0xFF00B880);

  // Background
  static const Color bgDark = Color(0xFF0A0A0F); // Near black
  static const Color bgCard = Color(0xFF12121A); // Card surface
  static const Color bgElevated = Color(0xFF1A1A2E); // Elevated surface
  static const Color bgInput = Color(0xFF16162B); // Input fields

  // Text
  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFF9090A7);
  static const Color textMuted = Color(0xFF5A5A72);

  // Status
  static const Color success = Color(0xFF00E5A0);
  static const Color warning = Color(0xFFFFB547);
  static const Color error = Color(0xFFFF4757);
  static const Color info = Color(0xFF54A0FF);

  // Borders & Dividers
  static const Color border = Color(0xFF2A2A3D);
  static const Color divider = Color(0xFF1F1F32);

  // Glassmorphism
  static const Color glassBg = Color(0x1AFFFFFF); // 10% white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white
}
