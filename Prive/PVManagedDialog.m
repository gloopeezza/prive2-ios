//
//  PVDialog.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/11/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVManagedDialog.h"
#import "PVManagedContact.h"
#import "PVManagedMessage.h"
#import "PVChatManager.h"

@implementation PVManagedDialog

@dynamic buddy;
@dynamic messages;

- (void)sendMessage:(NSString *)text {
    [[PVManagedMessage mainQueueContext] performBlockAndWait:^{
        PVManagedMessage *message = [[PVManagedMessage alloc] initWithContext:nil];
        message.text = text;
        message.date = [NSDate date];
        message.dialog = self;
        message.fromAddress = [[PVChatManager defaultManager] selfAddress];
        [message save];
        
        if (message) {
            [[PVChatManager defaultManager] sendMessage:text toBuddyWithAddress:self.buddy.address];
        }
    }];
}

@end
