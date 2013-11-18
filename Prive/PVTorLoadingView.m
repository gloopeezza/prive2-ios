//
//  PVTorLoadingView.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/18/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVTorLoadingView.h"

@interface PVTorLoadingView ()

@property (nonatomic, strong) UILabel *statusLabel;

@end

@implementation PVTorLoadingView {
    UIActivityIndicatorView *_activity;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 10.0f;
        self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5];
        
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_activity startAnimating];
        [_activity sizeToFit];
        
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.statusLabel.backgroundColor = [UIColor clearColor];
        self.statusLabel.textColor = [UIColor whiteColor];
        self.statusLabel.numberOfLines = 0;
        
        [self addSubview:_activity];
        [self addSubview:self.statusLabel];
    }
    return self;
}


- (void)layoutSubviews {
    CGRect frame = self.bounds;
    CGFloat centerY = CGRectGetHeight(frame)/2.0f;
    
    CGRect rect = _activity.frame;
    rect.origin.y = centerY - CGRectGetHeight(rect)/2.0f;
    rect.origin.x = 16.0f;
    rect = CGRectIntegral(rect);
    _activity.frame = rect;
    
    CGFloat offsetX = CGRectGetWidth(_activity.bounds) + 32.0f;
    CGFloat height = 80;
    
    rect = CGRectMake(offsetX, centerY - height/2.0f, CGRectGetWidth(frame) - offsetX - 16.0f, height);
    self.statusLabel.frame = rect;
}

@end
