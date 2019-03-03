#import "AVAssetExportSession+OverlapVideos.h"
#import "Ice_Princess-Swift.h"
#import <UIKit/UIKit.h>

@implementation AVAssetExportSession (Exporter)
+ (AVAssetExportSession *) overlapVideos:(NSURL *)firstUrl
                               secondUrl:(NSURL *)secondUrl
                          isPortraitMode:(BOOL) isPortraitMode
                        exportedFilename:(NSString *)filename {
    
    AVURLAsset* firstAsset = [AVURLAsset URLAssetWithURL:firstUrl options:nil];
    AVURLAsset * secondAsset = [AVURLAsset URLAssetWithURL:secondUrl options:nil];
    
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    
    AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *firstAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration) ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    [firstAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration) ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration) ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, secondAsset.duration);
    
    
    //set where the first screen is located
    AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [Helper videoCompositionInstructionForTrackWithTrack:firstTrack asset:firstAsset isPortraitMode:isPortraitMode isSmaller:YES];
    
    //set where the second screen is located
    AVMutableVideoCompositionLayerInstruction *SecondlayerInstruction = [Helper videoCompositionInstructionForTrackWithTrack:secondTrack asset:secondAsset isPortraitMode:isPortraitMode isSmaller:NO];
    
    MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,nil];;
    
    
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, 30);
    //PortraitMode
    CGSize sizeOfVideo = [UIScreen mainScreen].bounds.size;;
    if (isPortraitMode) {
        MainCompositionInst.renderSize = [UIScreen mainScreen].bounds.size;
        sizeOfVideo = [UIScreen mainScreen].bounds.size;
    } else {
        MainCompositionInst.renderSize = CGSizeMake(350, 275);
        sizeOfVideo = CGSizeMake(350, 275);
    }
    
    UIImage *myImage=[UIImage imageNamed:@"watermark.png"];
    CALayer *layerCa = [CALayer layer];
    layerCa.contents = (id)myImage.CGImage;
    layerCa.frame = CGRectMake(15, 15, 80, 80);
    layerCa.contentsGravity = kCAGravityResizeAspect;
    layerCa.opacity = 1.0;
    
    //    layerCa.contentsScale = [[UIScreen mainScreen] scale];
    
    
    CATextLayer *layerText = [CATextLayer layer];
    layerText.string = @"Video Call Princess App";
    layerText.font = (__bridge CFTypeRef)@"font18";
    layerText.fontSize = 36;
    layerText.alignmentMode = kCAAlignmentLeft;
    layerText.wrapped = YES;
    layerText.frame = CGRectMake(sizeOfVideo.width/4, -5, 150, 100);
    
    //    layerText.contentsScale = [[UIScreen mainScreen] scale];
    
    
    CALayer *parentLayer=[CALayer layer];
    CALayer *videoLayer=[CALayer layer];
    parentLayer.frame=CGRectMake(0, 0, sizeOfVideo.width, sizeOfVideo.height);
    videoLayer.frame=CGRectMake(0, 0, sizeOfVideo.width, sizeOfVideo.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:layerCa];
    [parentLayer addSublayer:layerText];
    
    MainCompositionInst.animationTool=[AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:filename];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:myPathDocs])
    {
        [[NSFileManager defaultManager] removeItemAtPath:myPathDocs error:nil];
    }
    
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=url;
    [exporter setVideoComposition:MainCompositionInst];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    
    return exporter;
}

@end
