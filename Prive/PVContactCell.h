//
//  PVContactCell.h
//  Prive
//
//  Created by Ivan Doroshenko on 11/11/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FICAvatar.h"

@interface PVContactCell : UITableViewCell

@property (nonatomic, assign, getter = isOnline) BOOL online;

- (void)setAvatar:(FICAvatar *)avatar;

@end
