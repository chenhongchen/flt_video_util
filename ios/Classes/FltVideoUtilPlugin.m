#import "FltVideoUtilPlugin.h"
#import "SDAVAssetExportSession.h"

@implementation FltVideoUtilPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flt_video_util"
            binaryMessenger:[registrar messenger]];
  FltVideoUtilPlugin* instance = [[FltVideoUtilPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *method = call.method;
    NSDictionary *argsMap = call.arguments;
    if ([@"compressToMp4" isEqualToString:method]) {
        NSString *videoPath = argsMap[@"videoPath"];
        NSString *mp4Path = argsMap[@"mp4Path"];
        
        AVURLAsset *anAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
        SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:anAsset];
        encoder.outputFileType = AVFileTypeMPEG4;
        encoder.outputURL = [NSURL fileURLWithPath:mp4Path];

        CGSize size = [self getVideoSize:videoPath];
        double width = 960;
        double height = 960;
        if (size.width > 0 && size.height > 0) {
            if (size.width > size.height) {
                width = 960;
                height = width * size.height / size.width;
            }
            else {
                height = 960;
                width = height * size.width / size.height;
            }
        }
        encoder.videoSettings = @
        {
            // 960
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: @(width),
            AVVideoHeightKey: @(height),
            AVVideoCompressionPropertiesKey: @
            {
                AVVideoAverageBitRateKey: @3000000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
            },
        };
        encoder.audioSettings = @
        {
            AVFormatIDKey: @(kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey: @2,
            AVSampleRateKey: @44100,
            AVEncoderBitRateKey: @128000,
        };

        [encoder exportAsynchronouslyWithCompletionHandler:^
        {
            if (encoder.status == AVAssetExportSessionStatusCompleted)
            {
                NSLog(@"Video export succeeded");
                result(@(YES));
            }
            else if (encoder.status == AVAssetExportSessionStatusCancelled)
            {
                NSLog(@"Video export cancelled");
                result(@(NO));
            }
            else
            {
                NSLog(@"Video export failed with error: %@ (%d)", encoder.error.localizedDescription, encoder.error.code);
                result(@(NO));
            }
        }];
    }
    else if ([@"getVideoSize" isEqualToString:method]) {
        NSString *videoPath = argsMap[@"videoPath"];
        CGSize size = [self getVideoSize:videoPath];
        result(@{@"width":@(size.width), @"height":@(size.height)});
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (CGSize)getVideoSize:(NSString *)videoPath {
    CGSize size = CGSizeMake(1, 1);
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
    NSArray *tracks = [avAsset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;//这里的矩阵有旋转角度，转换一下即可
        CGFloat rotate = acosf(t.a);
        // 旋转180度后，需要处理弧度的变化
        if (t.b < 0) {
            rotate = M_PI - rotate;
        }
        // 将弧度转换为角度
        CGFloat degree = rotate/M_PI * 180;
        double w = videoTrack.naturalSize.width;
        double h = videoTrack.naturalSize.height;
        if (fabs(degree - 90) < 1) {
            size = CGSizeMake(h, w);
        }
        else {
            size = CGSizeMake(w, h);
        }
    }
    return size;
}

@end