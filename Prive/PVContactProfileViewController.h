//
//  PVContactProfileViewController.h
//  Prive
//
//  Created by Andrey Tyshlaev on 11/14/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PVManagedDialog.h"
#import "PVManagedContact.h"

@interface PVContactProfileViewController : UIViewController

- (void)setupControllerWithBuddy:(PVManagedContact *)buddy;
@end
