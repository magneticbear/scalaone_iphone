//
//  SOHomeViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/21/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOHomeViewController.h"
#import "SOEventListViewController.h"
#import "SOSpeakerListViewController.h"
#import "SOFavoritesViewController.h"
#import "SOProfileViewController.h"
#import "SOChatViewController.h"
#import "SOMapViewController.h"
#import "SOWebViewController.h"

@interface SOHomeViewController ()

@end

@implementation SOHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"ScalaOne";
    
//    Fade out splash image
    UIImageView *splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:splashView];
    [UIView animateWithDuration:0.66f animations:^{
        splashView.alpha = 0;
    } completion:^(BOOL finished) {
        [splashView removeFromSuperview];
    }];
}

- (IBAction)pushEventListVC:(id)sender {
    SOEventListViewController *eventListVC = [[SOEventListViewController alloc] initWithNibName:@"SOEventListViewController" bundle:nil];
    [self.navigationController pushViewController:eventListVC animated:YES];
}

- (IBAction)pushSpeakerListVC:(id)sender {
    SOSpeakerListViewController *speakerListVC = [[SOSpeakerListViewController alloc] initWithNibName:@"SOSpeakerListViewController" bundle:nil];
    [self.navigationController pushViewController:speakerListVC animated:YES];
}

- (IBAction)pushFavoritesVC:(id)sender {
    SOFavoritesViewController *favoritesVC = [[SOFavoritesViewController alloc] initWithNibName:@"SOFavoritesViewController" bundle:nil];
    [self.navigationController pushViewController:favoritesVC animated:YES];
}

- (IBAction)pushProfileVC:(id)sender {
    SOProfileViewController *profileVC = [[SOProfileViewController alloc] initWithNibName:@"SOProfileViewController" bundle:nil];
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (IBAction)pushChatVC:(id)sender {
    SOChatViewController *chatVC = [[SOChatViewController alloc] initWithNibName:@"SOChatViewController" bundle:nil];
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (IBAction)pushMapVC:(id)sender {
    SOMapViewController *mapVC = [[SOMapViewController alloc] initWithNibName:@"SOMapViewController" bundle:nil];
    [self.navigationController pushViewController:mapVC animated:YES];
}

- (IBAction)pushPlaygroundVC:(id)sender {
    SOWebViewController *playgroundVC = [[SOWebViewController alloc] initWithNibName:@"SOWebViewController" bundle:nil title:@"Playground" url:[NSURL URLWithString:[NSString stringWithFormat:@"%@playground",kSOAPIHost]]];
    [self.navigationController pushViewController:playgroundVC animated:YES];
}

- (IBAction)pushAboutVC:(id)sender {
    SOWebViewController *aboutVC = [[SOWebViewController alloc] initWithNibName:@"SOWebViewController" bundle:nil title:@"About Scala1" url:[NSURL URLWithString:kSOAPIHost]];
    [self.navigationController pushViewController:aboutVC animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)didPressTypeSafeLogo:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.typesafe.com"]];
    
}

@end
