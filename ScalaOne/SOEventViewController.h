//
//  SOEventViewController.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOViewController.h"

@class SOEvent;

@interface SOEventViewController : SOViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(SOEvent *)event;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end
