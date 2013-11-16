//
//  PVChatDialogListViewController.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/8/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVDialogListViewController.h"
#import "PVManagedContact.h"
#import "PVManagedDialog.h"
#import "PVDialogViewController.h"
#import "PVChatManager.h"
#import "PVContactCell.h"
#import "UIViewController+PVChatStatusLeftItem.h"

static NSString * const kPVChatDialogListViewControllerCellReuseIdentifier = @"kPVChatDialogListViewControllerCellReuseIdentifier";

@interface PVDialogListViewController ()

@end

@implementation PVDialogListViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    
    if (self) {
        self.title = @"Dialogs";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Dialogs" image:nil tag:0];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar-dialogs-highlighted"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar-dialogs-normal"]];
        [self pv_configureChatStatusItem];
    }
    
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onlineStatus:)
                                                 name:kPVChatManagerContactStatusNotificationName
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) onlineStatus:(NSNotification *) note
{
    PVManagedContact *contact = [note.userInfo objectForKey:kPVChatManagerContactStatusNotificationUserInfoContactKey];
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:contact];
    
    PVContactCell *cell = (PVContactCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.online = contact.status == PVManagedContactStatusOnline;
    
}

- (Class)entityClass {
    return [PVManagedDialog class];
}

- (NSArray *)sortDescriptors {
    return @[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES]];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    PVContactCell *contactCell = (PVContactCell *)cell;
    
    contactCell.online = YES;
    
    PVManagedDialog *dialog = [self.fetchedResultsController objectAtIndexPath:indexPath];
    contactCell.textLabel.text = dialog.buddy.alias;
    contactCell.detailTextLabel.text = dialog.buddy.address;
    contactCell.online = dialog.buddy.status == PVManagedContactStatusOnline;
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *imageURL = [mainBundle URLForResource:@"avatar_0" withExtension:@"png"];
    
    PVAvatar *avatar = [PVAvatar new];
    [avatar setSourceImageURL:imageURL];
    
    [contactCell setAvatar:avatar];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kPVChatDialogListViewControllerCellReuseIdentifier];
    
    if (!cell) {
        cell = [[PVContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kPVChatDialogListViewControllerCellReuseIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PVManagedDialog *dialog = [self.fetchedResultsController objectAtIndexPath:indexPath];
    PVDialogViewController *dialogController = [[PVDialogViewController alloc] initWithDialog:dialog];
    dialogController.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:dialogController animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"Swipe");
        PVManagedDialog *dialog = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [dialog delete];
        [[PVChatManager defaultManager] removeDialog:dialog];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

@end
