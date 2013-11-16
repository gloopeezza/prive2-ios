//
//  PVContactProfileViewController.m
//  Prive
//
//  Created by Andrey Tyshlaev on 11/14/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVContactProfileViewController.h"
#import "UIViewController+PVCustomBackButton.h"
#import "UIImage+Appearance.h"
#import "PVDialogViewController.h"
#import "UIImage+Appearance.h"
#import "PVAvatar.h"
#import "FICImageCache.h"
#import "PVAppDelegate.h"
#import "UIViewController+PVChatStatusLeftItem.h"

@interface PVContactProfileViewController ()
{
    UILabel *_torAdress;
    UILabel *_torAdressLabel;

    PVManagedDialog *_dialog;
    PVManagedContact *_buddy;
    
    UIImageView *avatarImageView;
}
@end

@implementation PVContactProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = UIColor.whiteColor;
        [self pv_configureBackButton];
        [self pv_configureChatStatusItem];
        
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
            self.edgesForExtendedLayout = UIRectEdgeNone;
        
        UIImageView *backgroundAvatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"prive-background"]];
        backgroundAvatar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 215);

        avatarImageView = [[UIImageView alloc] initWithFrame:backgroundAvatar.frame];
        avatarImageView.contentMode = UIViewContentModeCenter;
        
        _torAdress = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 223.0, 280.0, 16.0)];
        _torAdress.numberOfLines = 1;
        _torAdress.backgroundColor = UIColor.clearColor;
        _torAdress.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
        _torAdress.textAlignment = NSTextAlignmentCenter;
        
        _torAdressLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 237.0, 280.0, 30.0)];
        _torAdressLabel.numberOfLines = 1;
        _torAdressLabel.backgroundColor = UIColor.clearColor;
        _torAdressLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:22];
        _torAdressLabel.textAlignment = NSTextAlignmentCenter;
        _torAdressLabel.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:114.0/255.0 alpha:1];
        
        UIButton *sendMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sendMessageButton.frame = CGRectMake(20, backgroundAvatar.frame.size.height + _torAdressLabel.frame.size.height + 25, 280, 44);
        [sendMessageButton setTitle:NSLocalizedString(@"send_message", @"") forState:UIControlStateNormal];
        [sendMessageButton setBackgroundImage:[UIImage sendMessageButtonImage] forState:UIControlStateNormal];
        [sendMessageButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:backgroundAvatar];
        [self.view addSubview:avatarImageView];
        [self.view addSubview:_torAdress];
        [self.view addSubview:_torAdressLabel];
        [self.view addSubview:sendMessageButton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setupControllerWithBuddy:(PVManagedContact *)buddy
{
    _buddy = buddy;
    _dialog = _buddy.dialog;
    self.title = buddy.alias;
    _torAdress.text = [NSString stringWithFormat:@"%@:\n%@",NSLocalizedString(@"torchat_id", nil),buddy.address];
    _torAdressLabel.text = [NSString stringWithFormat:@"%@",buddy.address];
    
    PVAvatar *avatar = [PVAvatar new];
    [avatar setTorchatID:buddy.address];
    
    [[FICImageCache sharedImageCache] retrieveImageForEntity:avatar withFormatName:@"PVAvatarRoundImageFormatNameBig" completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
        
        UIColor *borderColor = buddy.status?ONLINE_COLOR:OFFLINE_COLOR;
        
        UIImage *borderImage = [UIImage circleImageWithHeight:144 borderColor:borderColor];
        UIImage *avatarImage = [UIImage imageWithAvatar:image borderImage:borderImage withHeight:144];
        [avatarImageView setImage:avatarImage];
    }];
}

- (void)sendMessage {
    if (_buddy.dialog == nil) {
        _buddy.dialog = [[PVManagedDialog alloc] initWithContext:nil];
        [_buddy.dialog save];
    }
    
    PVDialogViewController *dialogController = [[PVDialogViewController alloc] initWithDialog:_buddy.dialog];
    dialogController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:dialogController animated:YES];
}
@end
