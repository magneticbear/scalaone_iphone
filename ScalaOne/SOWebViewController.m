//
//  SOWebViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOWebViewController.h"
#import "SOAppDelegate.h"
#import "SOChatViewController.h"
#import "NSString+SOAdditions.h"
#import "UIActionSheet+Blocks.h"

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
    
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
    [mixpanel track:self.title];
    
    _webView.backgroundColor = [UIColor colorWithRed: 0.93 green: 0.97 blue: 0.99 alpha: 1];
    for(UIView *wview in [[[_webView subviews] objectAtIndex:0] subviews]) {
        if([wview isKindOfClass:[UIImageView class]]) { wview.hidden = YES; }
    }
    [_webView loadRequest:_urlRequest];
    _webView.scalesPageToFit = YES;
    
    // Bug when favoriting something with 4+ VCs in the nav stack
    if ((_event || _speaker) && self.navigationController.viewControllers.count <= 3) {
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

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    // Catch web URLs
    
    // Sharing
    if ([request.URL.absoluteString rangeOfString:@"share"].location != NSNotFound) {
        if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
            [self postText:self.title toServiceType:kSOTwitterServiceType];
        } else {
            RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
            RIButtonItem *fbItem = [RIButtonItem itemWithLabel:@"Facebook"];
            fbItem.action = ^{ [self postText:self.title toServiceType:SLServiceTypeFacebook]; };
            RIButtonItem *twItem = [RIButtonItem itemWithLabel:@"Twitter"];
            twItem.action = ^{ [self postText:self.title toServiceType:SLServiceTypeTwitter]; };
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Select a sharing service" cancelButtonItem:cancelItem destructiveButtonItem:nil otherButtonItems:fbItem, twItem, nil];
            [sheet showInView:self.view];
        }
        return NO;
        
    // Chat
    } else if ([request.URL.absoluteString rangeOfString:@"discussion"].location != NSNotFound) {
        SOChatViewController *chatVC = [[SOChatViewController alloc] initWithChatURL:[NSString eventChatURLWithEventID:_event.remoteID.integerValue] andPusherChannel:[NSString eventChannelNameWithEventID:_event.remoteID.integerValue]];
        [self.navigationController pushViewController:chatVC animated:YES];
        return NO;
        
    // Event
    } else if ([request.URL.absoluteString rangeOfString:[NSString stringWithFormat:@"%@://events/",kSOScala1Scheme]].location != NSNotFound) {
        NSManagedObjectContext *moc = [(id)[[UIApplication sharedApplication] delegate] managedObjectContext];
                        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
        NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"remoteID == %d", request.URL.lastPathComponent.integerValue];
        [fetchRequest setPredicate:searchFilter];
        
        NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
        
        if (results.count > 0) {
            SOEvent* event = [results lastObject];
            SOWebViewController *eventVC = [[SOWebViewController alloc] initWithEvent:event];
            [self.navigationController pushViewController:eventVC animated:YES];
        }
        return NO;
        
    // Speaker
    } else if ([request.URL.absoluteString rangeOfString:[NSString stringWithFormat:@"%@://speakers/",kSOScala1Scheme]].location != NSNotFound) {
        NSManagedObjectContext *moc = [(id)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Speaker" inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
        NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"remoteID == %d", request.URL.lastPathComponent.integerValue];
        [fetchRequest setPredicate:searchFilter];
        
        NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
        
        if (results.count > 0) {
            SOSpeaker *speaker = [results lastObject];
            SOWebViewController *speakerVC = [[SOWebViewController alloc] initWithSpeaker:speaker];
            [self.navigationController pushViewController:speakerVC animated:YES];
        }
        return NO;
        
    // Non-scala1 URLs
    } else if ([request.URL.absoluteString rangeOfString:kSOAPIHost].location == NSNotFound) {
        if ([[UIApplication sharedApplication] canOpenURL:
             [NSURL URLWithString:[NSString stringWithFormat:@"%@://",kSOGoogleChromeScheme]]]) {
            NSString *scheme = request.URL.scheme;
            
            // Replace the URL Scheme with the Chrome equivalent.
            NSString *chromeScheme = nil;
            if ([scheme isEqualToString:kSOHTTPScheme]) {
                chromeScheme = kSOGoogleChromeScheme;
            } else if ([scheme isEqualToString:kSOHTTPSchemeSecure]) {
                chromeScheme = kSOGoogleChromeSchemeSecure;
            } else {
                [[UIApplication sharedApplication] openURL:request.URL];
            }
            
            // Proceed only if a valid Google Chrome URI Scheme is available.
            if (chromeScheme) {
                NSString *absoluteString = [request.URL absoluteString];
                NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
                NSString *urlNoScheme =
                [absoluteString substringFromIndex:rangeForScheme.location];
                NSString *chromeURLString =
                [chromeScheme stringByAppendingString:urlNoScheme];
                NSURL *chromeURL = [NSURL URLWithString:chromeURLString];
                
                // Open the URL with Chrome.
                [[UIApplication sharedApplication] openURL:chromeURL];
            }
            
        // Everything else
        } else {
            [[UIApplication sharedApplication] openURL:request.URL];
        }
        return NO;
    }
	return YES;
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

#pragma mark - Social

- (void)postText:(NSString*)text toServiceType:(NSString*)serviceType {
    if ([serviceType isEqualToString:kSOTwitterServiceType]) {
        text = [NSString stringWithFormat:@"%@ %@",text,kSOTwitterHashtag];
    }
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
        
        TWTweetComposeViewControllerCompletionHandler __block completionHandler = ^(SLComposeViewControllerResult result){
            [tweetSheet dismissViewControllerAnimated:YES completion:nil];
        };
        
        [tweetSheet setInitialText:text];
        [tweetSheet setCompletionHandler:completionHandler];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    } else {
        SLComposeViewController *slController = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        
        if([SLComposeViewController isAvailableForServiceType:serviceType])
        {
            SLComposeViewControllerCompletionHandler __block completionHandler = ^(SLComposeViewControllerResult result){
                [slController dismissViewControllerAnimated:YES completion:nil];
            };
            [slController setInitialText:text];
            [slController setCompletionHandler:completionHandler];
            [self presentViewController:slController animated:YES completion:nil];
        }
    }
}

@end
