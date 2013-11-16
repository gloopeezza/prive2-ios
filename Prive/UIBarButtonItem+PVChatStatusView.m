//
//  UIBarButtonItem+PVChatStatusView.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/16/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "UIBarButtonItem+PVChatStatusView.h"
#import "PVChatStatusView.h"

@implementation UIBarButtonItem (PVChatStatusView)

+ (UIBarButtonItem *)pv_chatStatusBarItem {
    PVChatStatusView *customView = [[PVChatStatusView alloc] initWithFrame:CGRectZero];
    [customView sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:customView];
    return item;
}

@end
