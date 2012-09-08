//
//  SOChatViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

// TODO: Queue sending operations (Twitter, Facebook, Message)

// TODO (Optional): SVProgressHUD extension to allow queuing and changing status lines
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
#import "UIAlertView+Blocks.h"
#import "UIActionSheet+Blocks.h"
#import "SHKFacebook.h"

#define SOChatInputFieldStandardHeight  45.0f
#define SOChatInputFieldExpandedHeight  82.0f

@implementation SHKFacebook(Autoshare)
- (BOOL)shouldAutoShare { return YES; }
- (BOOL)quiet { return YES; };
@end

@interface SOChatViewController () <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *moc;
}
@end

@implementation SOChatViewController
@synthesize client;
@synthesize chatChannel;
@synthesize chatTableView = _chatTableView;
@synthesize chatInputField = _chatInputField;
@synthesize twitterAccount = _twitterAccount;

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
    
    if (!DEMO) {
        moc = [(id)[[UIApplication sharedApplication] delegate] managedObjectContext];
        [[SOHTTPClient sharedClient] getMessagesWithSuccess:^(AFJSONRequestOperation *operation, NSDictionary *responseDict) {
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
                        
                        // Date
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"]; // Sample date format: 2012-01-16T01:38:37.123Z
                        message.sent = [df dateFromString:(NSString*)[messageDict objectForKey:@"sentTime"]];
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
        
        [self resetAndFetch];
        
////////////////////////
//        Pusher
////////////////////////
        
//        client = [[BLYClient alloc] initWithAppKey:@"28f1d32eb7a1f83880af" delegate:self];
//        chatChannel = [client subscribeToChannelWithName:@"ScalaOne"];
//        [chatChannel bindToEvent:@"new_message" block:^(id message) {
//            NSLog(@"New message: %@", message);
//        }];
        
////////////////////////
//        Sinatra Backend
////////////////////////
        
//        [[SOHTTPClient sharedClient] getMessagesWithSuccess:^(AFJSONRequestOperation *operation, id responseObject) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"getMessages succeeded\nresponseObject: %@",(NSDictionary*)responseObject);
//            });
//        } failure:^(AFJSONRequestOperation *operation, NSError *error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"getMessages failed");
//            });
//        }];
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
//            SOChatMessage *message = [SOChatMessage messageWithText:@"Message from SOChatMessage class" senderID:123456 date:[NSDate date]];
//            
//            [[SOHTTPClient sharedClient] postMessage:message success:^(AFJSONRequestOperation *operation, id responseObject) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSLog(@"postMessage succeeded\nresponseObject: %@",(NSDictionary*)responseObject);
//                });
//            } failure:^(AFJSONRequestOperation *operation, NSError *error) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSLog(@"postMessage failed");
//                });
//            }];
//        });
    }
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
    [super viewDidUnload];
    [self setChatTableView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [chatChannel unbindEvent:@"new_message"];
    [chatChannel unsubscribe];
    client = nil;
    moc = nil;
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

#pragma mark - Keyboard

- (void)keyboardWillHide:(NSNotification *)notification {
//    Show navBar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (_chatTableView.contentSize.height > _chatTableView.frame.size.height) {
        [_chatTableView setContentOffset:CGPointMake(0, _chatTableView.contentSize.height-_chatTableView.frame.size.height) animated:NO];
    }
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
	if (DEMO) return 10;
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
    if (DEMO) {
        NSArray *loremArray = @[@"Lorem ipsum dolor sit amet",@"Consectetur adipisicing elit, sed do eiusmod tempor incididunt ut",@"Labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex",@"Ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.", @"Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."];
        
        cell.messageTextView.text = [loremArray objectAtIndex:indexPath.row%loremArray.count];
        [cell.avatarBtn setBackgroundImage:[UIImage avatarWithSource:nil favorite:SOAvatarFavoriteTypeDefault] forState:UIControlStateNormal];
    } else {
        SOMessage *message = [_fetchedResultsController objectAtIndexPath:indexPath];
        cell.messageTextView.text = message.text;
        [cell.avatarBtn setBackgroundImage:[UIImage avatarWithSource:nil favorite:SOAvatarFavoriteTypeDefault] forState:UIControlStateNormal];
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:
         [NSURL URLWithString:[NSString stringWithFormat:@"%@assets/img/profile/%d.jpg",kSOAPIHost,message.senderID.integerValue]]
                        delegate:self
                         options:0
                         success:^(UIImage *image) {
                             [cell.avatarBtn setBackgroundImage:[UIImage avatarWithSource:image favorite:SOAvatarFavoriteTypeDefault] forState:UIControlStateNormal];
                         } failure:^(NSError *error) {
//                             NSLog(@"Image retrieval failed");
                         }];
    }
    
    cell.cellAlignment = indexPath.row % 4 ? SOChatCellAlignmentLeft : SOChatCellAlignmentRight;
    [cell layoutSubviews];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"selected cell: %d",indexPath.row);
}

#pragma mark - SOChatCellDelegate

- (void)didSelectAvatar:(NSInteger)profileID {
    SOProfileViewController *profileVC = [[SOProfileViewController alloc] initWithNibName:@"SOProfileViewController" bundle:nil];
    [self.navigationController pushViewController:profileVC animated:YES];
}

#pragma mark - Core Data

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_chatTableView reloadData];
}

- (void)resetAndFetch {
    [NSFetchedResultsController deleteCacheWithName:nil];
    _fetchedResultsController = nil;
    _fetchedResultsController.fetchRequest.predicate = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    NSSortDescriptor *sortOrder = [[NSSortDescriptor alloc] initWithKey:@"messageID" ascending:YES];
    
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
    if (_chatTableView.contentSize.height > _chatTableView.frame.size.height) {
        [_chatTableView setContentOffset:CGPointMake(0, _chatTableView.contentSize.height-_chatTableView.frame.size.height) animated:NO];
    }
}

- (void)didPressSendWithText:(NSString *)text facebook:(BOOL)facebook twitter:(BOOL)twitter {
    if (twitter) [self postStatus:text toTwitterAccount:_twitterAccount];
    if (facebook) [self postStatusToFacebook:text];
}

#pragma mark - Facebook

- (void)didSelectFacebook {
    if (![SHKFacebook isServiceAuthorized]) {
        [self deselectFacebook];
        [[[SHKFacebook alloc] init] authorize];
    }
}

- (void)deselectFacebook {
    _chatInputField.facebookButton.highlighted = NO;
    _chatInputField.shouldSendToFacebook = NO;
}

- (void)postStatusToFacebook:(NSString*)status {
    [SVProgressHUD showWithStatus:@"Sending to Facebook..."];
    SHKSharer *sharer = [SHKFacebook shareText:@"testing app - sharing text - please ignore"];
    sharer.shareDelegate = self;
}

- (void)sharerFinishedSending:(SHKSharer *)sharer
{
    [SVProgressHUD dismissWithSuccess:@"Successfully sent to Facebook!"];
}

- (void)sharer:(SHKSharer *)sharer failedWithError:(NSError *)error shouldRelogin:(BOOL)shouldRelogin
{
    [SVProgressHUD dismiss];
    
    //if user sent the item already but needs to relogin we do not show alert
    if (!sharer.quiet && sharer.pendingAction != SHKPendingShare && sharer.pendingAction != SHKPendingSend)
	{
		[[[UIAlertView alloc] initWithTitle:SHKLocalizedString(@"Error")
									 message:sharer.lastError!=nil?[sharer.lastError localizedDescription]:SHKLocalizedString(@"There was an error while sharing")
									delegate:nil
						   cancelButtonTitle:SHKLocalizedString(@"Close")
						   otherButtonTitles:nil] show];
    }
    if (shouldRelogin) {
        [sharer promptAuthorization];
	}
}

- (void)sharerStartedSending:(SHKSharer *)sharer {
    NSLog(@"sharerStartedSending");
}

- (void)sharerAuthDidFinish:(SHKSharer *)sharer success:(BOOL)success {
    NSLog(@"sharerAuthDidFinish");
}

- (void)sharerCancelledSending:(SHKSharer *)sharer {
    NSLog(@"sharerCancelledSending");
}

#pragma mark - Twitter

- (void)didSelectTwitter {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Completion Handler for requestAccessToAccounts
    void (^accountRequestCompletionHandler)(BOOL, NSError *) = ^(BOOL granted, NSError *error) {
        if (granted) {
            // Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            if (accountsArray.count > 1) {
                [self performSelectorOnMainThread:@selector(populateSheetAndShow:) withObject:accountsArray waitUntilDone:NO];
            } else if (accountsArray.count == 1) {
                _twitterAccount = (ACAccount*)[accountsArray lastObject];
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Linked Scala1 app with @%@",[(ACAccount*)accountsArray.lastObject username]] duration:2.0f];
            } else {
                [self performSelectorOnMainThread:@selector(noTwitterAccounts) withObject:nil waitUntilDone:NO];
            }
        } else {
            if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"6.0")) {
                [self performSelectorOnMainThread:@selector(noTwitterAccounts) withObject:nil waitUntilDone:NO];
            }
            [self performSelectorOnMainThread:@selector(deselectTwitter) withObject:nil waitUntilDone:NO];
        }
    };
    
    // Request access from the user to use their Twitter accounts.
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:accountRequestCompletionHandler];
    } else {
//        Must be commented for compiling with Xcode 4.4.1
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:accountRequestCompletionHandler];
    }
}

- (void)deselectTwitter {
    _chatInputField.twitterButton.highlighted = NO;
    _chatInputField.shouldSendToTwitter = NO;
}

- (void)noTwitterAccounts {
    [self deselectTwitter];
    
    if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"6.0")) {
        UIAlertView *ios6Alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"You do not have any Twitter accounts linked with this iPhone.\n\nOpen iPhone Settings to create one." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [ios6Alert show];
        return;
    }
    
    RIButtonItem *noItem = [RIButtonItem itemWithLabel:@"No"];
    
    RIButtonItem *yesItem = [RIButtonItem itemWithLabel:@"Yes"];
    yesItem.action = ^{ [self openTwitterSettings]; };
    
    UIAlertView *noTwitterAlert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts"
                                                             message:@"You do not have any Twitter accounts linked with this iPhone. Would you like exit this app and link one now?"
                                                    cancelButtonItem:noItem
                                                    otherButtonItems:yesItem, nil];
    [noTwitterAlert show];
}

- (void)openTwitterSettings {
    // This works in 5.0/5.1/5.1.1; No known work-around for iOS 6
    // Code from http://goto11.net/programmatically-open-twitter-settings-on-ios-5-1/
    TWTweetComposeViewController *ctrl = [[TWTweetComposeViewController alloc] init];
    if ([ctrl respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        // Manually invoke the alert view button handler
        [(id <UIAlertViewDelegate>)ctrl alertView:nil clickedButtonAtIndex:0];
    }
}

-(void)populateSheetAndShow:(NSArray *) accountsArray {
    NSMutableArray *buttonsArray = [NSMutableArray array];
    [accountsArray enumerateObjectsUsingBlock:^(ACAccount *account, NSUInteger idx, BOOL *stop) {
        RIButtonItem *item = [RIButtonItem itemWithLabel:[NSString stringWithFormat:@"@%@",account.username]];
        item.action = ^{ _twitterAccount = account; };
        [buttonsArray addObject:item];
    }];
    
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
    cancelItem.action = ^{ [self deselectTwitter]; };
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:nil destructiveButtonItem:nil otherButtonItems:nil];
    
    for (RIButtonItem *item in buttonsArray) {
        [actionSheet addButtonItem:item];
    }
    
    [actionSheet addButtonItem:cancelItem];
    [actionSheet setCancelButtonIndex:buttonsArray.count];
    
    [actionSheet showInView:self.view];
}

- (void)postStatus:(NSString*)status toTwitterAccount:(ACAccount*)account
{
    // Create an account store object.
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccount *requestAccount = [accountStore accountWithIdentifier:account.identifier];
    
    TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"]
                                                 parameters:[NSDictionary dictionaryWithObject:status forKey:@"status"]
                                              requestMethod:TWRequestMethodPOST];

    // Set the account used to post the tweet.
    [postRequest setAccount:requestAccount];
    
    // Send tweet
    [SVProgressHUD showWithStatus:@"Sending tweet..." maskType:SVProgressHUDMaskTypeClear];
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) {
            [SVProgressHUD dismissWithSuccess:@"Tweet sent!"];
        } else {
            [SVProgressHUD dismissWithError:@"Could not send to Twitter"];
        }
    }];
}

@end
