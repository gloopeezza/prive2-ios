//
//  PVIntroViewController.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/11/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVIntroViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PVIntroViewController ()

@end

@implementation PVIntroViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *moviePath = [[NSBundle mainBundle] pathForResource:@"someMovie" ofType:@"m4v"];
    
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:moviePath]];
    player.repeatMode = MPMovieRepeatModeOne;
    player.view.frame = self.view.bounds;
    
    [self.view addSubview:player.view];
    [player play];
}


@end
