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
    MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, firstAsset.duration);
    
    
    //set where the second screen is located
    NSMutableDictionary*dict2 = [Helper videoCompositionInstructionForTrackWithTrack:secondTrack asset:secondAsset isPortraitMode:isPortraitMode isSmaller:NO];
    AVMutableVideoCompositionLayerInstruction *SecondlayerInstruction = [dict2 valueForKey:@"Instruction"];
    
    //set where the first screen is located
    NSMutableDictionary*dict1 = [Helper videoCompositionInstructionForTrackWithTrack:firstTrack asset:firstAsset isPortraitMode:isPortraitMode isSmaller:YES];
    AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [dict1 valueForKey:@"Instruction"];
    
    
    MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,nil];;
    
    
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, 60);
    
    //PortraitMode
    
    CGSize sizeOfVideo = [[Helper originalVideoSize] CGSizeValue];
    if (sizeOfVideo.height < sizeOfVideo.width) {
        sizeOfVideo = CGSizeMake(sizeOfVideo.height, sizeOfVideo.width);
    }
    //CGSizeMake([secondAsset naturalSize].height, [secondAsset naturalSize].width);//[UIScreen mainScreen].bounds.size;
    CGFloat sizeOfScreenWidth = sizeOfVideo.width;//[UIScreen mainScreen].bounds.size.width;
    CGFloat watermarkSize = 0;
    CGFloat watermarkXPosition = 0;
    CGFloat watermarkYPosition = 0;
    CGFloat textWidth = 0;
    CGFloat textHeight = 0;
    CGFloat fontSize = 0;
    CGFloat textXPosition = 0;
    CGFloat textYPosition = 0;
    if (isPortraitMode) {
        MainCompositionInst.renderSize = sizeOfVideo;//[UIScreen mainScreen].bounds.size;
        //        sizeOfVideo = [UIScreen mainScreen].bounds.size;
        watermarkSize = 200;//100;
        watermarkXPosition = 15;
        watermarkYPosition = 35;
        textWidth = 300;//150;
        textHeight = 185;//95;
        fontSize = 70;
        textXPosition = 225;//125;
        textYPosition = 35;
    } else {
        MainCompositionInst.renderSize = CGSizeMake(sizeOfScreenWidth, sizeOfScreenWidth);
        sizeOfVideo = CGSizeMake(sizeOfScreenWidth, sizeOfScreenWidth);
        watermarkSize = 150;
        watermarkXPosition = 15;
        watermarkYPosition = 15;
        textWidth = 230;
        textHeight = 130;
        fontSize = 40;
        textXPosition = 170;
        textYPosition = 15;
    }
    
    CGFloat requireSpace = watermarkXPosition + watermarkSize + textXPosition + textWidth;
    CGFloat requireVidWidth = [[dict1 valueForKey:@"RequireWidth"] floatValue];
    
    CGFloat availableSpace = sizeOfVideo.width - ((CGFloat)requireVidWidth);
    if (availableSpace < requireSpace) {
        CGFloat scale = availableSpace/requireSpace;
        //        CGFloat oldSize = watermarkSize;
        watermarkSize = watermarkSize*(scale*1.35);
        textWidth = textWidth*(scale*1.65);
        textHeight = textHeight * (scale*1.35);
        textXPosition = 25 + watermarkSize;
        //        textYPosition = (isPortraitMode == YES ? 35 : 15) - ((oldSize - watermarkSize)/2);
        fontSize = (watermarkSize*50)/170;
    }
    
    UIImage *myImage=[UIImage imageNamed:@"Watermark"];
    CALayer *layerCa = [CALayer layer];
    
    layerCa.contents = (__bridge id _Nullable)[myImage CGImage];//(__bridge id _Nullable)([self resizeImage:myImage newSize:CGSizeMake(watermarkSize, watermarkSize)]);
    layerCa.frame = CGRectMake(watermarkXPosition, watermarkYPosition, watermarkSize, watermarkSize);
    layerCa.opacity = 1.0;
    
    
    CATextLayer *layerText = [CATextLayer layer];
    layerText.string = @"Video Call \nIce Princess";
    layerText.font = (__bridge CFTypeRef)@"Billabong";
    layerText.fontSize = fontSize;
    layerText.alignmentMode = kCAAlignmentLeft;
    layerText.wrapped = YES;
    layerText.frame = CGRectMake(textXPosition, textYPosition, textWidth, textHeight);
    
    
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

+ (CGImageRef)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    CGContextDrawImage(context, newRect, imageRef);
    
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    //    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    //    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImageRef;
}

+(BOOL)isVideoPortrait:(AVURLAsset*)asset
{
    /*  var assetOrientation = UIImage.Orientation.up
     var isPortrait = false
     if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
     assetOrientation = .right
     isPortrait = true
     } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
     assetOrientation = .left
     isPortrait = true
     } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
     assetOrientation = .up
     } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
     assetOrientation = .down
     }
     return (assetOrientation, isPortrait)*/
    
    AVAssetTrack *videoAsset = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    
    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
    BOOL  isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = videoAsset.preferredTransform;
    
    if(videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0)  {
        videoAssetOrientation_= UIImageOrientationRight; isVideoAssetPortrait_ = YES;
    }
    
    if(videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0)  {
        videoAssetOrientation_ =  UIImageOrientationLeft; isVideoAssetPortrait_ = YES;
    }
    
    if(videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0)   {
        videoAssetOrientation_ =  UIImageOrientationUp;
    }
    
    if(videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;
    }
    return isVideoAssetPortrait_;
}

@end
