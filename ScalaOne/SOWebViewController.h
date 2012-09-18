//
//  SOWebViewController.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOViewController.h"
#import "SOEvent.h"
#import "SOSpeaker.h"

// Social
#import <Twitter/Twitter.h>     // iOS 5
#import <Social/Social.h>       // iOS 6+

@interface SOWebViewController : SOViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (id)initWithTitle:(NSString*)aTitle url:(NSURL*)aURL;
- (id)initWithEvent:(SOEvent *)event;
- (id)initWithSpeaker:(SOSpeaker *)speaker;

@end
