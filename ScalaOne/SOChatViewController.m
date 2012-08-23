//
//  SOChatViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOChatViewController.h"
#import "SOHTTPClient.h"

@interface SOChatViewController ()

@end

@implementation SOChatViewController
@synthesize client;

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
#if !DEMO
    client = [[BLYClient alloc] initWithAppKey:@"28f1d32eb7a1f83880af" delegate:self];
    BLYChannel *chatChannel = [client subscribeToChannelWithName:@"ScalaOne"];
    [chatChannel bindToEvent:@"chat_message" block:^(id message) {
        // `message` is a dictionary of the Pusher message
        NSLog(@"New message: %@", [message objectForKey:@"text"]);
    }];
    
    [[SOHTTPClient sharedClient] getMessagesWithSuccess:^(AFJSONRequestOperation *operation, id responseObject) {
		dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"loading: no\nresponseObject: %@",(NSDictionary*)responseObject);
		});
	} failure:^(AFJSONRequestOperation *operation, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"loading: no\nresetLimitForName");
		});
	}];
#endif
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)backOne:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
