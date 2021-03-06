package com.mt.flt_video_util;

import androidx.annotation.NonNull;

import com.vincent.videocompressor.VideoController;

import org.reactivestreams.Subscriber;
import org.reactivestreams.Subscription;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.reactivex.Flowable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.functions.Function;
import io.reactivex.schedulers.Schedulers;

/** FltVideoUtilPlugin */
public class FltVideoUtilPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flt_video_util");
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flt_video_util");
    channel.setMethodCallHandler(new FltVideoUtilPlugin());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }else if(call.method.equals("compressToMp4")){
      Map args=(Map)call.arguments;
      Flowable.just(args)
              .map(new Function<Map, Boolean>() {
                @Override
                public Boolean apply(@io.reactivex.annotations.NonNull Map map) throws Exception {
                  String videoPath=(String) map.get("videoPath");
                  String mp4Path=(String) map.get("mp4Path");
                  Double maxSize=(Double) map.get("maxSize");
                  int bitRate=(int) map.get("bitRate");
                  return VideoController.getInstance().convertVideo(videoPath, mp4Path,
                          maxSize,bitRate,null);
                }
              })
              .subscribeOn(Schedulers.io())
              .observeOn(AndroidSchedulers.mainThread())
              .subscribe(new Subscriber<Boolean>() {
                @Override
                public void onSubscribe(Subscription s) {
                  s.request(Long.MAX_VALUE);
                }

                @Override
                public void onNext(Boolean aBoolean) {
                  result.success(aBoolean);
                }

                @Override
                public void onError(Throwable t) {
                  result.success(false);
                }

                @Override
                public void onComplete() {

                }
              });
    }else if(call.method.equals("getVideoSize")){
      Map args=(Map)call.arguments;
      String videoPath=(String) args.get("videoPath");
      double[] videoSize=VideoController.getInstance().getVideoSize(videoPath);
      Map<String,Double> map=new HashMap<>();
      map.put("width",videoSize[0]);
      map.put("height",videoSize[1]);
      result.success(map);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
