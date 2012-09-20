//
//  SOChatViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

// TODO: Improve performance on load
// TODO: Show name of sender, and message sent date

// TODO (Optional): Add day separators
// TODO (Optional): Remove new cell animation on keyboard dismiss
// TODO (Optional): Add navBar to DAKeyboardControl to have it pan with the keyboard

#import "SOChatViewController.h"
#import "SOHTTPClient.h"
#import "SOChatMessage.h"
#import "SOProfileViewController.h"
#import "SOMessage.h"
#import "UIImage+SOAvatar.h"
#import "SDWebImageManager.h"
#import "SVProgressHUD.h"

#define kSOChatInputFieldStandardHeight 45.0f
#define kSOChatInputFieldExpandedHeight 82.0f

@interface SOChatViewController () <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *moc;
    NSMutableArray *sendingQueue;
}
@end

@implementation SOChatViewController
@synthesize client;
@synthesize chatChannel;
@synthesize chatTableView = _chatTableView;
@synthesize chatInputField = _chatInputField;
@synthesize twitterAccount = _twitterAccount;
@synthesize facebookAccount = _facebookAccount;
@synthesize myUserID = _myUserID;
@synthesize chatURL = _chatURL;
@synthesize pusherChannelName = _pusherChannelName;

- (id)initWithChatURL:(NSString *)aChatURL andPusherChannel:(NSString *)pusherChannel {
    self = [super init];
    if (self) {
        _chatURL = aChatURL;
        _pusherChannelName = pusherChannel;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([_chatURL rangeOfString:@"general"].location != NSNotFound) {
        self.title = @"Discuss";
    } else if ([_chatURL rangeOfString:@"private"].location != NSNotFound) {
        self.title = @"Private Chat";
    } else if ([_chatURL rangeOfString:@"event"].location != NSNotFound) {
        self.title = @"Event Chat";
    }
    
    _chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _chatTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //    Keyboard show/hide notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    _chatInputField = [[SOChatInputField alloc] initWithFrame:CGRectMake(0.0f,
                                                                         self.view.bounds.size.height - kSOChatInputFieldStandardHeight,
                                                                         self.view.bounds.size.width,
                                                                         kSOChatInputFieldStandardHeight)];
    
    _chatInputField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    _chatInputField.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"input_bar"]];
    _chatInputField.delegate = self;
    [self.view addSubview:_chatInputField];
    
    self.view.keyboardTriggerOffset = kSOChatInputFieldExpandedHeight;
    
    __weak SOChatViewController *ref = self;
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        [ref updateLayoutWithKeyboardRect:keyboardFrameInView onlyTable:NO];
    }];
    
    moc = [(id)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    [self setMyID];
    
    [self getMessages];
    
    [self resetAndFetch];
    
    sendingQueue = [[NSMutableArray alloc] initWithCapacity:3];
    
    if (!_myUserID) {
        _chatInputField.inputField.placeholder = @"Please create your profile to chat";
        _chatInputField.inputField.userInteractionEnabled = NO;
    }
    
    client = [[BLYClient alloc] initWithAppKey:kSOPusherAPIKey delegate:self];
    chatChannel = [client subscribeToChannelWithName:_pusherChannelName];
    [chatChannel bindToEvent:@"newMessage" block:^(NSDictionary *message) {
        [self getMessages];
    }];
}

- (void)setMyID {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:moc]];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"isMe == YES && remoteID != nil"]];
    
    NSArray *results = [moc executeFetchRequest:request error:nil];
    
    if (results.count) {
        SOUser *me = [results lastObject];
        _myUserID = me.remoteID.integerValue;
    }
}

- (void)getMessages {
    [[SOHTTPClient sharedClient] getMessagesAtPath:_chatURL withSuccess:^(AFJSONRequestOperation *operation, NSDictionary *responseDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
                NSArray *messages = [[responseDict objectForKey:@"result"] objectForKey:@"messages"];
                
                for (NSDictionary *messageDict in messages) {
                    
                    SOMessage* message = nil;
                    
                    NSFetchRequest *request = [[NSFetchRequest alloc] init];
                    
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:moc];
                    [request setEntity:entity];
                    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"messageID == %d", [[messageDict objectForKey:@"id"] intValue]];
                    [request setPredicate:searchFilter];
                    
                    NSArray *results = [moc executeFetchRequest:request error:nil];
                    
                    if (results.count > 0) {
                        message = [results lastObject];
                    } else {
                        message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:moc];
                    }
                    
                    message.senderName = [messageDict objectForKey:@"senderName"];
                    message.senderID = [NSNumber numberWithInt:[[messageDict objectForKey:@"senderId"] intValue]];
                    message.messageID = [NSNumber numberWithInt:[[messageDict objectForKey:@"id"] intValue]];
                    message.text = [messageDict objectForKey:@"content"];
                    message.messageIndex = [NSNumber numberWithInt:[[messageDict objectForKey:@"index"] intValue]];
                    message.channel = _pusherChannelName;
                    
                    // Date
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"]; // Sample date format: 2012-01-16T01:38:37.123Z
                    message.sent = [df dateFromString:(NSString*)[messageDict objectForKey:@"sentTime"]];
                    
                    [self fetchUserWithID:message.senderID.integerValue];
                }
                
                NSError *error = nil;
                if ([moc hasChanges] && ![moc save:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                }
            }
        });
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"getMessages failed");
        });
    }];
}

- (void)fetchUserWithID:(NSInteger)userID {
    [[SOHTTPClient sharedClient] getUserWithID:userID success:^(AFJSONRequestOperation *operation, NSDictionary *responseDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
                NSDictionary *userDict = [responseDict objectForKey:@"result"];
                
                SOUser* user = nil;
                
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc];
                [request setEntity:entity];
                NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"remoteID == %d", [[userDict objectForKey:@"id"] intValue]];
                [request setPredicate:searchFilter];
                
                NSArray *results = [moc executeFetchRequest:request error:nil];
                
                if (results.count > 0) {
                    user = [results lastObject];
                } else {
                    user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc];
                }
                
                // User components
                user.firstName = [userDict objectForKey:@"firstName"];
                user.lastName = [userDict objectForKey:@"lastName"];
                user.remoteID = [NSNumber numberWithInt:[[userDict objectForKey:@"id"] intValue]];
                user.twitter = [userDict objectForKey:@"twitter"];
                user.facebook = [userDict objectForKey:@"facebook"];
                user.phone = [userDict objectForKey:@"phone"];
                user.email = [userDict objectForKey:@"email"];
                user.website = [userDict objectForKey:@"website"];
                
                // Location components
                user.latitude = [NSNumber numberWithFloat:[[userDict objectForKey:@"latitude"] floatValue]];
                user.longitude = [NSNumber numberWithFloat:[[userDict objectForKey:@"longitude"] floatValue]];
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"]; // Sample date format: 2012-01-16T01:38:37.123Z
                user.locationTime = [df dateFromString:[userDict objectForKey:@"locationTime"]];
                
                NSError *error = nil;
                if ([moc hasChanges] && ![moc save:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                }
            }
        });
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"getUserWithID failed");
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    Keyboard show/hide notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    __weak SOChatViewController *ref = self;
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        [ref updateLayoutWithKeyboardRect:keyboardFrameInView onlyTable:NO];
    }];
    
    [self resetAndFetch];
}

- (void)updateLayoutWithKeyboardRect:(CGRect)keyboardFrameInView onlyTable:(BOOL)onlyTable {
    //    Update input field frame
    CGRect chatInputFieldFrame = _chatInputField.frame;
    if (!onlyTable) {
        CGFloat inputFramePanConstant = (kSOChatInputFieldExpandedHeight - kSOChatInputFieldStandardHeight)/216.0f;
        
        chatInputFieldFrame.size.height = kSOChatInputFieldStandardHeight + _chatInputField.inputField.frame.size.height - 30.0f + (self.view.frame.size.height - keyboardFrameInView.origin.y)*inputFramePanConstant;
        
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
    [super viewDidUnload];
    [self setChatTableView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [chatChannel unbindEvent:@"new_message"];
    [chatChannel unsubscribe];
    client = nil;
    moc = nil;
    sendingQueue = nil;
    _chatTableView = nil;
    _fetchedResultsController = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _fetchedResultsController.delegate = nil;
    [self.view removeKeyboardControl];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)resetLayout {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    _chatTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-kSOChatInputFieldStandardHeight);
    _chatInputField.frame = CGRectMake(0, self.view.frame.size.height-kSOChatInputFieldStandardHeight, self.view.frame.size.width, kSOChatInputFieldStandardHeight);
    [self scrollToBottom];
}

#pragma sendingQueue

- (void)addAction:(void (^)(void))action toQueue:(NSMutableArray *)queue {
    [queue addObject:[action copy]];
}

- (void)performNextQueueItem {
    if (sendingQueue.count >= 1) {
        void (^ action)() = [[sendingQueue objectAtIndex:0] copy];
        action();
        [sendingQueue removeObjectAtIndex:0];
    }
}

#pragma mark - Keyboard

- (void)keyboardWillHide:(NSNotification *)notification {
    //    Show navBar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self scrollToBottom];
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
    if (!_fetchedResultsController.fetchedObjects.count) {
        [self.view sendSubviewToBack:_chatTableView];
    } else {
        [self.view bringSubviewToFront:_chatTableView];
    }
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
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
        cell.delegate = self;
    }
    
    //    Cell Content
    SOMessage *message = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.messageTextView.text = message.text;
    cell.userID = message.senderID.integerValue;
    [cell.avatarBtn setBackgroundImage:[UIImage avatarWithSource:nil type:SOAvatarTypeUser] forState:UIControlStateNormal];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:
     [NSURL URLWithString:[NSString stringWithFormat:@"%@assets/img/user/%d.jpg",kSOAPIHost,message.senderID.integerValue]]
                    delegate:self
                     options:0
                     success:^(UIImage *image, BOOL cached) {
                         [cell.avatarBtn setBackgroundImage:[UIImage avatarWithSource:image type:SOAvatarTypeUser] forState:UIControlStateNormal];
                     } failure:^(NSError *error) {
                         // NSLog(@"Image retrieval failed");
                     }];
    
    if (message.senderID.integerValue == _myUserID) {
        cell.cellAlignment = SOChatCellAlignmentRight;
    } else {
        cell.cellAlignment = SOChatCellAlignmentLeft;
    }
    [cell layoutSubviews];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"selected cell: %d",indexPath.row);
}

- (void)scrollToBottom {
    if (_chatTableView.contentSize.height > _chatTableView.frame.size.height) {
        [_chatTableView setContentOffset:CGPointMake(0, _chatTableView.contentSize.height-_chatTableView.frame.size.height) animated:NO];
    }
}

#pragma mark - SOChatCellDelegate

- (void)didSelectAvatar:(NSInteger)profileID {
    [self.view endEditing:YES];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:moc]];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"remoteID == %d",profileID]];
    
    NSArray *results = [moc executeFetchRequest:request error:nil];
    
    if (results.count) {
        SOProfileViewController *profileVC = [[SOProfileViewController alloc] initWithUser:[results lastObject]];
        [self.navigationController pushViewController:profileVC animated:YES];
    }
}

#pragma mark - Core Data

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_chatTableView reloadData];
    [self scrollToBottom];
}

- (void)resetAndFetch {
    [NSFetchedResultsController deleteCacheWithName:nil];
    _fetchedResultsController = nil;
    _fetchedResultsController.fetchRequest.predicate = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    NSSortDescriptor *sortOrder = [[NSSortDescriptor alloc] initWithKey:@"messageID" ascending:YES];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"channel ==[c] %@",_pusherChannelName]];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortOrder]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:nil cacheName:@"messages/general"];
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - SOChatInputFieldDelegate

- (void)didChangeSOInputChatFieldSize:(CGSize)size {
    [self updateLayoutWithKeyboardRect:CGRectNull onlyTable:YES];
    [self scrollToBottom];
}

- (void)didPressSendWithText:(NSString *)text facebook:(BOOL)facebook twitter:(BOOL)twitter {
    __block SOChatViewController *safeSelf = self;
    
    [self addAction:^{
        [safeSelf postMessageToAPI:text];
    } toQueue:sendingQueue];
    
    if (twitter) {
        [self addAction:^{
            if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
                [safeSelf postText:text toServiceType:kSOTwitterServiceType];
            } else {
                [safeSelf postText:text toServiceType:SLServiceTypeTwitter];
            }
        } toQueue:sendingQueue];
    }
    
    if (facebook) {
        [self addAction:^{
            [safeSelf postText:text toServiceType:SLServiceTypeFacebook];
        } toQueue:sendingQueue];
    }
    
    [self performNextQueueItem];
}

#pragma mark - SOAPI

- (void)postMessageToAPI:(NSString*)text {
    if (_myUserID) {
        SOChatMessage *message = [SOChatMessage messageWithText:text senderID:_myUserID channel:_pusherChannelName];
        
        [SVProgressHUD showWithStatus:@"Sending message..."];
        [[SOHTTPClient sharedClient] postMessage:message toPath:_chatURL success:^(AFJSONRequestOperation *operation, id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self performNextQueueItem];
            });
        } failure:^(AFJSONRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"Message couldn't be sent. Please try again later."];
                [self performNextQueueItem];
            });
        }];
    }
}

#pragma mark - Facebook

- (void)deselectFacebook {
    _chatInputField.facebookButton.highlighted = NO;
    _chatInputField.shouldSendToFacebook = NO;
}

- (void)didSelectFacebook {
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        [self performSelector:@selector(deselectFacebook) withObject:nil afterDelay:0.01];
        int64_t delayInSeconds = 0.02;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kSONoFacebookAccountTitle message:kSONoFacebookAccountMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
    }
}

#pragma mark - Twitter

- (void)deselectTwitter {
    _chatInputField.twitterButton.highlighted = NO;
    _chatInputField.shouldSendToTwitter = NO;
}

- (void)didSelectTwitter {
    if (![self globalCanSendTweet]) {
        [self performSelector:@selector(deselectTwitter) withObject:nil afterDelay:0.01];
        int64_t delayInSeconds = 0.02;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            UIAlertView *noTwitterAlert = [[UIAlertView alloc] initWithTitle:kSONoTwitterAccountsTitle
                                                                     message:kSONoTwitterAccountsMessage
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
            [noTwitterAlert show];
        });
    }
}

- (BOOL)globalCanSendTweet {
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        return [TWTweetComposeViewController canSendTweet];
    } else {
        return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
    }
    return NO;
}

#pragma mark - Social

- (void)postText:(NSString*)text toServiceType:(NSString*)serviceType {
    if ([serviceType isEqualToString:kSOTwitterServiceType]) {
        text = [NSString stringWithFormat:@"%@ %@",text,kSOTwitterHashtag];
    }
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
        
        TWTweetComposeViewControllerCompletionHandler __block completionHandler = ^(SLComposeViewControllerResult result){
            [self deselectTwitter];
            [tweetSheet dismissViewControllerAnimated:YES completion:^{
                [self performNextQueueItem];
                [self resetLayout];
            }];
        };
        
        [tweetSheet setInitialText:text];
        [tweetSheet setCompletionHandler:completionHandler];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    } else {
        SLComposeViewController *slController = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        
        if([SLComposeViewController isAvailableForServiceType:serviceType])
        {
            SLComposeViewControllerCompletionHandler __block completionHandler = ^(SLComposeViewControllerResult result){
                if ([serviceType isEqualToString:SLServiceTypeFacebook]) {
                    [self deselectFacebook];
                } else if ([serviceType isEqualToString:SLServiceTypeTwitter]) {
                    [self deselectTwitter];
                }
                
                [slController dismissViewControllerAnimated:YES completion:^{
                    [self performNextQueueItem];
                    [self resetLayout];
                }];
            };
            [slController setInitialText:text];
            [slController setCompletionHandler:completionHandler];
            [self presentViewController:slController animated:YES completion:nil];
        }
    }
}

@end
