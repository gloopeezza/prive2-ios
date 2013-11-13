//
//  PVSettingsViewController.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/8/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVProfileViewController.h"
#import "PVChatManager.h"
#import "UIImage+Appearance.h"

@interface PVProfileViewController ()

@property (nonatomic, weak) IBOutlet UILabel *torchatIdLabel;
@property (nonatomic, weak) IBOutlet UITextField *textField;

@end

@implementation PVProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
            self.edgesForExtendedLayout = UIRectEdgeNone;
        
        /*UIImageView *avatar = [[UIImageView alloc] initWithImage:[UIImage defaultAvatarWithHeight:100 borderColor:[UIColor colorWithRed:0.16 green:0.33 blue:0.49 alpha:1]]];
        [self.view addSubview:avatar];*/
        
        UIImage *avatarImage = [UIImage defaultAvatarWithHeight:100 borderColor:[UIColor colorWithRed:0.16 green:0.33 blue:0.49 alpha:1]];
        UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:avatarImage];
        [avatarImageView setImage:avatarImage];
        [avatarImageView setCenter:CGPointMake(self.view.bounds.size.width/2, 112.5)];
        [self.view addSubview:avatarImageView];
        
        NSLog(@"SUBVIEWS %@",[self.view subviews]);
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

- (BOOL) textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
