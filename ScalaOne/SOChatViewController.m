//
//  SOChatViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOChatViewController.h"
#import "SOHTTPClient.h"
#import "SOChatMessage.h"
#import "SOChatCell.h"

@interface SOChatViewController ()

@end

@implementation SOChatViewController
@synthesize client;
@synthesize chatChannel;
@synthesize chatTableView;

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

- (void)viewDidUnload
{
    [self setChatTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
