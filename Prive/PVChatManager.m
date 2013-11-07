//
//  PVChatManager.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/6/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVChatManager.h"
#import "PVBuddy.h"
#import "CPAConfiguration.h"
#import "CPAHiddenService.h"
#import "CPAProxyManager.h"
#import "TCCoreManager.h"
#import "TCBuddy.h"

static NSString * const kPVClientName = @"Prive iOS";
static NSString * const kPVBuddiesFetchedResultControllerCacheName = @"kPVBuddiesFetchedResultControllerCacheName";
static NSString * const kPVTorHiddenServiceDirPath = @"chat_service";
static NSInteger kPVTorHiddenServicePort = 11009;
static NSInteger kPVTorLocalServicePort = 11008;

@interface PVChatManager () <TCCoreManagerDelegate>

@end


@implementation PVChatManager {
    NSManagedObjectContext *_managedObjectContext;
    NSPersistentStoreCoordinator *_psc;
    NSManagedObjectModel *_managedModel;
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

- (NSFetchedResultsController *)createBuddiesFetchedResultController {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[PVBuddy entityName]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"alias" ascending:YES]];
    NSFetchedResultsController *result = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                             managedObjectContext:_managedObjectContext
                                                                               sectionNameKeyPath:nil
                                                                                        cacheName:kPVBuddiesFetchedResultControllerCacheName];
    NSError *error;
    [result performFetch:&error];
    NSAssert(!error, @"Error when performing fetch with newly created fetchedResultController: %@", error);
    
    return result;
}

- (id)init {
    self = [super init];
    
    if (self) {
        NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *dataStorePath = [documentsDirectoryPath stringByAppendingPathComponent:@"PVCoreDataStore.sqlite"];
        NSURL *dataStoreURL = [NSURL fileURLWithPath:dataStorePath];
        
        _managedModel = [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]]];
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedModel];
        NSError *error;
        [_psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:dataStoreURL options:nil error:&error];
        NSAssert(!error, @"Error when adding persistent store to PSC: %@", error);
        _managedObjectContext.persistentStoreCoordinator = _psc;
        
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
        self.profileName = @"Prive2 User";
        self.profileText = @"Test text";
    }
    
    return self;
}

#pragma mark - Core Data

+ (NSFetchRequest *)requestWithAddress:(NSString *)address {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[PVBuddy entityName]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"address == %@", address]];
    [request setFetchLimit:1];
    return request;
}

- (BOOL)isBuddyAlreadyExistWithAddress:(NSString *)address {
    __block NSError *error;
    __block NSInteger count;
    [_managedObjectContext performBlockAndWait:^{
        count = [_managedObjectContext countForFetchRequest:[[self class] requestWithAddress:address] error:&error];
    }];
    
    NSAssert(!error, @"Error when checking buddy already exist: %@", error);
    return count == 1;
}

- (PVBuddy *)buddyWithAddress:(NSString *)address {
    NSParameterAssert(address);
    
    __block PVBuddy *buddy;
    
    [_managedObjectContext performBlockAndWait:^{
        NSError *error;
        NSArray *results = [_managedObjectContext executeFetchRequest:[[self class] requestWithAddress:address] error:&error];
        NSAssert(!error, @"Error when fetching buddy before deletion: %@", error);
        buddy = [results lastObject];
    }];
    
    return buddy;
}

- (void)addBuddy:(NSString *)address alias:(NSString *)alias notes:(NSString *)notes {
    NSParameterAssert(address);
    
    if ([self isBuddyAlreadyExistWithAddress:address]) {
        return;
    }
    
    [_managedObjectContext performBlockAndWait:^{
        NSEntityDescription *buddyEntityDescription = [NSEntityDescription entityForName:[PVBuddy entityName] inManagedObjectContext:_managedObjectContext];
        PVBuddy *buddy = [[PVBuddy alloc] initWithEntity:buddyEntityDescription insertIntoManagedObjectContext:_managedObjectContext];
        buddy.address = address;
        buddy.alias = alias;
        buddy.info = notes;
        
        NSError *error;
        [_managedObjectContext save:&error];
        NSAssert(!error, @"Error when saving context after inserting new buddy: %@", error);
    }];
}

- (BOOL)removeBuddy:(NSString *)address {
    NSParameterAssert(address);
    
    __block NSError *error;
    
    if (![self isBuddyAlreadyExistWithAddress:address]) {
        return NO;
    }
    
    [_managedObjectContext performBlockAndWait:^{
        NSArray *results = [_managedObjectContext executeFetchRequest:[[self class] requestWithAddress:address] error:&error];
        NSAssert(!error, @"Error when fetching buddy before deletion: %@", error);
        PVBuddy *buddy = [results lastObject];
        [_managedObjectContext deleteObject:buddy];
        
        [_managedObjectContext save:&error];
    }];
    
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
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[PVBuddy entityName]];
    NSError *error;
    NSArray *managedBuddies = [_managedObjectContext executeFetchRequest:request error:&error];
    NSMutableArray *buddies = [[NSMutableArray alloc] initWithCapacity:managedBuddies.count];
    
    for (PVBuddy *managedBuddy in managedBuddies) {
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
    PVBuddy *buddy = [self buddyWithAddress:address];
    buddy.alias = alias;
    
    NSError *error;
    [_managedObjectContext save:&error];
}

- (void)setBuddy:(NSString *)address notes:(NSString *)notes {
    PVBuddy *buddy = [self buddyWithAddress:address];
    buddy.info = notes;
    
    NSError *error;
    [_managedObjectContext save:&error];
}

- (NSString *)getBuddyAlias:(NSString *)address {
    PVBuddy *buddy = [self buddyWithAddress:address];
    return buddy.alias;
}

- (NSString *)getBuddyNotes:(NSString *)address {
    PVBuddy *buddy = [self buddyWithAddress:address];
    return buddy.info;
}


#pragma mark - TCCoreManagerDelegate 

- (void)torchatManager:(TCCoreManager *)manager information:(TCInfo *)info {
    NSLog(@"Got info from torchat manager: %@", [info render]);
}

#pragma mark - Stubs

- (void)setBuddy:(NSString *)address lastProfileAvatar:(UIImage *)lastAvatar {}
- (void)setBuddy:(NSString *)address lastProfileName:(NSString *)lastName {}
- (void)setBuddy:(NSString *)address lastProfileText:(NSString *)lastText {}
- (NSString *)getBuddyLastProfileName:(NSString *)address {return nil;}
- (NSString *)getBuddyLastProfileText:(NSString *)address {return nil;}
- (UIImage *)getBuddyLastProfileAvatar:(NSString *)address {return nil;}

#pragma mark - Debug

- (void)sendMessage:(NSString *)message toBuddyWithAddress:(NSString *)address {
    [[_coreManager buddyWithAddress:address] sendMessage:message];
}



@end
