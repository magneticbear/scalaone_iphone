//
//  SOSpeakerListViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

// TODO: Fix bug where if searching for something and user performs an action (favorite or tap cell), dismissing search won't bring back all events

#import "SOSpeakerListViewController.h"
#import "SOWebViewController.h"
#import "SOListHeaderLabel.h"
#import "SOHTTPClient.h"
#import "SOSpeaker.h"
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
@synthesize currentCell = _currentCell;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = kSOScreenTitleSpeakers;
    
    if (kSOAnalyticsEnabled) {
        MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
        [mixpanel track:self.title];
    }
    
    _tableView.separatorColor = [UIColor colorWithWhite:0.85 alpha:1];
    _tableView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    
    // Setup
    _searchBar.placeholder = kSOSpeakerSearchPlaceholder;
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
    
    [[SOHTTPClient sharedClient] getEventsWithSuccess:^(AFJSONRequestOperation *operation, NSDictionary *responseDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
                NSArray *events = [[responseDict objectForKey:@"result"] objectForKey:@"events"];
                
                for (NSDictionary *eventDict in events) {
                    
                    SOEvent* event = nil;
                    
                    NSFetchRequest *request = [[NSFetchRequest alloc] init];
                    
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:moc];
                    [request setEntity:entity];
                    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"remoteID == %d", [[eventDict objectForKey:@"id"] intValue]];
                    [request setPredicate:searchFilter];
                    
                    NSArray *results = [moc executeFetchRequest:request error:nil];
                    
                    if (results.count > 0) {
                        event = [results lastObject];
                    } else {
                        event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:moc];
                    }
                    
                    event.title = [eventDict objectForKey:@"title"];
                    event.remoteID = [NSNumber numberWithInt:[[eventDict objectForKey:@"id"] intValue]];
                    event.location = [eventDict objectForKey:@"location"];
                    event.textDescription = [eventDict objectForKey:@"description"];
                    event.code = [eventDict objectForKey:@"code"];
                    
                    // Dates
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"]; // Sample date format: 2012-01-16T01:38:37.123Z
                    event.start = [df dateFromString:(NSString*)[eventDict objectForKey:@"start"]];
                    event.end = [df dateFromString:(NSString*)[eventDict objectForKey:@"end"]];
                }
                
                NSError *error = nil;
                if ([moc hasChanges] && ![moc save:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                }
            }
        });
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"getEvents failed");
        });
    }];
    
    [self resetAndFetch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_tableView reloadData];
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
        cell = [[SOSpeakerCell alloc] initWithSpeaker:speaker favorite:NO];
        cell.delegate = self;
    } else {
        [cell setSpeaker:speaker];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SOSpeaker *speaker = [_fetchedResultsController objectAtIndexPath:indexPath];
    SOWebViewController *speakerVC = [[SOWebViewController alloc] initWithSpeaker:speaker];
    [self.navigationController pushViewController:speakerVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Core Data

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (_avatarState == SOAvatarStateDefault) {
        _currentCell = nil;
        [_tableView reloadData];
    }
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
    } else {
        [_tableView reloadData];
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

#pragma mark - SOSpeakerCellDelegate & Avatar Methods

- (void)didPressAvatarForCell:(SOSpeakerCell *)speakerCell {
    if (_avatarState == SOAvatarStateFavorite) {
        if (_currentCell.speaker.favorite.boolValue) {
            speakerCell.imageView.image = [UIImage imageNamed:@"list-avatar-favorite"];
        } else {
            speakerCell.imageView.image = [UIImage imageNamed:@"list-avatar-favorite-on"];
        }
        _currentCell.speaker.favorite = [NSNumber numberWithBool:!_currentCell.speaker.favorite.boolValue];
        NSError *error = nil;
        if ([moc hasChanges] && ![moc save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        [self performSelector:@selector(dismissAvatar) withObject:nil afterDelay:0.15f];
        return;
    }
    _avatarState = SOAvatarStateAnimatingToFavorite;
    _currentCell = speakerCell;
    [UIView transitionWithView:speakerCell.imageView
                      duration:0.66f
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        if (_currentCell.speaker.favorite.boolValue) {
                            speakerCell.imageView.image = [UIImage imageNamed:@"list-avatar-favorite-on"];
                        } else {
                            speakerCell.imageView.image = [UIImage imageNamed:@"list-avatar-favorite"];
                        }
                    }
                    completion:^(BOOL finished){
                        _avatarState = SOAvatarStateFavorite;
                    }];
}

- (void)dismissAvatar {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:
     [NSURL URLWithString:[NSString stringWithFormat:kSOImageURLFormatForSpeaker,kSOAPIHost,_currentCell.speaker.remoteID.integerValue]]
                    delegate:self
                     options:0
                     success:^(UIImage *image, BOOL cached) {
                         _avatarState = SOAvatarStateAnimatingToDefault;
                         [UIView transitionWithView:_currentCell.imageView
                                           duration:0.66f
                                            options:UIViewAnimationOptionTransitionFlipFromLeft
                                         animations:^{
                                             if (_currentCell.speaker.favorite.boolValue) {
                                                 _currentCell.imageView.image = [UIImage avatarWithSource:image type:SOAvatarTypeFavoriteOn];
                                             } else {
                                                 _currentCell.imageView.image = [UIImage avatarWithSource:image type:SOAvatarTypeFavoriteOff];
                                             }
                                         }
                                         completion:^(BOOL finished){
                                             _avatarState = SOAvatarStateDefault;
                                             _currentCell = nil;
                                             [_tableView reloadData];
                                         }];
                     } failure:^(NSError *error) {
                         _avatarState = SOAvatarStateAnimatingToDefault;
                         [UIView transitionWithView:_currentCell.imageView
                                           duration:0.66f
                                            options:UIViewAnimationOptionTransitionFlipFromLeft
                                         animations:^{
                                             if (_currentCell.speaker.favorite.boolValue) {
                                                 _currentCell.imageView.image = [UIImage avatarWithSource:nil type:SOAvatarTypeFavoriteOn];
                                             } else {
                                                 _currentCell.imageView.image = [UIImage avatarWithSource:nil type:SOAvatarTypeFavoriteOff];
                                             }
                                         }
                                         completion:^(BOOL finished){
                                             _avatarState = SOAvatarStateDefault;
                                             _currentCell = nil;
                                             [_tableView reloadData];
                                         }];
                     }];
}

- (UIView *)view:(SOUniqueTouchView *)view hitTest:(CGPoint)point withEvent:(UIEvent *)event hitView:(UIView *)hitView {
    // If the avatar is in default state, or the user is tapping the "favorite" image
    if (_avatarState == SOAvatarStateDefault || (hitView == _currentCell.imageView && _avatarState == SOAvatarStateFavorite)) {
        return hitView;
    } else if (_avatarState == SOAvatarStateFavorite && hitView != _currentCell.imageView) {
        [self dismissAvatar];
    }
    
    return nil;
}

@end
