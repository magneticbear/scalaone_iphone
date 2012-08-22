//
//  SOHomeViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/21/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOHomeViewController.h"
#import "SOSessionListViewController.h"
#import "SOSessionViewController.h"
#import "SOSpeakerListViewController.h"
#import "SOSpeakerViewController.h"
#import "SOFavoritesViewController.h"
#import "SOProfileViewController.h"
#import "SOChatViewController.h"
#import "SOMapViewController.h"
#import "SOPlaygroundViewController.h"

@interface SOHomeViewController ()

@end

@implementation SOHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)pushSessionListVC:(id)sender {
    NSLog(@"pushSessionListVC");
    SOSessionListViewController *sessionListVC = [[SOSessionListViewController alloc] initWithNibName:@"SOSessionListViewController" bundle:nil];
    [self.navigationController pushViewController:sessionListVC animated:YES];
}

- (IBAction)pushSpeakerListVC:(id)sender {
    NSLog(@"pushSpeakerListVC");
    SOSpeakerListViewController *speakerListVC = [[SOSpeakerListViewController alloc] initWithNibName:@"SOSpeakerListViewController" bundle:nil];
    [self.navigationController pushViewController:speakerListVC animated:YES];
}

- (IBAction)pushFavoritesVC:(id)sender {
    NSLog(@"pushFavoritesVC");
    SOFavoritesViewController *favoritesVC = [[SOFavoritesViewController alloc] initWithNibName:@"SOFavoritesViewController" bundle:nil];
    [self.navigationController pushViewController:favoritesVC animated:YES];
}

- (IBAction)pushProfileVC:(id)sender {
    NSLog(@"pushProfileVC");
    SOProfileViewController *profileVC = [[SOProfileViewController alloc] initWithNibName:@"SOProfileViewController" bundle:nil];
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (IBAction)pushChatVC:(id)sender {
    NSLog(@"pushChatVC");
    SOChatViewController *chatVC = [[SOChatViewController alloc] initWithNibName:@"SOChatViewController" bundle:nil];
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (IBAction)pushMapVC:(id)sender {
    NSLog(@"pushMapVC");
    SOMapViewController *mapVC = [[SOMapViewController alloc] initWithNibName:@"SOMapViewController" bundle:nil];
    [self.navigationController pushViewController:mapVC animated:YES];
}

- (IBAction)pushPlaygroundVC:(id)sender {
    NSLog(@"pushPlaygroundVC");
    SOPlaygroundViewController *playgroundVC = [[SOPlaygroundViewController alloc] initWithNibName:@"SOPlaygroundViewController" bundle:nil];
    [self.navigationController pushViewController:playgroundVC animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
