import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/driver_trip_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/driver/driver_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/trips/trips_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoading = authProvider.isLoading;
      final isDriver = authProvider.role == null ? false : authProvider.role!.name == 'chofer';
      final isLoginRoute = state.matchedLocation == '/login';
      final isDriverHomeRoute = state.matchedLocation == '/driver-home';

      if (isLoading) {
        return null;
      }

      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }

      if (isAuthenticated && isLoginRoute) {
        return isDriver ? '/driver-home' : '/home';
      }

      if (isAuthenticated && isDriver && (state.matchedLocation == '/home' || state.matchedLocation == '/map')) {
        return '/driver-home';
      }

      if (isAuthenticated && !isDriver && isDriverHomeRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/driver-home',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => DriverTripProvider(),
          child: const DriverScreen(),
        ),
      ),
      GoRoute(
        path: '/trips',
        builder: (context, state) => const TripsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
