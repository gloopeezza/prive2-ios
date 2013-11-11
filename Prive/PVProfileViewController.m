//
//  PVSettingsViewController.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/8/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVProfileViewController.h"
#import "PVChatManager.h"

@interface PVProfileViewController ()

@property (nonatomic, weak) IBOutlet UILabel *torchatIdLabel;
@property (nonatomic, weak) IBOutlet UITextField *textField;

@end

@implementation PVProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"My Privé" image:nil tag:0];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar-profile-highlighted"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar-profile-normal"]];
        self.title = @"My Privé";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.torchatIdLabel.text = [[PVChatManager defaultManager] selfAddress];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
