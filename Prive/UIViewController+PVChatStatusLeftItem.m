//
//  UIViewController+PVChatStatusLeftItem.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/16/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "UIViewController+PVChatStatusLeftItem.h"
#import "UIBarButtonItem+PVChatStatusView.h"

@implementation UIViewController (PVChatStatusLeftItem)

- (void)pv_configureChatStatusItem {
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:self.navigationItem.leftBarButtonItems];
    [items addObject:[UIBarButtonItem pv_chatStatusBarItem]];
    self.navigationItem.leftBarButtonItems = items;
}

@end
