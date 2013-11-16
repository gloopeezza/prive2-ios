//
//  PVAppDelegate.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/6/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVAppDelegate.h"

#import "UIImage+Appearance.h"

#import "PVChatManager.h"
#import "PVContactsListViewController.h"
#import "PVProfileViewController.h"
#import "PVDialogListViewController.h"
#import "PVTimelineViewController.h"
#import "PVIntroViewController.h"

#import "PVManagedContact.h"

#import "FICImageCache.h"
#import "PVAvatar.h"

@interface PVAppDelegate () <FICImageCacheDelegate>

@end

@implementation PVAppDelegate {
    UITabBarController *_tabBarController;
    PVIntroViewController *_introViewController;
}

- (void)applyAppearance {
    UITabBar *tabBar = [UITabBar appearance];
    [tabBar setBackgroundImage:[UIImage tabbarBackgroundImage]];
    [tabBar setSelectionIndicatorImage:[UIImage tabbarSelectedItemBackground]];
    [tabBar setShadowImage:[UIImage clearImage]];

    UITabBarItem *tabBarItem = [UITabBarItem appearance];
    [tabBarItem setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor blackColor],
                                         UITextAttributeFont: [UIFont systemFontOfSize:10.0f]} forState:UIControlStateSelected];
    [tabBarItem setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor whiteColor],
                                         UITextAttributeFont: [UIFont systemFontOfSize:10.0f]} forState:UIControlStateNormal];
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],UITextAttributeTextColor, nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
}

- (void)configureFIC {
    NSInteger squareImageFormatMaximumCount = 400;
    FICImageFormatDevices squareImageFormatDevices = FICImageFormatDevicePhone | FICImageFormatDevicePad;
    
    FICImageFormat *roundAvatarBig = [FICImageFormat formatWithName:PVAvatarRoundImageFormatNameBig
                                                             family:PVAvatarImageFormatFamily
                                                          imageSize:FIDAvatarRoundImageSizeBig
                                                              style:FICImageFormatStyle32BitBGRA
                                                       maximumCount:squareImageFormatMaximumCount
                                                            devices:squareImageFormatDevices];
    
    FICImageFormat *roundAvatarMedium = [FICImageFormat formatWithName:PVAvatarRoundImageFormatNameMedium
                                                                family:PVAvatarImageFormatFamily
                                                             imageSize:FIDAvatarRoundImageSizeMedium
                                                                 style:FICImageFormatStyle32BitBGRA
                                                          maximumCount:squareImageFormatMaximumCount
                                                               devices:squareImageFormatDevices];
    
    FICImageFormat *roundAvatarSmall = [FICImageFormat formatWithName:PVAvatarRoundImageFormatNameSmall
                                                               family:PVAvatarImageFormatFamily
                                                            imageSize:FIDAvatarRoundImageSizeSmall
                                                                style:FICImageFormatStyle32BitBGRA
                                                         maximumCount:squareImageFormatMaximumCount
                                                              devices:squareImageFormatDevices];
    
    NSArray *mutableImageFormats = @[roundAvatarBig, roundAvatarMedium, roundAvatarSmall];
    
    FICImageCache *sharedImageCache = [FICImageCache sharedImageCache];
    [sharedImageCache setDelegate:self];
    [sharedImageCache setFormats:mutableImageFormats];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    sleep(1);
    [self applyAppearance];
    [self configureFIC];
    
    [[PVChatManager defaultManager] start];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    PVDialogListViewController *chatDialogListController = [[PVDialogListViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *chatDialogsNavigationController = [[UINavigationController alloc] initWithRootViewController:chatDialogListController];
    [chatDialogsNavigationController.navigationBar setBackgroundImage:[UIImage navigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
    
    PVContactsListViewController *buddyListController = [[PVContactsListViewController alloc] initWithStyle:UITableViewStylePlain];
    buddyListController.chatDialogsViewController = chatDialogListController;
    UINavigationController *buddyNavigationController = [[UINavigationController alloc] initWithRootViewController:buddyListController];
    [buddyNavigationController.navigationBar setBackgroundImage:[UIImage navigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];

    PVTimelineViewController *timelineController = [[PVTimelineViewController alloc] init];
    UINavigationController *timelineNavigationController = [[UINavigationController alloc] initWithRootViewController:timelineController];
    [timelineNavigationController.navigationBar setBackgroundImage:[UIImage navigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];

    PVProfileViewController *settingsController = [[PVProfileViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsController];
    [settingsNavigationController.navigationBar setBackgroundImage:[UIImage navigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];

    _tabBarController = [[UITabBarController alloc] init];
    _tabBarController.viewControllers = @[buddyNavigationController,
                                         chatDialogsNavigationController,
                                         timelineNavigationController,
                                         settingsNavigationController];
    
    self.window.rootViewController = _tabBarController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    /*[[NSNotificationCenter defaultCenter] addObserverForName:kPVChatManagerContactStatusNotificationName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        PVManagedContact *contact = [note.userInfo objectForKey:kPVChatManagerContactStatusNotificationUserInfoContactKey];
        
        NSString *status = (contact.status == PVManagedContactStatusOnline) ? @"online" : @"offline";
        
        NSLog(@"*** Contact %@ status updated to %@", contact.address, status);
    }];*/
    
    return YES;
}

#pragma mark - FICImageCacheDelegate

- (void)imageCache:(FICImageCache *)imageCache wantsSourceImageForEntity:(id<FICEntity>)entity withFormatName:(NSString *)formatName completionBlock:(FICImageRequestCompletionBlock)completionBlock {
    // Images typically come from the Internet rather than from the app bundle directly, so this would be the place to fire off a network request to download the image.
    // For the purposes of this demo app, we'll just access images stored locally on disk.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *sourceImage = [(PVAvatar *)entity sourceImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(sourceImage);
        });
    });
}

- (BOOL)imageCache:(FICImageCache *)imageCache shouldProcessAllFormatsInFamily:(NSString *)formatFamily forEntity:(id<FICEntity>)entity {
    BOOL shouldProcessAllFormats = [formatFamily isEqualToString:PVAvatarImageFormatFamily];
    
    return shouldProcessAllFormats;
}

- (void)imageCache:(FICImageCache *)imageCache errorDidOccurWithMessage:(NSString *)errorMessage {
    NSLog(@"%@", errorMessage);
}

@end
