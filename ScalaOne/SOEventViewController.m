//
//  SOEventViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOEventViewController.h"

@interface SOEventViewController ()

@end

@implementation SOEventViewController
@synthesize webView = _webView;

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
    self.title = @"Event";
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mgn.tc/scalaone/event.jpg"]]];
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
