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

@implementation PVAppDelegate

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
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self applyAppearance];
    
    [[PVChatManager defaultManager] start];
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    PVDialogListViewController *chatDialogListController = [[PVDialogListViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *chatDialogsNavigationController = [[UINavigationController alloc] initWithRootViewController:chatDialogListController];
    
    PVContactsListViewController *buddyListController = [[PVContactsListViewController alloc] initWithStyle:UITableViewStylePlain];
    buddyListController.chatDialogsViewController = chatDialogListController;
    UINavigationController *buddyNavigationController = [[UINavigationController alloc] initWithRootViewController:buddyListController];
    
    PVTimelineViewController *timelineController = [[PVTimelineViewController alloc] init];
    UINavigationController *timelineNavigationController = [[UINavigationController alloc] initWithRootViewController:timelineController];
    
    PVProfileViewController *settingsController = [[PVProfileViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsController];

    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[buddyNavigationController,
                                         chatDialogsNavigationController,
                                         timelineNavigationController,
                                         settingsNavigationController];
    
    self.window.rootViewController = tabBarController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
