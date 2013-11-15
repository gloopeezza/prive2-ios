//
//  PVChatManager.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/6/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVChatManager.h"
#import "CPAProxy.h"
#import "TCCoreManager.h"
#import "TCBuddy.h"
#import "SSManagedObject.h"
#import "PVManagedContact.h"
#import "PVManagedMessage.h"
#import "CPAHiddenService.h"

static NSString * const kPVClientName = @"Prive iOS";
static NSString * const kPVBuddiesFetchedResultControllerCacheName = @"kPVBuddiesFetchedResultControllerCacheName";
static NSString * const kPVTorHiddenServiceDirPath = @"chat_service";
static NSInteger kPVTorHiddenServicePort = 11009;
static NSInteger kPVTorLocalServicePort = 11008;

NSString * const kPVChatManagerContactStatusNotificationName = @"kPVChatManagerContactStatusNotificationName";
NSString * const kPVChatManagerContactStatusNotificationUserInfoContactKey = @"kPVChatManagerContactStatusNotificationUserInfoContactKey";

static NSString * const kPVClientProfileNameKey = @"kPVClientProfileNameKey";

@interface PVChatManager () <TCCoreManagerDelegate, TCBuddyDelegate>

@end


@implementation PVChatManager {
    CPAProxyManager *_proxyManager;
    NSString *_selfAddress;
    TCCoreManager *_coreManager;
}

+ (instancetype)defaultManager {
    static id defaultManger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManger = [[self alloc] init];
    });
    return defaultManger;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [SSManagedObject mainQueueContext];
        
        NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString *torrcPath = [[NSBundle mainBundle] pathForResource:@"torrc" ofType:nil];
        NSString *geoipPath = [[NSBundle mainBundle] pathForResource:@"geoip" ofType:nil];
        NSString *chatServiceDirPath = [documentsDirectoryPath stringByAppendingPathComponent:kPVTorHiddenServiceDirPath];
        CPAConfiguration *proxyConfiguration = [[CPAConfiguration alloc] initWithTorrcPath:torrcPath geoipPath:geoipPath];
        
        CPAHiddenService *chatService = [[CPAHiddenService alloc] initWithDirectoryPath:chatServiceDirPath
                                                                            virtualPort:kPVTorHiddenServicePort
                                                                             targetPort:kPVTorLocalServicePort];
        proxyConfiguration.hiddenServices = @[chatService];
        _proxyManager = [[CPAProxyManager alloc] initWithConfiguration:proxyConfiguration];
        
        // TCConfig init

        
        self.clientPort = kPVTorLocalServicePort;
        
        self.profileText = @"about me";
        
        _profileName = [[NSUserDefaults standardUserDefaults] stringForKey:kPVClientProfileNameKey];
        if (!_profileName) {
            self.profileName = @"Prive User iOS";
        }
        
    }
    
    return self;
}

- (void)setProfileName:(NSString *)profileName {
    if ([profileName isEqualToString:_profileName]) return;
    
    _profileName = profileName;
    [[NSUserDefaults standardUserDefaults] setObject:profileName forKey:kPVClientProfileNameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([self selfAddress]) {
        [self setBuddy:[self selfAddress] alias:profileName];
    }
}

#pragma mark - Core Data

+ (NSFetchRequest *)requestWithAddress:(NSString *)address {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[PVManagedContact entityName]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"address == %@", address]];
    [request setFetchLimit:1];
    return request;
}

- (BOOL)isBuddyAlreadyExistWithAddress:(NSString *)address {
    NSError *error;
    NSInteger count = [[PVManagedContact mainQueueContext] countForFetchRequest:[[self class] requestWithAddress:address] error:&error];
    
    NSAssert(!error, @"Error when checking buddy already exist: %@", error);
    return count == 1;
}

- (PVManagedContact *)buddyWithAddress:(NSString *)address {
    NSParameterAssert(address);
    
    NSError *error;
    NSArray *results = [[PVManagedContact mainQueueContext] executeFetchRequest:[[self class] requestWithAddress:address] error:&error];
    NSAssert(!error, @"Error when fetching buddy before deletion: %@", error);
    PVManagedContact *buddy = [results lastObject];
    
    return buddy;
}

- (void)addBuddy:(NSString *)address alias:(NSString *)alias notes:(NSString *)notes {
    NSParameterAssert(address);
    
    if ([self isBuddyAlreadyExistWithAddress:address]) {
        return;
    }
    
    [[PVManagedContact mainQueueContext] performBlockAndWait:^{
        PVManagedContact *buddy = [[PVManagedContact alloc] initWithContext:nil];
        buddy.address = address;
        buddy.alias = alias;
        buddy.info = notes;
        
        NSError *error;
        [buddy save];
        NSAssert(!error, @"Error when saving context after inserting new buddy: %@", error);
    }];
}

- (BOOL)removeBuddy:(NSString *)address {
    NSParameterAssert(address);
    
    NSError *error;
    
    if (![self isBuddyAlreadyExistWithAddress:address]) {
        return NO;
    }
    
    NSArray *results = [[PVManagedContact mainQueueContext] executeFetchRequest:[[self class] requestWithAddress:address] error:&error];
    NSAssert(!error, @"Error when fetching buddy before deletion: %@", error);
    PVManagedContact *buddy = [results lastObject];
    [buddy delete];
    [[PVManagedContact mainQueueContext] save:nil];
    
    NSAssert(!error, @"Error when saving context after buddy deletion: %@", error);
    
    if (error) return NO;
    return YES;
}

- (BOOL)removeDialog:(PVManagedDialog *)dialog {
    NSParameterAssert(dialog);
    
    NSError *error;
    [dialog delete];
    [[PVManagedContact mainQueueContext] save:nil];
    
    NSAssert(!error, @"Error when saving context after buddy deletion: %@", error);
    
    if (error) return NO;
    return YES;
}

#pragma mark - Tor proxy

- (void)start {
    [self startTorProxy];
}

- (void)startTorProxy {
    __weak id __weak__self = self;
    [_proxyManager setupWithSuccess:^(NSString *socksHost, NSUInteger socksPort) {
        NSLog(@"Tor proxy successfully started at %@:%d",socksHost, socksPort);
        NSLog(@"Hidden service address: %@", [self selfAddress]);
        [__weak__self performSelector:@selector(startCoreChat) withObject:__weak__self afterDelay:20.0f];
    } failure:^(NSError *error) {
        NSLog(@"Tor start failure: %@", error);
    }];
}

- (void)startCoreChat {
    if (!_coreManager) {
        __weak id __weak__self = self;
        _coreManager = [[TCCoreManager alloc] initWithConfiguration:__weak__self];
        _coreManager.delegate = __weak__self;
    }
    [_coreManager start];
}

- (NSString *)selfAddress {
    if (!_selfAddress) {
        NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *chatServiceDirPath = [documentsDirectoryPath stringByAppendingPathComponent:kPVTorHiddenServiceDirPath];
        NSString *hostNameFilePath = [chatServiceDirPath stringByAppendingPathComponent:@"hostname"];
        
        NSError *error;
        NSString *onionAddress = [NSString stringWithContentsOfFile:hostNameFilePath encoding:NSASCIIStringEncoding error:&error];
        if (error) return nil;
        
        _selfAddress = [onionAddress stringByDeletingPathExtension];
    }
    return _selfAddress;
}

#pragma mark - TCConfig

- (NSString *)torAddress {
    return _proxyManager.SOCKSHost;
}

- (NSInteger)torPort {
    return _proxyManager.SOCKSPort;
}

- (NSString *)clientName:(tc_config_get)get {
    return kPVClientName;
}

- (NSArray *)buddies {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[PVManagedContact entityName]];
    NSError *error;
    NSArray *managedBuddies = [[PVManagedContact mainQueueContext] executeFetchRequest:request error:&error];
    NSMutableArray *buddies = [[NSMutableArray alloc] initWithCapacity:managedBuddies.count];
    
    for (PVManagedContact *managedBuddy in managedBuddies) {
       NSDictionary *buddy = @{TCConfigBuddyAddress: managedBuddy.address,
                               TCConfigBuddyAlias: managedBuddy.alias ?: @"",
                               TCConfigBuddyNotes: managedBuddy.info ?: @""};
        
        
        [buddies addObject:buddy];
    }
    
    return buddies;
}

- (NSString *)clientVersion:(tc_config_get)get {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (NSString *)localized:(NSString *)key
{
	NSString *local = nil;
	if (!key) {
		return @"";
    }
    
	local = NSLocalizedString(key, @"");
	
	if ([local length] == 0) {
		return key;
    }
	
	return local;
}

- (void)setBuddy:(NSString *)address alias:(NSString *)alias {
    PVManagedContact *buddy = [self buddyWithAddress:address];
    buddy.alias = alias;
    [buddy save];
}

- (void)setBuddy:(NSString *)address notes:(NSString *)notes {
    PVManagedContact *buddy = [self buddyWithAddress:address];
    buddy.info = notes;
    [buddy save];
}

- (NSString *)getBuddyAlias:(NSString *)address {
    PVManagedContact *buddy = [self buddyWithAddress:address];
    return buddy.alias;
}

- (NSString *)getBuddyNotes:(NSString *)address {
    PVManagedContact *buddy = [self buddyWithAddress:address];
    return buddy.info;
}


#pragma mark - TCCoreManagerDelegate 

- (void)torchatManager:(TCCoreManager *)manager information:(TCInfo *)info {
    NSLog(@"Got info from torchat manager: %@", [info render]);
    
    if (info.infoCode == tccore_notify_buddy_new) {
        TCBuddy *buddy = info.context;
        buddy.delegate = self;
    }
    
}

#pragma mark - TCBuddyDelegate

- (void)buddy:(TCBuddy *)buddy event:(const TCInfo *)info {
    PVManagedContact *pvBuddy = [self buddyWithAddress:buddy.address];
    if (!pvBuddy) {
        NSLog(@"*** Got buddy event %@, but PVManagedContact is nil for that buddy", [info render]);
    }
    
    if (info.infoCode == tcbuddy_notify_message) {
        NSString *messageText = info.context;
        
        [[PVManagedMessage mainQueueContext] performBlockAndWait:^{
            if (pvBuddy.dialog == nil) {
                pvBuddy.dialog = [[PVManagedDialog alloc] initWithContext:nil];
            }
        
            PVManagedMessage *managedMessage = [[PVManagedMessage alloc] initWithContext:nil];
            managedMessage.text = messageText;
            managedMessage.date = [NSDate date];
            managedMessage.dialog = pvBuddy.dialog;
            managedMessage.fromAddress = pvBuddy.address;
            [managedMessage save];
        }];
    }
    
    if (info.infoCode == tcbuddy_notify_identified) { // Online
        NSDictionary *userInfo = @{kPVChatManagerContactStatusNotificationUserInfoContactKey: pvBuddy};
        
        pvBuddy.status = PVManagedContactStatusOnline;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kPVChatManagerContactStatusNotificationName
                                                            object:self
                                                          userInfo:userInfo];
    }
    
    if (info.infoCode == tcbuddy_notify_disconnected) { // Offline
        NSDictionary *userInfo = @{kPVChatManagerContactStatusNotificationUserInfoContactKey: pvBuddy};
        
        pvBuddy.status = PVManagedContactStatusOffline;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kPVChatManagerContactStatusNotificationName
                                                            object:self
                                                          userInfo:userInfo];
    }
}

#pragma mark - Stubs

- (void)setBuddy:(NSString *)address lastProfileAvatar:(UIImage *)lastAvatar {}
- (void)setBuddy:(NSString *)address lastProfileName:(NSString *)lastName {
    PVManagedContact *contact = [self buddyWithAddress:address];
    
    [[PVManagedContact mainQueueContext] performBlockAndWait:^{
        contact.alias = lastName;
        [contact save];
    }];
}

- (void)setBuddy:(NSString *)address lastProfileText:(NSString *)lastText {}
- (NSString *)getBuddyLastProfileName:(NSString *)address {return nil;}
- (NSString *)getBuddyLastProfileText:(NSString *)address {return nil;}
- (UIImage *)getBuddyLastProfileAvatar:(NSString *)address {return nil;}

#pragma mark - Debug

- (void)sendMessage:(NSString *)message toBuddyWithAddress:(NSString *)address {
    [[_coreManager buddyWithAddress:address] sendMessage:message];
}



@end
