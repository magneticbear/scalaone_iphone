//
//  SOWebViewController.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOViewController.h"

@interface SOWebViewController : SOViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (id)initWithTitle:(NSString*)aTitle url:(NSURL*)aURL;

- (id)initWithTitle:(NSString*)aTitle url:(NSURL*)aURL speakerID:(NSInteger)aSpeakerID;

- (id)initWithTitle:(NSString*)aTitle url:(NSURL*)aURL eventID:(NSInteger)aEventID;

- (id)initWithTitle:(NSString*)aTitle url:(NSURL*)aURL speakerID:(NSInteger)aSpeakerID eventID:(NSInteger)aEventID;

@end
