import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'TropiMotos';

  static const String baseUrlWeb = 'http://localhost:8080';
  static const String baseUrlAndroid = 'http://10.0.2.2:8080';

  static String get baseUrl {
    if (kIsWeb) {
      return baseUrlWeb;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return baseUrlAndroid;
    }

    return baseUrlWeb;
  }

  static const String apiAuth = '/api/auth';
  static const String loginEndpoint = '$apiAuth/login';
  static const String registerEndpoint = '$apiAuth/register';
  static const String tripEndpoint = '/api/trips/request';
  static const String driverRequestedTripsEndpoint = '/api/trips?estado=SOLICITADO';
  static const String driverAcceptTripEndpoint = '/api/trips';

  static const String jwtTokenKey = 'jwt_token';
  static const String userRoleKey = 'user_role';
  static const String userEmailKey = 'user_email';
  static const String userNameKey = 'user_name';

  static const String roleAdmin = 'ADMIN';
  static const String roleChofer = 'CHOFER';
  static const String roleCliente = 'CLIENTE';

  static const String googleMapsApiKeyPlaceholder = 'AIzaSyDKNpK47C1AncfAltHI_nnX-k1Zb-f-fPg';

  static const double rideBaseFare = 5.0;
  static const double ridePricePerKm = 2.8;
  static const double averageSpeedKmPerHour = 28.0;
}
