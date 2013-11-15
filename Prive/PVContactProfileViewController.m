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
#import "FICAvatar.h"
#import "FICImageCache.h"
#import "PVAppDelegate.h"

@interface PVContactProfileViewController ()
{
    UILabel *_torAdressLabel;
    PVManagedDialog *_dialog;
    PVManagedContact *_buddy;
}
@end

@implementation PVContactProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self pv_configureBackButton];
        
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
            self.edgesForExtendedLayout = UIRectEdgeNone;
        
        UIImageView *backgroundAvatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"prive-background"]];
        backgroundAvatar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 215);

        UIImage *avatarImage = [UIImage defaultAvatarWithHeight:100 borderColor:[UIColor colorWithRed:0.16 green:0.33 blue:0.49 alpha:1]];
        UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:avatarImage];
        [avatarImageView setCenter:CGPointMake(self.view.bounds.size.width/2, 107.5)];
        
        _torAdressLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, backgroundAvatar.frame.size.height + 10.0, 280.0, 30.0)];
        _torAdressLabel.numberOfLines = 2;
        _torAdressLabel.backgroundColor = UIColor.clearColor;
        _torAdressLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        
        UIButton *sendMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sendMessageButton.frame = CGRectMake(20, backgroundAvatar.frame.size.height + _torAdressLabel.frame.size.height + 15, 280, 44);
        [sendMessageButton setTitle:NSLocalizedString(@"send_message", @"") forState:UIControlStateNormal];
        [sendMessageButton setBackgroundImage:[UIImage sendMessageButtonImage] forState:UIControlStateNormal];
        [sendMessageButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:backgroundAvatar];
        [self.view addSubview:avatarImageView];
        [self.view addSubview:_torAdressLabel];
        [self.view addSubview:sendMessageButton];
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSURL *imageURL = [mainBundle URLForResource:@"avatar_0" withExtension:@"png"];
        
        FICAvatar *avatar = [FICAvatar new];
        [avatar setSourceImageURL:imageURL];
        
        [[FICImageCache sharedImageCache] retrieveImageForEntity:avatar withFormatName:@"FICAvatarRoundImageFormatNameBig" completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
            NSLog(@"Draw");
            UIImage *borderImage = [UIImage circleImageWithHeight:144 borderColor:[UIColor colorWithRed:0.16 green:0.33 blue:0.49 alpha:1]];
            UIImage *avatarImage = [UIImage imageWithAvatar:image borderImage:borderImage withHeight:144];
            [avatarImageView setImage:avatarImage];
        }];
        
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
    _torAdressLabel.text = [NSString stringWithFormat:@"%@:\n%@",NSLocalizedString(@"torchat_id", nil),buddy.address];
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
