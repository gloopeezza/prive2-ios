//
//  UIViewController+PVCustomBackButton.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/13/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "UIViewController+PVCustomBackButton.h"

@implementation UIViewController (PVCustomBackButton)

- (void)pv_configureBackButton {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[UIImage imageNamed:@"nav-back-button"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0.0f, 0.0f, 44.0f, 44.0f);
    [backButton setContentEdgeInsets:UIEdgeInsetsMake(-5, 0, -5, 0)];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
        fixed.width = -16.0f;
    } else {
        fixed.width = -5.0f;
    }
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItems = @[fixed, backButtonItem];
}

@end
