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

@end
