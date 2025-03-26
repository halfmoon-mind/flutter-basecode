import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppFlavor {
  development,
  staging,
  production,
}

class EnvConfig {
  static String appFlavor = '';
  static Future<void> initialize(AppFlavor flavor) async {
    appFlavor = flavor.name;
    // flavor 환경에 따라 환경 파일 로드
    await dotenv.load(fileName: '.env.${flavor.name}');
  }

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.pickiverse.com';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  // 환경별 설정
  static String get environment => appFlavor;
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';

  static String get onesignalAppId => dotenv.env['ONESIGNAL_APP_ID'] ?? '';
  static String get androidNativeAdId =>
      dotenv.env['ANDROID_NATIVE_AD_ID'] ?? '';
  static String get iosNativeAdId => dotenv.env['IOS_NATIVE_AD_ID'] ?? '';
  static String get androidBannerAdId =>
      dotenv.env['ANDROID_BANNER_AD_ID'] ?? '';
  static String get iosBannerAdId => dotenv.env['IOS_BANNER_AD_ID'] ?? '';
}
