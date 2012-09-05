//
//  SOSpeakerViewController.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOViewController.h"

@class SOSpeaker;

@interface SOSpeakerViewController : SOViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil speaker:(SOSpeaker *)speaker;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
