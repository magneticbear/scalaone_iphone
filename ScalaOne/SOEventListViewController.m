//
//  SOEventListViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//  http://www.magneticbear.com

#import "SOEventListViewController.h"
#import "SOWebViewController.h"
#import "SOListHeaderLabel.h"
#import "SOHTTPClient.h"
#import "SOEvent.h"
#import "SOEventCell.h"

@interface SOEventListViewController () <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *moc;
}
@end

@implementation SOEventListViewController
@synthesize tableView = _tableView;
@synthesize searchBar = _searchBar;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = kSOScreenTitleEvents;
    
    if (kSOAnalyticsEnabled) {
        MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
        [mixpanel track:self.title];
    }
    
    _tableView.separatorColor = [UIColor colorWithWhite:0.85 alpha:1];
    _tableView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    _searchBar.placeholder = kSOEventSearchPlaceholder;
    
    moc = [(id)[[UIApplication sharedApplication] delegate] managedObjectContext];
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
            // NSLog(@"getSpeakers failed");
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
    headerTitleLabel.text = [NSString stringWithFormat:@"Day %d",section+1];
    
    return headerTitleLabel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SOEvent *event = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *cellIdentifier = @"EventCell";
    SOEventCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[SOEventCell alloc] initWithEvent:event favorite:NO];
    } else {
        [cell setEvent:event];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SOEvent *event = [_fetchedResultsController objectAtIndexPath:indexPath];
    SOWebViewController *eventVC = [[SOWebViewController alloc] initWithEvent:event];
    [self.navigationController pushViewController:eventVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Core Data

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_tableView reloadData];
}

- (void)resetAndFetch {
    [NSFetchedResultsController deleteCacheWithName:nil];
    _fetchedResultsController = nil;
    _fetchedResultsController.fetchRequest.predicate = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    NSSortDescriptor *sortOrder = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortOrder]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:@"day" cacheName:@"Event"];
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
        [NSFetchedResultsController deleteCacheWithName:@"Event"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", searchString];
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
