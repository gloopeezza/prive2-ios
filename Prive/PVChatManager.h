//
//  PVChatManager.h
//  Prive
//
//  Created by Ivan Doroshenko on 11/6/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "TCConfig.h"

#import "PVManagedDialog.h"

extern NSString * const kPVChatManagerContactStatusNotificationName;
extern NSString * const kPVChatManagerContactStatusNotificationUserInfoContactKey;

extern NSString * const kPVChatManagerDidConnectedNotificationName;

@interface PVChatManager : NSObject<TCConfig>

+ (instancetype)defaultManager;

- (void)start;

@property (nonatomic, strong) NSString *selfAddress;

// TCConfig Protocol

@property (nonatomic, strong) NSString *torAddress;
@property (nonatomic, assign) NSInteger torPort;
@property (nonatomic, strong) NSString *torPath;
@property (nonatomic, strong) NSString *torDataPath;
@property (nonatomic, strong) NSString *downloadFolder;
@property (nonatomic, assign) NSInteger clientPort;
@property (nonatomic, strong) NSString *profileName;
@property (nonatomic, strong) NSString *profileText;
@property (nonatomic, strong) UIImage *profileAvatar;
@property (nonatomic, strong) NSArray *buddies;
@property (nonatomic, strong) NSArray *blockedBuddies;
@property (nonatomic, assign) tc_config_title modeTitle;

@property (nonatomic, assign, readonly) BOOL connectedToTor;

- (NSArray *)buddies;
- (void)addBuddy:(NSString *)address alias:(NSString *)alias notes:(NSString *)notes;
- (BOOL)removeBuddy:(NSString *)address;
- (BOOL)removeDialog:(PVManagedDialog *)dialog;

- (void)setBuddy:(NSString *)address alias:(NSString *)alias;
- (void)setBuddy:(NSString *)address notes:(NSString *)notes;
- (void)setBuddy:(NSString *)address lastProfileName:(NSString *)lastName;
- (void)setBuddy:(NSString *)address lastProfileText:(NSString *)lastText;
- (void)setBuddy:(NSString *)address lastProfileAvatar:(UIImage *)lastAvatar;

- (NSString *)getBuddyAlias:(NSString *)address;
- (NSString *)getBuddyNotes:(NSString *)address;
- (NSString *)getBuddyLastProfileName:(NSString *)address;
- (NSString *)getBuddyLastProfileText:(NSString *)address;
- (UIImage *)getBuddyLastProfileAvatar:(NSString *)address;

- (NSArray *)blockedBuddies;
- (BOOL)addBlockedBuddy:(NSString *)address;
- (BOOL)removeBlockedBuddy:(NSString *)address;

- (NSString *)clientVersion:(tc_config_get)get;
- (void)setClientVersion:(NSString *)version;

- (NSString *)clientName:(tc_config_get)get;
- (void)setClientName:(NSString *)name;

- (NSString *)realPath:(NSString *)path;
- (NSString *)localized:(NSString *)key;

// Debug

- (void)sendMessage:(NSString *)message toBuddyWithAddress:(NSString *)address;

@end
