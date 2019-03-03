#import <AVFoundation/AVFoundation.h>

@interface AVAssetExportSession (Exporter)
+ (AVAssetExportSession *) overlapVideos:(NSURL *)firstUrl
                               secondUrl:(NSURL *)secondUrl
                          isPortraitMode:(BOOL) isPortraitMode
                        exportedFilename:(NSString *)filename;
@end
