//
//  PVBuddy.h
//  Prive
//
//  Created by Ivan Doroshenko on 11/6/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SSManagedObject.h"


@interface PVBuddy : SSManagedObject;

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * alias;
@property (nonatomic, retain) NSString * info;

@end
