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
#import "PVAvatar.h"
#import "FICImageCache.h"
#import "PVAppDelegate.h"
#import "PVManagedContact.h"
#import "UIViewController+PVChatStatusLeftItem.h"
@interface PVProfileViewController ()
{
    PVAvatar *avatar;
    UIImageView *statusImageView;
    UIImageView *avatarImageView;
}

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
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"My Privé" image:nil tag:0];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar-profile-highlighted"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar-profile-normal"]];
        self.title = @"My Privé";
        
        [self pv_configureChatStatusItem];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didConnectedToTor:)
                                                 name:kPVChatManagerDidConnectedNotificationName object:nil];
    
    statusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 144.0)];
    statusImageView.contentMode = UIViewContentModeCenter;
    [statusImageView setCenter:CGPointMake(self.view.bounds.size.width/2, 107.5)];
    [self.view addSubview:statusImageView];

    avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 144.0)];
    avatarImageView.contentMode = UIViewContentModeCenter;
    [avatarImageView setCenter:CGPointMake(self.view.bounds.size.width/2, 107.5)];
    [self.view addSubview:avatarImageView];
    
    avatar = [PVAvatar new];
    [avatar setTorchatID:[[PVChatManager defaultManager] selfAddress]];
    
    [[FICImageCache sharedImageCache] retrieveImageForEntity:avatar withFormatName:@"PVAvatarRoundImageFormatNameBig" completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
        [avatarImageView setImage:image];
    }];
    
    self.textField.text = [[PVChatManager defaultManager] profileName];
    [_textField setBackground:[UIImage whiteImage]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateStatusImage];
    self.torchatIdLabel.text = [[PVChatManager defaultManager] selfAddress];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didConnectedToTor:(NSNotification *)note {
    [self updateStatusImage];
}

- (void)updateStatusImage
{
    UIImage *borderImage = [UIImage circleImageWithHeight:144 borderColor:[[PVChatManager defaultManager] connectedToTor]?ONLINE_COLOR_SELF:OFFLINE_COLOR];
    [statusImageView setImage:borderImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (!textField.text || [textField.text isEqualToString:@""]) return;
    NSString *newProfileName = textField.text;
    [[PVChatManager defaultManager] setProfileName:newProfileName];
    [self animateTextField: textField up: NO];

}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up {
    int movement = (!up ? 44.0 : - 100.0);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(0, movement, self.view.frame.size.width, self.view.frame.size.height);
        //self.textField.frame = CGRectMake(_textField.frame.origin.x, movement, _textField.frame.size.width, _textField.frame.size.height);
    }];
}
@end
