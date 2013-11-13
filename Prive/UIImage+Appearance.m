//
//  UIImage+Appearance.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/11/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "UIImage+Appearance.h"

@implementation UIImage (Appearance)

+ (UIImage *)clearImage {
    UIGraphicsBeginImageContext(CGSizeMake(3.0f, 3.0f));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] setFill];
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 3.0f, 3.0f));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRelease(context);
    
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(1.0f, 1.0f, 1.0f, 1.0f)];;
}

+ (UIImage *)tabbarBackgroundImage {
    UIGraphicsBeginImageContext(CGSizeMake(1.0f, 49.0f));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor colorWithRed:0.08f green:0.19f blue:0.34f alpha:1.0f] setFill];
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 1.0f, 49.0f));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRelease(context);
    
    return image;
}

+ (UIImage *)navigationBarBackgroundImage
{
    UIGraphicsBeginImageContext(CGSizeMake(1.0f, 44.0f));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor colorWithRed:0.0f green:0.04f blue:0.13f alpha:1.0f] setFill];
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 1.0f, 44.0f));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRelease(context);
    
    return image;
}

+ (UIImage *)tabbarSelectedItemBackground {
    UIGraphicsBeginImageContext(CGSizeMake(3.0f, 49.0f));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor colorWithWhite:0.88f alpha:1.0f] setFill];
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 3.0f, 1.0f));
    
    [[UIColor colorWithWhite:1.0f alpha:1.0f] setFill];
    CGContextFillRect(context, CGRectMake(0.0f, 1.0f, 3.0f, 48.0f));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRelease(context);
    
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f)];
}

+ (UIImage *)circleImageWithHeight:(CGFloat)radius borderColor:(UIColor *)color {
    NSParameterAssert(radius);
    NSParameterAssert(color);
    
    CGFloat width = radius;
    CGFloat lineWidth = radius / 18.0f;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, width), NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor whiteColor] setFill];
    CGRect borderRect = CGRectIntegral(CGRectMake(lineWidth/2.0f, lineWidth/2.0f, width - lineWidth, width - lineWidth));
    CGContextFillEllipseInRect(context, borderRect);
    
    [color setStroke];
    CGContextSetLineWidth(context, lineWidth);
    CGContextStrokeEllipseInRect(context, borderRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRelease(context);
    
    return image;
}

+ (UIImage *)defaultAvatarWithHeight:(CGFloat)radius borderColor:(UIColor *)color {
    NSParameterAssert(radius);
    NSParameterAssert(color);
    
    CGFloat width = radius;
    CGFloat lineWidth = radius / 18.0f;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, width), NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor whiteColor] setFill];
    CGRect borderRect = CGRectIntegral(CGRectMake(lineWidth/2.0f, lineWidth/2.0f, width - lineWidth, width - lineWidth));
    CGContextFillEllipseInRect(context, borderRect);
    
    [color setStroke];
    CGContextSetLineWidth(context, lineWidth);
    CGContextStrokeEllipseInRect(context, borderRect);
    
    UIImage *defaultAvatar = [UIImage imageNamed:@"default-avatar"];
    [defaultAvatar drawInRect:CGRectMake((radius - 38.0) / 2, (radius - 38.0) / 2, 38, 38.0)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRelease(context);
    
    return image;
}

+ (UIImage *)balloonImageWithHeight:(CGFloat)height backgroundColor:(UIColor *)backgroundColor sent:(BOOL)sent{
    NSParameterAssert(height);
    NSParameterAssert(backgroundColor);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(145, height), NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    UIBezierPath *tile = [UIBezierPath bezierPath];
    
    float x;
    if (!sent) {
        x = 0.0;
        [tile moveToPoint:CGPointMake(130, height/2)];
        [tile addCurveToPoint:CGPointMake(130+10, height/2+1) controlPoint1:CGPointMake(130+1, height/2+1) controlPoint2:CGPointMake(130+5, height/2+4)];
        [tile addCurveToPoint:CGPointMake(130-2, height/2+7) controlPoint1:CGPointMake(130+15, height/2-5) controlPoint2:CGPointMake(130+9, height/2+13)];

    }else{
        x = 8.0;
        [tile moveToPoint:CGPointMake(9, height/2+3)];
        [tile addCurveToPoint:CGPointMake(2, height/2+1) controlPoint1:CGPointMake(9, height/2+1) controlPoint2:CGPointMake(6, height/2+4)];
        [tile addCurveToPoint:CGPointMake(10, height/2+6) controlPoint1:CGPointMake(-3, height/2+-3) controlPoint2:CGPointMake(4, height/2+7)];
    }
    UIBezierPath *balloon = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, 0.0, 135.0, height) cornerRadius:height/2];
    
    [backgroundColor setFill];
    [balloon fill];
    [tile fill];

    CGContextAddPath(context, tile.CGPath);
    CGContextAddPath(context, balloon.CGPath);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRelease(context);
    return image;
}

@end
