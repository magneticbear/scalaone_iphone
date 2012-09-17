//
//  SOWebViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOWebViewController.h"
#import "SOAppDelegate.h"

@interface SOWebViewController ()
@property (nonatomic, strong) NSURLRequest *urlRequest;
@property (nonatomic, assign) SOEvent *event;
@property (nonatomic, assign) SOSpeaker *speaker;
@property (nonatomic, retain) UIButton *starBtn;
@end

@implementation SOWebViewController
@synthesize webView = _webView;
@synthesize activityIndicator = _activityIndicator;
@synthesize urlRequest = _urlRequest;
@synthesize speaker = _speaker;
@synthesize event = _event;
@synthesize starBtn = _starBtn;

#pragma mark - Init

- (id)initWithTitle:(NSString*)aTitle url:(NSURL*)aURL
{
    return [self initWithTitle:aTitle url:aURL speaker:nil event:nil];
}

- (id)initWithEvent:(SOEvent *)event {
    return [self initWithTitle:event.title url:[self urlForEvent:event] speaker:nil event:event];
}

- (id)initWithSpeaker:(SOSpeaker *)speaker {
    return [self initWithTitle:speaker.name url:[self urlForSpeaker:speaker] speaker:speaker event:nil];
}

- (id)initWithTitle:(NSString*)aTitle url:(NSURL*)aURL speaker:(SOSpeaker *)aSpeaker event:(SOEvent *)aEvent
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = aTitle;
        _urlRequest = [NSURLRequest requestWithURL:aURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        _speaker = aSpeaker;
        _event = aEvent;
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _webView.backgroundColor = [UIColor colorWithRed: 0.93 green: 0.97 blue: 0.99 alpha: 1];
    for(UIView *wview in [[[_webView subviews] objectAtIndex:0] subviews]) {
        if([wview isKindOfClass:[UIImageView class]]) { wview.hidden = YES; }
    }
    [_webView loadRequest:_urlRequest];
    _webView.scalesPageToFit = YES;
    if (_event || _speaker) {
        //    Right bar button star
        _starBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _starBtn.frame = CGRectMake(0, 0, 40, 24);
        _starBtn.contentMode = UIViewContentModeCenter;
        
        UIImage *starImg = [UIImage imageNamed:@"topbar-star-off"];
        if ((_event && _event.favorite.boolValue) || (_speaker && _speaker.favorite.boolValue)) {
            starImg = [UIImage imageNamed:@"topbar-star-on"];
        }
        [_starBtn setBackgroundImage:starImg forState:UIControlStateNormal];
        [_starBtn addTarget:self action:@selector(didPressStar:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_starBtn];
    }
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [_activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_activityIndicator stopAnimating];
}

#pragma mark - Favorite

- (void)didPressStar:(id)sender {
    UIImage *starImg = [UIImage imageNamed:@"topbar-star-off"];
    if (_event) {
        _event.favorite = [NSNumber numberWithBool:!_event.favorite.boolValue];
        starImg = _event.favorite.boolValue ? [UIImage imageNamed:@"topbar-star-on"] : [UIImage imageNamed:@"topbar-star-off"];
    } else if (_speaker) {
        _speaker.favorite = [NSNumber numberWithBool:!_speaker.favorite.boolValue];
        starImg = _speaker.favorite.boolValue ? [UIImage imageNamed:@"topbar-star-on"] : [UIImage imageNamed:@"topbar-star-off"];
    }
    
    [_starBtn setBackgroundImage:starImg forState:UIControlStateNormal];
    [self saveContext];
}

#pragma mark - Utitilies

- (NSURL *)urlForEvent:(SOEvent *)event {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@events/%d",kSOAPIHost,event.remoteID.integerValue]];
}

- (NSURL *)urlForSpeaker:(SOSpeaker *)speaker {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@speakers/%d",kSOAPIHost,speaker.remoteID.integerValue]];
}

- (void)saveContext {
    SOAppDelegate *appDel = (SOAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDel saveContext];
}

@end
