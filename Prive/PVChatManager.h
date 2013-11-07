//
//  PVChatManager.h
//  Prive
//
//  Created by Ivan Doroshenko on 11/6/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PVChatManager : NSObject

+ (instancetype)defaultManager;

- (NSFetchedResultsController *)createBuddiesFetchedResultController;

- (void)addBuddyWithAddress:(NSString *)address alias:(NSString *)alias info:(NSString *)info;
- (void)removeBuddyWithAddress:(NSString *)address;

- (void)startTorProxy;

@end
