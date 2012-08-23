//
//  SOChatViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOChatViewController.h"

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
