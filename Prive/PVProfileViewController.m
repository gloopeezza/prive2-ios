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

@interface PVProfileViewController ()
{
    PVAvatar *avatar;
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
        
        UIImage *avatarImage = [UIImage defaultAvatarWithHeight:144 borderColor:OFFLINE_COLOR];

        avatarImageView = [[UIImageView alloc] initWithImage:avatarImage];
        [avatarImageView setCenter:CGPointMake(self.view.bounds.size.width/2, 107.5)];
        [self.view insertSubview:avatarImageView belowSubview:self.textField];
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"My Privé" image:nil tag:0];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar-profile-highlighted"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar-profile-normal"]];
        self.title = @"My Privé";
        
        self.textField.text = [[PVChatManager defaultManager] profileName];
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSURL *imageURL = [mainBundle URLForResource:@"avatar_0" withExtension:@"png"];
        
        avatar = [PVAvatar new];
        [avatar setSourceImageURL:imageURL];
        
        [self reloaAvatarImage:PVManagedContactStatusOffline];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.torchatIdLabel.text = [[PVChatManager defaultManager] selfAddress];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onlineStatus:)
                                                 name:kPVChatManagerContactStatusNotificationName
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) onlineStatus:(NSNotification *) note
{
    
    PVManagedContact *contact = [note.userInfo objectForKey:kPVChatManagerContactStatusNotificationUserInfoContactKey];
    
    NSString *status = (contact.status == PVManagedContactStatusOnline) ? @"online" : @"offline";
    
    if ([contact.address isEqual:[[PVChatManager defaultManager] selfAddress]]) {
        [self reloaAvatarImage:contact.status];
    }
    
    NSLog(@"!!!! Contact %@ status updated to %@", contact.address, status);
}

- (void)reloaAvatarImage:(PVManagedContactStatus)status
{
    [[FICImageCache sharedImageCache] retrieveImageForEntity:avatar withFormatName:@"PVAvatarRoundImageFormatNameBig" completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
        UIImage *borderImage = [UIImage circleImageWithHeight:144 borderColor:status?ONLINE_COLOR_SELF:OFFLINE_COLOR];
        UIImage *avatarImage = [UIImage imageWithAvatar:image borderImage:borderImage withHeight:144];
        [avatarImageView setImage:avatarImage];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    int movement = (!up ? 277.0 : (self.view.bounds.size.height - 200.0));
    
    [UIView animateWithDuration:0.25 animations:^{
        self.textField.frame = CGRectMake(_textField.frame.origin.x, movement, _textField.frame.size.width, _textField.frame.size.height);
    }];
}
@end
