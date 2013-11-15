//
//  PVContactCell.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/11/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVContactCell.h"
#import "UIImage+Appearance.h"
#import "FICImageCache.h"
#import "PVAppDelegate.h"

@interface PVContactCell ()

@property (nonatomic, weak) UIImageView *borderImageView;
@property (nonatomic, weak) UIImageView *avatarImageView;

@end

@implementation PVContactCell

+ (UIImage *)onlineBorder {
    static dispatch_once_t onceToken;
    static UIImage *_border;
    dispatch_once(&onceToken, ^{
        //UIColor *color = [UIColor colorWithRed:0.71f green:0.86f blue:0.75f alpha:1.0f];
        _border = [UIImage circleImageWithHeight:37.0f borderColor:ONLINE_COLOR];
    });
    
    return _border;
}

+ (UIImage *)offlineBorder {
    static dispatch_once_t onceToken;
    static UIImage *_border;
    dispatch_once(&onceToken, ^{
        //UIColor *color = [UIColor colorWithRed:0.93f green:0.68f blue:0.65f alpha:1.0f];
        _border = [UIImage circleImageWithHeight:37.0f borderColor:OFFLINE_COLOR];
    });
    
    return _border;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.borderImageView];
        [self.contentView addSubview:self.avatarImageView];

    }
    return self;
}

- (UIImageView *)borderImageView {
    if (_borderImageView) return _borderImageView;
    UIImageView *borderImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _borderImageView = borderImageView;
    return borderImageView;
}

- (UIImageView *)avatarImageView {
    if (_avatarImageView) return _avatarImageView;
    UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _avatarImageView = avatarImageView;
    return avatarImageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = CGRectMake(5.0f, 4.0f, 37.0f, 37.0f);
    self.borderImageView.frame = frame;
    
    frame = CGRectMake(9.0f, 8.0f, 29.0f, 29.0f);
    self.imageView.frame = frame;
    
    frame = self.textLabel.frame;
    frame.origin.x = 60.0f;
    self.textLabel.frame = frame;
    
    frame = self.detailTextLabel.frame;
    frame.origin.x = 60.0f;
    self.detailTextLabel.frame = frame;
    
    frame = CGRectMake(7.0f, 6.0f, 33.0f, 33.0f);
    self.avatarImageView.frame = frame;
}

- (void)setOnline:(BOOL)online {
    _online = online;
    
    if (_online) {
        self.borderImageView.image = [[self class] onlineBorder];
    } else {
        self.borderImageView.image = [[self class] offlineBorder];
    }
    [_borderImageView.layer addAnimation:[CATransition animation] forKey:kCATransition];
}

- (void)setAvatar:(PVAvatar *)avatar {
    [[FICImageCache sharedImageCache] retrieveImageForEntity:avatar withFormatName:@"PVAvatarRoundImageFormatNameSmall" completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
        [self.avatarImageView setImage:image];
    }];
}

@end
