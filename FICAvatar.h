//
//  FICAvatar.h
//  testFIC
//
//  Created by Andrey Tyshlaev on 11/15/13.
//  Copyright (c) 2013 Andrey Tyshlaev. All rights reserved.
//

#import "FICEntity.h"

extern NSString *const FICAvatarImageFormatFamily;

extern NSString *const FICAvatarRoundImageFormatNameBig;
extern NSString *const FICAvatarRoundImageFormatNameMedium;
extern NSString *const FICAvatarRoundImageFormatNameSmall;

extern CGSize const FIDAvatarRoundImageSizeBig;
extern CGSize const FIDAvatarRoundImageSizeMedium;
extern CGSize const FIDAvatarRoundImageSizeSmall;

@interface FICAvatar : NSObject <FICEntity>

@property (nonatomic, copy) NSURL *sourceImageURL;
@property (nonatomic, strong, readonly) UIImage *sourceImage;

@end
