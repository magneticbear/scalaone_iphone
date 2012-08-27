//
//  SOHomeViewController.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/21/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOViewController.h"

@interface SOHomeViewController : SOViewController

- (IBAction)pushEventListVC:(id)sender;
- (IBAction)pushSpeakerListVC:(id)sender;
- (IBAction)pushFavoritesVC:(id)sender;
- (IBAction)pushProfileVC:(id)sender;
- (IBAction)pushChatVC:(id)sender;
- (IBAction)pushMapVC:(id)sender;
- (IBAction)pushPlaygroundVC:(id)sender;
- (IBAction)pushAboutVC:(id)sender;

@end
