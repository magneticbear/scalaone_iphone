//
//  SOChatViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

// TODO: Fix scroll to bottom on short tables

// TODO (Optional): Remove new cell animation on keyboard dismiss
// TODO (Optional): Add navBar to DAKeyboardControl to have it pan with the keyboard

#import "SOChatViewController.h"
#import "SOHTTPClient.h"
#import "SOChatMessage.h"
#import "SOChatCell.h"

#define SOChatInputFieldStandardHeight  45.0f
#define SOChatInputFieldExpandedHeight  82.0f

@interface SOChatViewController ()
@end

@implementation SOChatViewController
@synthesize client;
@synthesize chatChannel;
@synthesize chatTableView = _chatTableView;
@synthesize chatInputField = _chatInputField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Discuss";
    _chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _chatTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
//    Keyboard show/hide notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    _chatInputField = [[SOChatInputField alloc] initWithFrame:CGRectMake(0.0f,
                                                               self.view.bounds.size.height - SOChatInputFieldStandardHeight,
                                                               self.view.bounds.size.width,
                                                               SOChatInputFieldStandardHeight)];
    _chatInputField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    _chatInputField.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"input_bar"]];
    _chatInputField.delegate = self;
    [self.view addSubview:_chatInputField];
        
    self.view.keyboardTriggerOffset = SOChatInputFieldExpandedHeight;
    
    __weak SOChatViewController *ref = self;
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        [ref updateLayoutWithKeyboardRect:keyboardFrameInView onlyTable:NO];
    }];
    
#if !DEMO
    client = [[BLYClient alloc] initWithAppKey:@"28f1d32eb7a1f83880af" delegate:self];
    chatChannel = [client subscribeToChannelWithName:@"ScalaOne"];
    [chatChannel bindToEvent:@"new_message" block:^(id message) {
        NSLog(@"New message: %@", message);
    }];
    
    [[SOHTTPClient sharedClient] getMessagesWithSuccess:^(AFJSONRequestOperation *operation, id responseObject) {
		dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"getMessages succeeded\nresponseObject: %@",(NSDictionary*)responseObject);
		});
	} failure:^(AFJSONRequestOperation *operation, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"getMessages failed");
		});
	}];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        SOChatMessage *message = [SOChatMessage messageWithText:@"Message from SOChatMessage class" senderID:123456 date:[NSDate date]];
        
        [[SOHTTPClient sharedClient] postMessage:message success:^(AFJSONRequestOperation *operation, id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"postMessage succeeded\nresponseObject: %@",(NSDictionary*)responseObject);
            });
        } failure:^(AFJSONRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"postMessage failed");
            });
        }];
    });
#endif
}

- (void)updateLayoutWithKeyboardRect:(CGRect)keyboardFrameInView onlyTable:(BOOL)onlyTable {
//    Update input field frame
    CGRect chatInputFieldFrame = _chatInputField.frame;
    if (!onlyTable) {
        CGFloat inputFramePanConstant = (SOChatInputFieldExpandedHeight - SOChatInputFieldStandardHeight)/216.0f;
        
        chatInputFieldFrame.size.height = SOChatInputFieldStandardHeight + _chatInputField.inputField.frame.size.height - 30.0f + (self.view.frame.size.height - keyboardFrameInView.origin.y)*inputFramePanConstant;
        
        chatInputFieldFrame.origin.y = keyboardFrameInView.origin.y - chatInputFieldFrame.size.height;
        _chatInputField.frame = chatInputFieldFrame;
        //    Deselect text
        _chatInputField.inputField.selectedTextRange = nil;
    }
    
//    Update tableView frame
    CGRect tableViewRect = _chatTableView.frame;
    tableViewRect.size.height = chatInputFieldFrame.origin.y;
    _chatTableView.frame = tableViewRect;
}

- (void)viewDidUnload
{
    [self setChatTableView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [chatChannel unbindEvent:@"new_message"];
    [chatChannel unsubscribe];
    client = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.view removeKeyboardControl];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)keyboardWillHide:(NSNotification *)notification {
//    Show navBar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [_chatTableView setContentOffset:CGPointMake(0, _chatTableView.contentSize.height-_chatTableView.frame.size.height) animated:NO];
}

- (void)keyboardWillShow:(NSNotification *)notification {
//    Hide navBar
    double delayInSeconds = 0.33f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 10;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SOChatCell *cell = (SOChatCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row+1 == [self tableView:tableView numberOfRowsInSection:indexPath.section]) {
        return cell.frame.size.height + 40;
    }
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *const cellIdentifier = @"cellIdentifier";

    SOChatCell *cell = (SOChatCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[SOChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray *loremArray = @[@"Lorem ipsum dolor sit amet",@"Consectetur adipisicing elit, sed do eiusmod tempor incididunt ut",@"Labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex",@"Ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.", @"Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."];
    
    cell.messageTextView.text = [loremArray objectAtIndex:indexPath.row%loremArray.count];
    cell.cellAlignment = indexPath.row % 2 ? SOChatCellAlignmentLeft : SOChatCellAlignmentRight;
    [cell layoutSubviews];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected cell: %d",indexPath.row);
}

#pragma mark - SOChatInputFieldDelegate

- (void)didChangeSOInputChatFieldSize:(CGSize)size {
    [self updateLayoutWithKeyboardRect:CGRectNull onlyTable:YES];
    [_chatTableView setContentOffset:CGPointMake(0, _chatTableView.contentSize.height-_chatTableView.frame.size.height) animated:NO];
}

@end
