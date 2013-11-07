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

static NSString * const kPVBuddiesFetchedResultControllerCacheName = @"kPVBuddiesFetchedResultControllerCacheName";

@implementation PVChatManager {
    NSManagedObjectContext *_managedObjectContext;
    NSPersistentStoreCoordinator *_psc;
    NSManagedObjectModel *_managedModel;
    CPAProxyManager *_proxyManager;
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
        NSString *chatServiceDirPath = [documentsDirectoryPath stringByAppendingPathComponent:@"/chat_service/"];
        CPAConfiguration *proxyConfiguration = [[CPAConfiguration alloc] initWithTorrcPath:torrcPath geoipPath:geoipPath];
        
        CPAHiddenService *chatService = [[CPAHiddenService alloc] initWithDirectoryPath:chatServiceDirPath
                                                                            virtualPort:11009
                                                                             targetPort:11009];
        proxyConfiguration.hiddenServices = @[chatService];
        _proxyManager = [[CPAProxyManager alloc] initWithConfiguration:proxyConfiguration];
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
    NSError *error;
    NSInteger count = [_managedObjectContext countForFetchRequest:[[self class] requestWithAddress:address] error:&error];
    NSAssert(!error, @"Error when checking buddy already exist: %@", error);
    return count == 1;
}

- (void)addBuddyWithAddress:(NSString *)address alias:(NSString *)alias info:(NSString *)info {
    NSParameterAssert(address);
    if ([self isBuddyAlreadyExistWithAddress:address]) {
        return;
    }
    
    NSEntityDescription *buddyEntityDescription = [NSEntityDescription entityForName:[PVBuddy entityName] inManagedObjectContext:_managedObjectContext];
    PVBuddy *buddy = [[PVBuddy alloc] initWithEntity:buddyEntityDescription insertIntoManagedObjectContext:_managedObjectContext];
    buddy.address = address;
    buddy.alias = alias;
    buddy.info = info;
    
    NSError *error;
    [_managedObjectContext save:&error];
    NSAssert(!error, @"Error when saving context after inserting new buddy: %@", error);
}

- (void)removeBuddyWithAddress:(NSString *)address {
    NSParameterAssert(address);
    if (![self isBuddyAlreadyExistWithAddress:address]) {
        return;
    }
    
    NSError *error;
    NSArray *results = [_managedObjectContext executeFetchRequest:[[self class] requestWithAddress:address] error:&error];
    NSAssert(!error, @"Error when fetching buddy before deletion: %@", error);
    PVBuddy *buddy = [results lastObject];
    [_managedObjectContext deleteObject:buddy];
    
    [_managedObjectContext save:&error];
    NSAssert(!error, @"Error when saving context after buddy deletion: %@", error);
}

#pragma mark - Tor proxy

- (void)createChatServiceDirIfNeeded {

}

- (void)startTorProxy {
    [_proxyManager setupWithSuccess:^(NSString *socksHost, NSUInteger socksPort) {
        NSLog(@"Tor started at host:port %@:%d",socksHost, socksPort);
    } failure:^(NSError *error) {
        NSLog(@"Tor start failure: %@", error);
    }];
}

@end
