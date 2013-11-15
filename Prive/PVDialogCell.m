//
//  PVDialogCell.m
//  Prive
//
//  Created by Andrey Tyshlaev on 11/12/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVDialogCell.h"
#import "UIImage+Appearance.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDateFormatterCache.h"
#import "FICImageCache.h"
#import "PVAppDelegate.h"

#define TEXT_VIEW_WIDTH 135

@interface PVDialogCell()
{
    float height;
}

@property (nonatomic, weak)   NSDictionary *options;

@property (nonatomic, strong) UITextView   *textView;
@property (nonatomic, strong) UILabel      *timeLabel;
@property (nonatomic, strong) UIImageView  *imageAvatar;
@property (nonatomic, strong) UIImageView  *imageBalloon;

@end

#define kMessageTextWidth 145.0f
#define kMinHeight 100.0f

@implementation PVDialogCell
@synthesize type = _type;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textView = [UITextView new];
        self.textView.backgroundColor = UIColor.clearColor;
        self.textView.userInteractionEnabled = NO;
        self.textView.editable = NO;
        self.textView.scrollEnabled = NO;

        self.timeLabel = [UILabel new];
        self.timeLabel.backgroundColor = UIColor.clearColor;
        self.timeLabel.textColor = UIColor.whiteColor;

        [self.timeLabel setFont:[UIFont fontWithName:@"Helvetica" size:10]];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
            [self.textView setContentInset:UIEdgeInsetsMake(-5, -5, 0, 0)];
        }
        
        self.backgroundColor = UIColor.clearColor;
        
        self.imageAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 70, 70)];
        self.imageAvatar.contentMode = UIViewContentModeScaleAspectFill;
        
        self.imageBalloon = [[UIImageView alloc] initWithFrame:CGRectZero];

        [self.contentView addSubview:self.imageAvatar];
        [self.contentView addSubview:self.imageBalloon];
        [self.contentView addSubview:self.textView];
        [self.contentView addSubview:self.timeLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    self.textView.frame = CGRectZero;
    self.textView.text = @"";
    self.imageView.image = nil;
    self.imageBalloon.image = nil;
    self.timeLabel.text = @"";
}

- (void)setupCellWithType:(PVDialogCellType)typeCell andMessage:(PVManagedMessage *)message
{
    _type = typeCell;
    
    [self.textView setText:message.text];

    CGSize size = [message.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0]
                           constrainedToSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
    height = MAX(size.height, 25);

    [self.timeLabel setText:[NSDateFormatterCache stringFromDate:message.date withFormat:@"HH:mm"]];
}

- (void)setAvatar:(PVAvatar *)avatar {
    [[FICImageCache sharedImageCache] retrieveImageForEntity:avatar withFormatName:@"PVAvatarRoundImageFormatNameMedium" completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
        UIImage *borderImage = [UIImage circleImageWithHeight:72 borderColor:[UIColor colorWithRed:0.16 green:0.33 blue:0.49 alpha:1]];
        UIImage *avatarImage = [UIImage imageWithAvatar:image borderImage:borderImage withHeight:72];
        [self.imageAvatar setImage:avatarImage];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (_type == PVDialogCellSent) {
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        _imageAvatar.center = CGPointMake(40, self.frame.size.height/2);
        [_textView setFrame:CGRectMake(_imageAvatar.frame.size.width + 10.0, 10.0, 145.0, height)];
        [_textView setCenter:CGPointMake(_imageAvatar.frame.size.width + 20.0 + (TEXT_VIEW_WIDTH + 10.0)/2, self.frame.size.height/2 + 4)];
        //_imageAvatar.image = [UIImage defaultAvatarWithHeight:70.0 borderColor:[UIColor colorWithRed:45/255.0 green:114/255.0 blue:21.0/255.0 alpha:0.8]];
        if (height > 0) {
            [_imageBalloon setFrame:CGRectMake(0, 0, TEXT_VIEW_WIDTH + 10.0, height)];
            [_imageBalloon setCenter:CGPointMake(_imageAvatar.frame.size.width + 10.0 + (TEXT_VIEW_WIDTH + 10.0)/2, self.frame.size.height/2)];
            [_imageBalloon setImage:[UIImage balloonImageWithHeight:height backgroundColor:UIColor.whiteColor sent:YES]];
        }
    }else{
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        _imageAvatar.center = CGPointMake(self.frame.size.width - 40, self.frame.size.height/2);
        [_textView setFrame:CGRectMake(self.bounds.size.width - _imageAvatar.frame.size.width - 145.0 - 5.0, 10.0, 145.0, height)];
        [_textView setCenter:CGPointMake(self.bounds.size.width - _imageAvatar.frame.size.width - TEXT_VIEW_WIDTH/2 - 20.0 + 10, self.frame.size.height/2 + 4)];
        //_imageAvatar.image = [UIImage defaultAvatarWithHeight:70.0 borderColor:[UIColor colorWithRed:71/255.0 green:98/255.0 blue:115.0/255.0 alpha:0.8]];
        if (height > 0) {
            [_imageBalloon setFrame:CGRectMake(self.bounds.size.width - _imageAvatar.frame.size.width - TEXT_VIEW_WIDTH - 10.0, 10.0, 145.0, height)];
            [_imageBalloon setCenter:CGPointMake(self.bounds.size.width - _imageAvatar.frame.size.width - TEXT_VIEW_WIDTH/2 - 20.0, self.frame.size.height/2)];
            [_imageBalloon setImage:[UIImage balloonImageWithHeight:height backgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8] sent:NO]];
        }
    }
    [self.timeLabel setFrame:CGRectMake(_imageBalloon.frame.origin.x + 10.0, _imageBalloon.frame.size.height + _imageBalloon.frame.origin.y + 3.0, _imageBalloon.frame.size.width - 10.0, 10.0)];
}

@end
