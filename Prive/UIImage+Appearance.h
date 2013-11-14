//
//  UIImage+Appearance.h
//  Prive
//
//  Created by Ivan Doroshenko on 11/11/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Appearance)

+ (UIImage *)clearImage;
+ (UIImage *)navigationBarBackgroundImage;
+ (UIImage *)tabbarBackgroundImage;
+ (UIImage *)tabbarSelectedItemBackground;
+ (UIImage *)circleImageWithHeight:(CGFloat)radius borderColor:(UIColor *)borderColor;

+ (UIImage *)balloonImageWithHeight:(CGFloat)height backgroundColor:(UIColor *)backgroundColor sent:(BOOL)sent;
+ (UIImage *)defaultAvatarWithHeight:(CGFloat)radius borderColor:(UIColor *)color;

+ (UIImage *)sendMessageButtonImage;

@end
