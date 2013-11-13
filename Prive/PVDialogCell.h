//
//  PVDialogCell.h
//  Prive
//
//  Created by Andrey Tyshlaev on 11/12/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PVManagedMessage.h"

typedef enum  {
    PVDialogCellSent,
	PVDialogCellReceived
} PVDialogCellType;

@interface PVDialogCell : UITableViewCell
{
    PVDialogCellType type;
}

@property(nonatomic) PVDialogCellType type;

- (void)setupCellWithType:(PVDialogCellType)type andMessage:(PVManagedMessage *)message;

@end