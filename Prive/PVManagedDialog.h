//
//  PVDialog.h
//  Prive
//
//  Created by Ivan Doroshenko on 11/11/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SSManagedObject.h"

@class PVManagedContact, PVManagedMessage;

@interface PVManagedDialog : SSManagedObject

@property (nonatomic, retain) PVManagedContact *buddy;
@property (nonatomic, retain) NSSet *messages;
@end

@interface PVManagedDialog (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(PVManagedMessage *)value;
- (void)removeMessagesObject:(PVManagedMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
