import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension String {
    static func randomStringWithLength(_ length: Int) -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789"
        let randomString = NSMutableString(capacity: length)
        for _ in 0 ..< length {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        return randomString as String
    }
}

@objc class Helper: NSObject {
    class func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
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
        return (assetOrientation, isPortrait)
    }

    @objc class func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset, isPortraitMode: Bool, isSmaller: Bool = false) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]

        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform: transform)

        if isPortraitMode {
            //Scaled the video to hight not width of screen
            var scaleToFitRatio = UIScreen.main.bounds.height / assetTrack.naturalSize.height
            if assetInfo.isPortrait {
                scaleToFitRatio = UIScreen.main.bounds.width / UIScreen.main.bounds.height
                scaleToFitRatio = isPortraitMode && isSmaller ? scaleToFitRatio / 4 : scaleToFitRatio
                let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
                if isPortraitMode && isSmaller {
                    let assetSize = CGSize(width: scaleToFitRatio * assetTrack.naturalSize.height, height: scaleToFitRatio * assetTrack.naturalSize.width)
                    //this puts the smaller video in the corner.
                    let translation = CGAffineTransform(translationX: UIScreen.main.bounds.width - assetSize.width - 30,
                                                        y: UIScreen.main.bounds.height - assetSize.height - 30)
                    instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(translation),
                                             at: CMTime.zero)
                } else {
                    instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor),
                                             at: CMTime.zero)
                }
            } else {
                scaleToFitRatio = isPortraitMode && isSmaller ? scaleToFitRatio / 4 : scaleToFitRatio
                let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
                var concat = assetTrack.preferredTransform.concatenating(scaleFactor)
                if assetInfo.orientation == .down {
                    let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat.pi)
                    let windowBounds = UIScreen.main.bounds
                    let yFix = assetTrack.naturalSize.height + windowBounds.height
                    let centerFix = CGAffineTransform(translationX: assetTrack.naturalSize.width, y: yFix)
                    concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
                }
                instruction.setTransform(concat, at: CMTime.zero)
            }
        } else {
            var scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.height
            if assetInfo.isPortrait {
                scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.width
                let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
                let translation = CGAffineTransform(translationX: isSmaller ? (UIScreen.main.bounds.width/2) : 0,
                                                    y: 0)
                instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(translation),
                                         at: CMTime.zero)
            } else {
                let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
                let translation = CGAffineTransform(translationX: isSmaller ? (UIScreen.main.bounds.width/2) : 0,
                                                    y: 0)
                var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(translation)
                if assetInfo.orientation == .down {
                    let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat.pi)
                    let windowBounds = UIScreen.main.bounds
                    let yFix = assetTrack.naturalSize.height + windowBounds.height
                    let centerFix = CGAffineTransform(translationX: assetTrack.naturalSize.width, y: yFix)
                    concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor).concatenating(translation)
                }
                instruction.setTransform(concat, at: CMTime.zero)
            }
        }
        return instruction
    }
}
