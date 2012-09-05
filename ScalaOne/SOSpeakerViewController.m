//
//  SOSpeakerViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOSpeakerViewController.h"
#import "SOSpeaker.h"

@interface SOSpeakerViewController ()

@end

@implementation SOSpeakerViewController {
    SOSpeaker *_speaker;
}

@synthesize webView = _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil speaker:(SOSpeaker *)speaker
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _speaker = speaker;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSURLRequest *request = nil;
    
    if (DEMO) {
        self.title = @"Speaker";
        request = [NSURLRequest
                   requestWithURL:[NSURL URLWithString:@"http://mgn.tc/scalaone/speaker.jpg"]
                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                   timeoutInterval:10.0];
    } else {
        self.title = _speaker.name;
        request = [NSURLRequest
                   requestWithURL:[NSURL URLWithString:
                                   [NSString stringWithFormat:@"%@speakers/%d",kSOAPIHost,_speaker.remoteID.integerValue]]
                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                   timeoutInterval:10.0];
    }
    
    [_webView loadRequest:request];
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
