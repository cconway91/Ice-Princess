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
    CGSize sizeOfVideo = [UIScreen mainScreen].bounds.size;
    CGFloat sizeOfScreenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat watermarkSize = 0;
    CGFloat textWidth = 0;
    CGFloat fontSize = 0;
    if (isPortraitMode) {
        MainCompositionInst.renderSize = [UIScreen mainScreen].bounds.size;
        sizeOfVideo = [UIScreen mainScreen].bounds.size;
        watermarkSize = 100;
        textWidth = 150;
        fontSize = 36;
    } else {
        MainCompositionInst.renderSize = CGSizeMake(sizeOfScreenWidth, sizeOfScreenWidth);
        sizeOfVideo = CGSizeMake(sizeOfScreenWidth, sizeOfScreenWidth);
        watermarkSize = 40;
        textWidth = 60;
        fontSize = 18;
    }
    
    UIImage *myImage=[UIImage imageNamed:@"Watermark.png"];
    CALayer *layerCa = [CALayer layer];
    layerCa.contents = (id)myImage.CGImage;
    layerCa.frame = CGRectMake(15, 35, watermarkSize, watermarkSize);
    layerCa.opacity = 1.0;
    
    
    CATextLayer *layerText = [CATextLayer layer];
    layerText.string = @"Video Call Ice Princess";
    layerText.font = (__bridge CFTypeRef)@"Billabong";
    layerText.fontSize = fontSize;
    layerText.alignmentMode = kCAAlignmentLeft;
    layerText.wrapped = YES;
    layerText.frame = CGRectMake(watermarkSize + 20, watermarkSize/4, textWidth, 100);
        
    
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
