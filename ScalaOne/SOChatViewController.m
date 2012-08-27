//
//  SOChatViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

// TODO: Adjust table view frame when keyboard is up

// TODO (Optional): Animate input field up with keyboard will show
// TODO (Optional): Add navBar to DAKeyboardControl to have it pan with the keyboard

#import "SOChatViewController.h"
#import "SOHTTPClient.h"
#import "SOChatMessage.h"
#import "SOChatCell.h"
#import "SOChatInputField.h"

@interface InputTextField : UITextField
@property (nonatomic,assign) UIEdgeInsets insets;
@end

@implementation InputTextField
@synthesize insets;
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + insets.left, bounds.origin.y + insets.top, bounds.size.width - (insets.left+insets.right), bounds.size.height - (insets.top+insets.bottom));
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}
@end

@interface SOChatViewController ()
    @property (nonatomic) InputTextField *inputField;
@end

@implementation SOChatViewController
@synthesize client;
@synthesize chatChannel;
@synthesize chatTableView = _chatTableView;
@synthesize inputField = _inputField;

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
    self.title = @"Chat";
    _chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
//    Keyboard show/hide notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    SOChatInputField *toolBar = [[SOChatInputField alloc] initWithFrame:CGRectMake(0.0f,
                                                               self.view.bounds.size.height - 49.0f,
                                                               self.view.bounds.size.width,
                                                               49.0f)];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    toolBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"input_bar"]];
    [self.view addSubview:toolBar];
    
    _inputField = [[InputTextField alloc] initWithFrame:CGRectMake(10.0f,
                                                                   9.0f,
                                                                   toolBar.bounds.size.width - 20.0f - 68.0f,
                                                                   30.0f)];
    
//    UIImage *fieldImg = [[UIImage imageNamed:@"input_field"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
//    _inputField.background = fieldImg;
//    _inputField.borderStyle = UITextBorderStyleNone;
    _inputField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _inputField.autocorrectionType = UITextAutocorrectionTypeNo;
    _inputField.insets = UIEdgeInsetsMake(4, 10, 0, 10);
    _inputField.returnKeyType = UIReturnKeySend;
    _inputField.delegate = self;
    _inputField.placeholder = @"Send a chat";
    [toolBar addSubview:_inputField];
    
//    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    postButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
//    postButton.titleLabel.shadowColor = [UIColor colorWithWhite:0.5 alpha:1.0];
//    postButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
//    postButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//    UIImage *postBtnImg = [[UIImage imageNamed:@"post_btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
//    [postButton setBackgroundImage:postBtnImg forState:UIControlStateNormal];
//    UIImage *postBtnImgDown = [[UIImage imageNamed:@"post_btn_down"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
//    [postButton setBackgroundImage:postBtnImgDown forState:UIControlStateHighlighted];
//    [postButton setTitle:@"Send" forState:UIControlStateNormal];
//    postButton.frame = CGRectMake(toolBar.bounds.size.width - 71.0f,
//                                  (toolBar.bounds.size.height - 31.0f)/2,
//                                  61.0f,
//                                  31.0f);
//    [postButton addTarget:self action:@selector(didPressPost:) forControlEvents:UIControlEventTouchUpInside];
//    [toolBar addSubview:postButton];
    
    self.view.keyboardTriggerOffset = toolBar.bounds.size.height;
    
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        CGRect toolBarFrame = toolBar.frame;
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        toolBar.frame = toolBarFrame;
        
//        Update tableView frame
        CGRect tableViewRect = _chatTableView.frame;
        tableViewRect.size.height = toolBarFrame.origin.y;
        _chatTableView.frame = tableViewRect;
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

#pragma mark - UITextField/DAKeyboardControl

- (void)didPressPost:(id)sender {
    if (_inputField.text.length) {
        _inputField.text = @"";
        [_inputField resignFirstResponder];
    } else {
        [_inputField becomeFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self didPressPost:self];
    return YES;
}

- (void)viewDidUnload
{
    [self setChatTableView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
}

- (void)keyboardWillShow:(NSNotification *)notification {
//    Hide navBar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 10;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *const cellIdentifier = @"cellIdentifier";

    SOChatCell *cell = (SOChatCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[SOChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.messageTextView.text = @"This is my pretty long chat message, hard coded into cellForRowAtIndexPath. This is my pretty long chat message, hard coded into cellForRowAtIndexPath.";
    cell.cellAlignment = indexPath.row % 2 ? SOChatCellAlignmentLeft : SOChatCellAlignmentRight;
    [cell layoutSubviews];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected cell: %d",indexPath.row);
}

@end
