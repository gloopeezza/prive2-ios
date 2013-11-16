//
//  PVAvatar.h
//  testFIC
//
//  Created by Andrey Tyshlaev on 11/15/13.
//  Copyright (c) 2013 Andrey Tyshlaev. All rights reserved.
//

#import "FICEntity.h"

extern NSString *const PVAvatarImageFormatFamily;

extern NSString *const PVAvatarRoundImageFormatNameBig;
extern NSString *const PVAvatarRoundImageFormatNameMedium;
extern NSString *const PVAvatarRoundImageFormatNameSmall;

extern CGSize const FIDAvatarRoundImageSizeBig;
extern CGSize const FIDAvatarRoundImageSizeMedium;
extern CGSize const FIDAvatarRoundImageSizeSmall;

@interface PVAvatar : NSObject <FICEntity>

@property (nonatomic, copy) NSURL *sourceImageURL;
@property (nonatomic, copy) NSString *torchatID;
@property (nonatomic, strong, readonly) UIImage *sourceImage;

@end
