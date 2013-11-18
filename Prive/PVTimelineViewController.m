//
//  PVTimelineViewController.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/11/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVTimelineViewController.h"

@interface PVTimelineViewController ()

@end

@implementation PVTimelineViewController

- (id)init {
    self = [super init];
    
    if (self) {
        self.title = @"Timeline";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Timeline" image:nil tag:0];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar-timeline-highlighted"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar-timeline-normal"]];
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    CGRect rect = CGRectMake(0.0f, 64.0f, 320.0f, 455.0f);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    imageView.image = [UIImage imageNamed:@"timelinescreen"];
    [self.view addSubview:imageView];
}


@end
