import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class FltVideoUtil {
  static const MethodChannel _channel = const MethodChannel('flt_video_util');

  static Future<bool> compressToMp4(String videoPath, String mp4Path,
      {double maxSize, int bitRate}) async {
    if ((videoPath ?? '').length <= 0 || (mp4Path ?? '').length <= 0) {
      return false;
    }
    Map param = Map();
    param['videoPath'] = videoPath;
    param['mp4Path'] = mp4Path;
    param['maxSize'] = maxSize ?? 960.0;
    param['bitRate'] = bitRate ?? 3000000;

    final bool isSuccess = await _channel.invokeMethod('compressToMp4', param);
    return isSuccess;
  }

  static Future<Size> getVideoSize(String videoPath) async {
    if ((videoPath ?? '').length <= 0) {
      return Size.zero;
    }
    Map param = Map();
    param['videoPath'] = videoPath;

    Map map = await _channel.invokeMethod('getVideoSize', param);
    double width = map['width'] ?? 0;
    double height = map['height'] ?? 0;
    Size size = Size(width, height);
    return size;
  }
}
