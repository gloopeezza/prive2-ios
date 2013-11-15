//
//  FICAvatar.m
//  testFIC
//
//  Created by Andrey Tyshlaev on 11/15/13.
//  Copyright (c) 2013 Andrey Tyshlaev. All rights reserved.
//

#import "FICAvatar.h"
#import "FICUtilities.h"

NSString *const FICAvatarImageFormatFamily = @"FICAvatarImageFormatFamily";

NSString *const FICAvatarRoundImageFormatNameBig = @"FICAvatarRoundImageFormatNameBig";
NSString *const FICAvatarRoundImageFormatNameMedium = @"FICAvatarRoundImageFormatNameMedium";
NSString *const FICAvatarRoundImageFormatNameSmall = @"FICAvatarRoundImageFormatNameSmall";

CGSize const FIDAvatarRoundImageSizeBig    = {128, 128};
CGSize const FIDAvatarRoundImageSizeMedium = {68, 68};
CGSize const FIDAvatarRoundImageSizeSmall  = {32, 32};

@interface FICAvatar () {
    NSURL *_sourceImageURL;
    NSString *_UUID;
}

@end

@implementation FICAvatar

#pragma mark - Protocol Implementations

@synthesize sourceImageURL = _sourceImageURL;

#pragma mark - Property Accessors

- (UIImage *)sourceImage {
    UIImage *sourceImage = [UIImage imageWithContentsOfFile:[_sourceImageURL path]];
    
    return sourceImage;
}

static UIImage * _FICDSquareImageFromImage(UIImage *image) {
    UIImage *squareImage = nil;
    CGSize imageSize = [image size];
    
    if (imageSize.width == imageSize.height) {
        squareImage = image;
    } else {
        // Compute square crop rect
        CGFloat smallerDimension = MIN(imageSize.width, imageSize.height);
        CGRect cropRect = CGRectMake(0, 0, smallerDimension, smallerDimension);
        
        // Center the crop rect either vertically or horizontally, depending on which dimension is smaller
        if (imageSize.width <= imageSize.height) {
            cropRect.origin = CGPointMake(0, rintf((imageSize.height - smallerDimension) / 2.0));
        } else {
            cropRect.origin = CGPointMake(rintf((imageSize.width - smallerDimension) / 2.0), 0);
        }
        
        CGImageRef croppedImageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
        squareImage = [UIImage imageWithCGImage:croppedImageRef];
        CGImageRelease(croppedImageRef);
    }
    
    return squareImage;
}

#pragma mark - FICImageCacheEntity

- (NSString *)UUID {
    if (_UUID == nil) {
        CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString([_sourceImageURL absoluteString]);
        _UUID = FICStringWithUUIDBytes(UUIDBytes);
    }
    return _UUID;
}

- (NSString *)sourceImageUUID {
    return [self UUID];
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName {
    return _sourceImageURL;
}

- (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image withFormatName:(NSString *)formatName {
    FICEntityImageDrawingBlock drawingBlock = ^(CGContextRef contextRef, CGSize contextSize) {
        CGRect contextBounds = CGRectZero;
        contextBounds.size = contextSize;
        CGContextClearRect(contextRef, contextBounds);
        
            /*if ([formatName isEqualToString:FICDPhotoSquareImage32BitBGRAFormatName] == NO) {
                CGContextSetFillColorWithColor(contextRef, [[UIColor whiteColor] CGColor]);
                CGContextFillRect(contextRef, contextBounds);
            }*/
            
            UIImage *squareImage = _FICDSquareImageFromImage(image);
        
            CGContextBeginPath(contextRef);
            CGRect pathRect = CGRectMake(0, 0, contextSize.width, contextSize.height);
            CGContextAddEllipseInRect(contextRef, pathRect);
            CGContextClosePath(contextRef);
            CGContextClip(contextRef);
        
            UIGraphicsPushContext(contextRef);
            [squareImage drawInRect:contextBounds];
            UIGraphicsPopContext();
    };
    
    return drawingBlock;
}

@end
