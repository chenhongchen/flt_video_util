import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class FltVideoUtil {
  static const MethodChannel _channel = const MethodChannel('flt_video_util');

  static Future<bool> compressToMp4(String videoPath, String mp4Path) async {
    if ((videoPath ?? '').length <= 0 || (mp4Path ?? '').length <= 0) {
      return false;
    }
    Map param = Map();
    param['videoPath'] = videoPath;
    param['mp4Path'] = mp4Path;

    final bool isSuccess = await _channel.invokeMethod('compressToMp4', param);
    return isSuccess;
  }

  static Future<Size> getVideoSize(String videoPath) async {
    if ((videoPath ?? '').length <= 0) {
      return Size.zero;
    }
    Map param = Map();
    param['videoPath'] = videoPath;

    final Size size = await _channel.invokeMethod('getVideoSize', param);
    return size;
  }
}
