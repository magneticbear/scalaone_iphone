//
//  SOSpeakerListViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOSpeakerListViewController.h"
#import "SOWebViewController.h"
#import "SOListHeaderLabel.h"
#import "SOHTTPClient.h"
#import "SOSpeaker.h"
#import "SOSpeakerCell.h"
#import "UIImage+SOAvatar.h"
#import "SDWebImageManager.h"

static inline double radians (double degrees) {return degrees * M_PI/180;}

@interface SOSpeakerListViewController () <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *moc;
}
@end

@implementation SOSpeakerListViewController
@synthesize tableView = _tableView;
@synthesize searchBar = _searchBar;
@synthesize avatarState = _avatarState;
@synthesize currentAvatar = _currentAvatar;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Speakers";
    
    _tableView.separatorColor = [UIColor colorWithWhite:0.85 alpha:1];
    _tableView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    
//    Setup
    _searchBar.placeholder = @"Find speakers";
    _avatarState = SOAvatarStateDefault;
    ((SOUniqueTouchView*)self.view).viewDelegate = self;
    
    moc = [(id)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [[SOHTTPClient sharedClient] getSpeakersWithSuccess:^(AFJSONRequestOperation *operation, NSDictionary *responseDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
                NSArray *speakers = [[responseDict objectForKey:@"result"] objectForKey:@"speakers"];
                
                for (NSDictionary *speakerDict in speakers) {
                    
                    SOSpeaker* speaker = nil;
                    
                    NSFetchRequest *request = [[NSFetchRequest alloc] init];
                    
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Speaker" inManagedObjectContext:moc];
                    [request setEntity:entity];
                    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"remoteID == %d", [[speakerDict objectForKey:@"id"] intValue]];
                    [request setPredicate:searchFilter];
                    
                    NSArray *results = [moc executeFetchRequest:request error:nil];
                    
                    if (results.count > 0) {
                        speaker = [results lastObject];
                    } else {
                        speaker = [NSEntityDescription insertNewObjectForEntityForName:@"Speaker" inManagedObjectContext:moc];
                    }
                    
                    speaker.name = [speakerDict objectForKey:@"name"];
                    speaker.remoteID = [NSNumber numberWithInt:[[speakerDict objectForKey:@"id"] intValue]];
                }
                
                NSError *error = nil;
                if ([moc hasChanges] && ![moc save:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                }
            }
        });
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"getSpeakers failed");
        });
    }];
    
    [self resetAndFetch];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    moc = nil;
    _tableView = nil;
    _fetchedResultsController = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _fetchedResultsController.delegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[_fetchedResultsController sections] count];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerTitleLabel = [[SOListHeaderLabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 24)];
    headerTitleLabel.text = [[[_fetchedResultsController sections] objectAtIndex:section] name];
    
    return headerTitleLabel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SOSpeaker *speaker = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *cellIdentifier = @"SpeakerCell";
    SOSpeakerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        SOSpeaker *speaker = [_fetchedResultsController objectAtIndexPath:indexPath];
        cell = [[SOSpeakerCell alloc] initWithSpeaker:speaker favorite:NO];
        
//        Make imageView tappable
        cell.imageView.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] init];
        longPressRecognizer.minimumPressDuration = 0.15f;
        [cell.imageView addGestureRecognizer:longPressRecognizer];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAvatar:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [cell.imageView addGestureRecognizer:tapRecognizer];
    } else {
        [cell setSpeaker:speaker];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SOSpeaker *speaker = [_fetchedResultsController objectAtIndexPath:indexPath];
    SOWebViewController *speakerVC = [[SOWebViewController alloc] initWithTitle:speaker.name url:[NSURL URLWithString:[NSString stringWithFormat:@"%@speakers/%d",kSOAPIHost,speaker.remoteID.integerValue]] speakerID:speaker.remoteID.integerValue];
    [self.navigationController pushViewController:speakerVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Avatar Methods

- (void)didTapAvatar:(UIGestureRecognizer *)gestureRecognizer {
    if (_avatarState == SOAvatarStateFavorite) {
        ((UIImageView *)gestureRecognizer.view).image = [UIImage imageNamed:@"list-avatar-favorite-on"];
        [self performSelector:@selector(toggleAvatar) withObject:nil afterDelay:0.15f];
        return;
    }
    _avatarState = SOAvatarStateAnimatingToFavorite;
    _currentAvatar = nil;
    [UIView transitionWithView:gestureRecognizer.view
                      duration:0.66f
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        ((UIImageView*)gestureRecognizer.view).image = [UIImage imageNamed:@"list-avatar-favorite"];
                    }
                    completion:^(BOOL finished){
                        _avatarState = SOAvatarStateFavorite;
                        _currentAvatar = (UIImageView *)gestureRecognizer.view;
                    }];
}

- (void)toggleAvatar {
    _avatarState = SOAvatarStateAnimatingToDefault;
    [UIView transitionWithView:_currentAvatar
                      duration:0.66f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        _currentAvatar.image = [UIImage avatarWithSource:[UIImage imageNamed:@"jp.jpeg"] type:SOAvatarTypeFavoriteOn];
                    }
                    completion:^(BOOL finished){
                        _avatarState = SOAvatarStateDefault;
                        _currentAvatar = nil;
                    }];
}

- (void)dismissAvatar {
    _avatarState = SOAvatarStateAnimatingToDefault;
    [UIView transitionWithView:_currentAvatar
                      duration:0.66f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        _currentAvatar.image = [UIImage avatarWithSource:[UIImage imageNamed:@"jp.jpeg"] type:SOAvatarTypeFavoriteOn];
                    }
                    completion:^(BOOL finished){
                        _avatarState = SOAvatarStateDefault;
                        _currentAvatar = nil;
                    }];
}

- (UIView *)view:(SOUniqueTouchView *)view hitTest:(CGPoint)point withEvent:(UIEvent *)event hitView:(UIView *)hitView {
//    If the avatar is in default state, or the user is tapping the "favorite" image
    if (_avatarState == SOAvatarStateDefault || (hitView == _currentAvatar && _avatarState == SOAvatarStateFavorite)) {
        return hitView;
    } else if (_avatarState == SOAvatarStateFavorite && hitView != _currentAvatar) {
        [self dismissAvatar];
    }
    
    return nil;
}

#pragma mark - Core Data

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    _currentAvatar = nil;
    _avatarState = SOAvatarStateDefault;
    [_tableView reloadData];
}

- (void)resetAndFetch {
    [NSFetchedResultsController deleteCacheWithName:nil];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Speaker"];
    NSSortDescriptor *nameInitialSortOrder = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:nameInitialSortOrder]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:@"firstInitial" cacheName:@"Speaker"];
    
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Search

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    if ([searchString length]) {
        [NSFetchedResultsController deleteCacheWithName:@"Speaker"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchString];
        [_fetchedResultsController.fetchRequest setPredicate:predicate];
    }
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return YES;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [searchBar resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (![searchBar.text length]) {
        [self resetAndFetch];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self resetAndFetch];
}

@end
