//
//  SOEventViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOEventViewController.h"
#import "SOEvent.h"
#import "SODefines.h"

@interface SOEventViewController ()

@end

@implementation SOEventViewController {
    SOEvent *_event;
}
@synthesize webView = _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(SOEvent *)event
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _event = event;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (DEMO) {
        self.title = @"Event";
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mgn.tc/scalaone/event.jpg"]]];
    } else {
        self.title = _event.title;
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@events/%d",kSOAPIHost,_event.remoteID.integerValue]]]];
    }
    _webView.scalesPageToFit = YES;
    
//    Right bar button star
    UIButton *starButton = [UIButton buttonWithType:UIButtonTypeCustom];
    starButton.frame = CGRectMake(0, 0, 40, 24);
    starButton.contentMode = UIViewContentModeCenter;
    [starButton setBackgroundImage:[UIImage imageNamed:@"topbar-star-off"] forState:UIControlStateNormal];
    [starButton setBackgroundImage:[UIImage imageNamed:@"topbar-star-on"] forState:UIControlStateHighlighted];
    [starButton addTarget:self action:@selector(didPressStar:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:starButton];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didPressStar:(id)sender {
    NSLog(@"didPressStar");
}

@end
