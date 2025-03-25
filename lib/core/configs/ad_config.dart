import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:template/core/configs/env_config.dart';

class AdHelper {
  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      final id = EnvConfig.androidNativeAdId;
      if (kDebugMode || id.isEmpty) {
        return 'ca-app-pub-3940256099942544/2247696110';
      } else {
        return id;
      }
    } else if (Platform.isIOS) {
      final id = EnvConfig.iosNativeAdId;
      if (kDebugMode || id.isEmpty) {
        return 'ca-app-pub-3940256099942544/3986624511';
      } else {
        return id;
      }
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      final id = EnvConfig.androidBannerAdId;
      if (kDebugMode || id.isEmpty) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else {
        return id;
      }
    } else if (Platform.isIOS) {
      final id = EnvConfig.iosBannerAdId;
      if (kDebugMode || id.isEmpty) {
        return 'ca-app-pub-3940256099942544/2934735716';
      } else {
        return id;
      }
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
