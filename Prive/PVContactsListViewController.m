//
//  PVBuddyListViewController.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/6/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVContactsListViewController.h"
#import "PVContactProfileViewController.h"
#import "PVChatManager.h"
#import "PVManagedContact.h"
#import "PVManagedDialog.h"
#import "PVDialogViewController.h"
#import "UIImage+Appearance.h"
#import "PVContactCell.h"
#import "PVAvatar.h"
#import "UIViewController+PVChatStatusLeftItem.h"
#import "PVTorLoadingView.h"

static NSString * const kPVBuddyListViewControllerCellReuseIdentifier = @"kPVBuddyListViewControllerCellReuseIdentifier";

@interface PVContactsListViewController () <UIAlertViewDelegate>
{
    NSArray *imageURLs;
    PVTorLoadingView *_statusView;
}

@property (nonatomic, weak) UIAlertView *addBuddyAlertView;

@end

@implementation PVContactsListViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Contacts";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Contacts" image:nil tag:0];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar-contacts-highlighted"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar-contacts-normal"]];
        
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addButton setFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
        [addButton addTarget:self action:@selector(addBuddy:) forControlEvents:UIControlEventTouchUpInside];
        [addButton setImage:[UIImage imageNamed:@"nav-add-button"] forState:UIControlStateNormal];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:addButton];
        
        self.navigationItem.rightBarButtonItem = barButton;
        [self pv_configureChatStatusItem];
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        imageURLs = [mainBundle URLsForResourcesWithExtension:@"png" subdirectory:@"PriveAvatars.bundle"];
    }
    
    return self;
}

- (void)connectionStatusChangeHandler:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateStatusView];
    });
}

- (void)updateStatusView {
    switch ([PVChatManager defaultManager].connectionStatus) {
        case PVChatManagerConnectionStatusTypeNone:
            
            break;
            
        case PVChatManagerConnectionStatusTypeTorStarting:
            _statusView.statusLabel.text = @"Connecting to Tor network...";
            break;
            
        case PVChatManagerConnectionStatusTypeConnectingToIntroPoint:
            _statusView.statusLabel.text = @"Connecting to Tor Introduction point...";
            break;
            
        case PVChatManagerConnectionStatusTypeConnectingToRendezvousPoint:
            _statusView.statusLabel.text = @"Connecting to Tor Rendezvous point...";
            break;
            
        case PVChatManagerConnectionStatusTypeDone: {
            _statusView.statusLabel.text = @"Successfuly connected to Tor!";
            [self setLoading:NO animated:YES];
        }
            break;
            
        default:
            break;
    }
}


- (BOOL)hasContent {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _statusView = [[PVTorLoadingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 240.0f, 48.0f)];
    
    self.loadingView = _statusView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionStatusChangeHandler:)
                                                 name:kPVChatManagerConnectionStatusChangeNotificationName
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onlineStatus:)
                                                 name:kPVChatManagerContactStatusNotificationName
                                               object:nil];
    [self updateStatusView];
    
    if ([PVChatManager defaultManager].connectionStatus != PVChatManagerConnectionStatusTypeDone) {
        [self setLoading:YES animated:YES];
    } else {
        [self setLoading:NO animated:NO];
    }
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

#pragma mark - Alert View

- (UIAlertView *)addBuddyAlertView {
    if (_addBuddyAlertView) return _addBuddyAlertView;
    UIAlertView *addBuddyAlertView = [[UIAlertView alloc] initWithTitle:@"Add buddy" message:@"Enter buddy address" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    addBuddyAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    _addBuddyAlertView = addBuddyAlertView;
    return addBuddyAlertView;
}

- (void)addBuddy:(id)sender {
    if (!_addBuddyAlertView) {
        [self.addBuddyAlertView show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *buddyAddress = [alertView textFieldAtIndex:0].text;
        [[PVChatManager defaultManager] addBuddyWithAddress:buddyAddress name:nil];
        self.addBuddyAlertView = nil;
    }
}

#pragma mark - Table View

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    PVContactCell *contactCell = (PVContactCell *)cell;
    
    PVManagedContact *buddy = (PVManagedContact *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    contactCell.textLabel.text = buddy.alias;
    contactCell.detailTextLabel.text = buddy.address;
    contactCell.online = buddy.status == PVManagedContactStatusOnline;
    
    PVAvatar *avatar = [PVAvatar new];

    if (imageURLs && imageURLs.count > 0 && indexPath.row <= imageURLs.count) {
        [avatar setSourceImageURL:[imageURLs objectAtIndex:indexPath.row]];
    }else if(imageURLs && imageURLs.count > 0){
        [avatar setSourceImageURL:[imageURLs objectAtIndex:0]];
    }
    
    [avatar setTorchatID:buddy.address];
    
    [contactCell setAvatar:avatar];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PVManagedContact *buddy = [self.fetchedResultsController objectAtIndexPath:indexPath];

    PVContactProfileViewController *profileController = [PVContactProfileViewController new];
    [profileController setupControllerWithBuddy:buddy];
    [self.navigationController pushViewController:profileController animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PVManagedContact *buddy = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[PVChatManager defaultManager] removeBuddy:buddy.address];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kPVBuddyListViewControllerCellReuseIdentifier];
    if (!cell) {
        cell = [[PVContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kPVBuddyListViewControllerCellReuseIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - SSManagedTableViewController

- (Class)entityClass {
    return [PVManagedContact class];
}

- (NSArray *)sortDescriptors {
    NSSortDescriptor *sortByAliasDescriptor = [[NSSortDescriptor alloc] initWithKey:@"alias" ascending:YES];
    return @[sortByAliasDescriptor];
}

@end
