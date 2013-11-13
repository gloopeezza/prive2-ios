//
//  PVDialogViewController.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/11/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVDialogViewController.h"
#import "PVManagedDialog.h"
#import "PVManagedMessage.h"
#import "PVManagedContact.h"
#import "PVDialogCell.h"

static NSString * const kPVDialogViewControllerMessageCellReuseIdentifier = @"kPVDialogViewControllerMessageCellReuseIdentifier";

#define kMessageTextWidth 145.0f
#define kMinHeight 100.0f

@interface PVDialogViewController () {
    PVManagedDialog *_dialog;
    
    UIView *containerView;
    HPGrowingTextView *textView;
}

@end

@implementation PVDialogViewController

- (id)initWithDialog:(PVManagedDialog *)dialog {
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        _dialog = dialog;
        [self configureController];
        [self configureGrowingTextView];
    }
    
    return self;
}

- (Class)entityClass {
    return [PVManagedMessage class];
}

- (NSArray *)sortDescriptors {
    return @[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES]];
}

- (NSString *)sectionNameKeyPath {
    return @"day";
}
- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *request = [super fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"dialog == %@", self.dialog];
    return request;
}

- (void)configureCell:(PVDialogCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    PVManagedMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //cell.textLabel.text = message.text;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"From %@", message.dialog.buddy.address];

    if ([message.fromAddress isEqualToString:message.dialog.buddy.address]) {
        [cell setupCellWithType:PVDialogCellReceived andMessage:message];
    }else
        [cell setupCellWithType:PVDialogCellSent andMessage:message];
    
    [cell.contentView setNeedsDisplay];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PVManagedMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];

    CGSize size = [message.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0]
				   constrainedToSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
					   lineBreakMode:NSLineBreakByWordWrapping];
    return MAX(size.height, kMinHeight) ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    PVDialogCell *cell = (PVDialogCell*)[tableView dequeueReusableCellWithIdentifier:kPVDialogViewControllerMessageCellReuseIdentifier];

    if (!cell) {
        cell = [[PVDialogCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kPVDialogViewControllerMessageCellReuseIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Configure Chat Interface

- (void)configureController
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dialog-background"]];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 40.0, 0.0);
    
    self.tableView.backgroundColor = UIColor.clearColor;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    UIToolbar *tools = [[UIToolbar alloc]
                        initWithFrame:CGRectMake(0.0f, 0.0f, 103.0f, 44.01f)]; // 44.01 shifts it up 1px for some reason
    tools.clearsContextBeforeDrawing = NO;
    tools.clipsToBounds = NO;
    tools.tintColor = [UIColor colorWithWhite:0.305f alpha:0.0f]; // closest I could get by eye to black, translucent style.
    // anyone know how to get it perfect?
    tools.barStyle = -1; // clear background
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:3];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backButton setTitle:@"" forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"nav-back-button"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0.0f, 0.0f, 44.0f, 44.0f);
    [backButton setContentEdgeInsets:UIEdgeInsetsMake(-5, 0, -5, 0)];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -10;
    
    [buttons addObject:fixed];
    [buttons addObject:backButtonItem];
    
    [tools setItems:buttons animated:NO];
    UIBarButtonItem *twoButtons = [[UIBarButtonItem alloc] initWithCustomView:tools];

    self.navigationItem.leftBarButtonItem = twoButtons;
}

#pragma mark - Configure Chat Interface
- (void)sendMessage
{
    [_dialog sendMessage:textView.text];
    [textView resignFirstResponder];
    textView.text = @"";
}

- (void)attachFile
{
    NSLog(@"attachFile");
}

- (void)configureGrowingTextView
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, 320, 50)];
    
	textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(15.0, 3.0, 240.0, 50.0)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 3;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
	textView.returnKeyType = UIReturnKeyGo; //just as an example
	textView.font = [UIFont systemFontOfSize:15.0f];
	textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    textView.text = @" ";
    // textView.text = @"test\n\ntest";
	// textView.animateHeightChange = NO; //turns off animation
    
    [self.view addSubview:containerView];
	
    /*UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, 248, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    */
    
    UIImage *rawBackground = [UIImage imageNamed:@"dialog-text-view"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0.0, 0.0, 272.0, 50.0);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [containerView addSubview:imageView];
    [containerView addSubview:textView];
    //[containerView addSubview:entryImageView];
    
    UIImage *sendBtnBackground = [UIImage imageNamed:@"dialog-send-button"];
    
	UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	doneBtn.frame = CGRectMake(containerView.frame.size.width - 46.0, 0.0, 45.0, 45.0);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    
	[doneBtn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
	[containerView addSubview:doneBtn];
    
    UIImage *attachBtnBackground = [UIImage imageNamed:@"dialog-attach-file"];
    
	UIButton *attachBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	attachBtn.frame = CGRectMake(3.0, 11.0, 23.0, 23.0);
    attachBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    
	[attachBtn addTarget:self action:@selector(attachFile) forControlEvents:UIControlEventTouchUpInside];
    [attachBtn setBackgroundImage:attachBtnBackground forState:UIControlStateNormal];
	[containerView addSubview:attachBtn];
    
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	containerView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	containerView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	containerView.frame = r;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideKeyboard];
}

-(void)hideKeyboard
{
    [self.view endEditing:YES];
}

@end
