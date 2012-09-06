//
//  SOWebViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

// TODO: There must be a better way to have multiple init functions

#import "SOWebViewController.h"

@interface SOWebViewController ()
@property (nonatomic, strong) NSURLRequest *urlRequest;
@property (nonatomic, assign) NSInteger speakerID;
@property (nonatomic, assign) NSInteger eventID;
@end

@implementation SOWebViewController
@synthesize webView = _webView;
@synthesize activityIndicator = _activityIndicator;
@synthesize urlRequest = _urlRequest;
@synthesize speakerID = _speakerID;
@synthesize eventID = _eventID;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)aTitle url:(NSURL*)aURL
{
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil title:aTitle url:aURL speakerID:-1 eventID:-1];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)aTitle url:(NSURL*)aURL speakerID:(NSInteger)aSpeakerID {
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil title:aTitle url:aURL speakerID:aSpeakerID eventID:-1];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)aTitle url:(NSURL*)aURL eventID:(NSInteger)aEventID {
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil title:aTitle url:aURL speakerID:-1 eventID:aEventID];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)aTitle url:(NSURL*)aURL speakerID:(NSInteger)aSpeakerID eventID:(NSInteger)aEventID
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = aTitle;
        _urlRequest = [NSURLRequest requestWithURL:aURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        _speakerID = aSpeakerID;
        _eventID = aEventID;
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_webView loadRequest:_urlRequest];
    _webView.scalesPageToFit = YES;
    if (_speakerID != -1 || _eventID != -1) {
        //    Right bar button star
        UIButton *starButton = [UIButton buttonWithType:UIButtonTypeCustom];
        starButton.frame = CGRectMake(0, 0, 40, 24);
        starButton.contentMode = UIViewContentModeCenter;
        [starButton setBackgroundImage:[UIImage imageNamed:@"topbar-star-off"] forState:UIControlStateNormal];
        [starButton setBackgroundImage:[UIImage imageNamed:@"topbar-star-on"] forState:UIControlStateHighlighted];
        [starButton addTarget:self action:@selector(didPressStar:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:starButton];
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
    NSLog(@"didPressStar");
}

@end
