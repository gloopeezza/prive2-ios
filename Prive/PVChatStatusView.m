//
//  PVChatStatusView.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/16/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVChatStatusView.h"
#import "PVChatManager.h"

@implementation PVChatStatusView {
    UIActivityIndicatorView *_activity;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activity.hidesWhenStopped = YES;
        [self updateActivity];
        [self addSubview:_activity];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didConnectedToTor:)
                                                     name:kPVChatManagerDidConnectedNotificationName object:nil];
    }
    return self;
}

- (void)updateActivity {
    if ([[PVChatManager defaultManager] connectedToTor]) {
        [_activity stopAnimating];
    } else {
        [_activity startAnimating];
    }
}

- (void)didConnectedToTor:(NSNotification *)note {
    [self updateActivity];
}

- (void)sizeToFit {
    [_activity sizeToFit];
    CGRect frame = self.frame;
    frame.size = _activity.frame.size;
    self.frame = frame;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
