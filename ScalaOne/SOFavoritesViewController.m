//
//  SOFavoritesViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

// TODO: Don't duplicate the efforts of SOEventViewController and SOSpeakerViewController

#import "SOFavoritesViewController.h"
#import "SOHTTPClient.h"

#import "SOWebViewController.h"

#import "SOEvent.h"
#import "SOSpeaker.h"

#import "SOEventCell.h"
#import "SOSpeakerCell.h"

#import "SDWebImageManager.h"
#import "UIImage+SOAvatar.h"

@interface SOFavoritesViewController () <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *moc;
}
- (void)refetchData;
@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSArray *speakers;
@end

@implementation SOFavoritesViewController
@synthesize segmentView = _segmentView;
@synthesize tableView = _tableView;
@synthesize segmentEventsBtn = _segmentEventsBtn;
@synthesize segmentSpeakersBtn = _segmentSpeakersBtn;
@synthesize events = _events;
@synthesize speakers = _speakers;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Favorites";
    _tableView.separatorColor = [UIColor colorWithWhite:0.85 alpha:1];
    _tableView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    
    if (DEMO) {
        _events = @[@"Talk 1",@"Talk 2",@"Talk 3",@"Talk 4",@"Talk 5",@"Talk 6",@"Talk 7",@"Talk 8",@"Talk 9",@"Talk 10",@"Talk 11",@"Talk 12"];
        _speakers = @[@"Speaker 1",@"Speaker 2",@"Speaker 3",@"Speaker 4",@"Speaker 5",@"Speaker 6",@"Speaker 7",@"Speaker 8",@"Speaker 9",@"Speaker 10",@"Speaker 11",@"Speaker 12"];
    }
    
    _segmentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"segment_bg"]];
    
    [self didSelectSegment:_segmentEventsBtn];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    moc = nil;
    _tableView = nil;
    _fetchedResultsController = nil;
    _segmentView = nil;
    _segmentEventsBtn = nil;
    _segmentSpeakersBtn = nil;
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
    if (DEMO) return (currentSegment == SOFavoritesSegmentTypeEvents) ? _events.count : _speakers.count;
    
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentSegment == SOFavoritesSegmentTypeEvents) {
        SOEvent *event = [_fetchedResultsController objectAtIndexPath:indexPath];
        
        NSString *cellIdentifier = @"EventCellFavorite";
        SOEventCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[SOEventCell alloc] initWithEvent:event favorite:YES];
        } else {
            [cell setEvent:event];
        }
        
        return cell;
    }   else if (currentSegment == SOFavoritesSegmentTypeSpeakers) {
        SOSpeaker *speaker = [_fetchedResultsController objectAtIndexPath:indexPath];
        
        NSString *cellIdentifier = @"SpeakerCellFavorite";
        SOSpeakerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[SOSpeakerCell alloc] initWithSpeaker:speaker favorite:YES];
        } else {
            [cell setSpeaker:speaker];
        }
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (currentSegment == SOFavoritesSegmentTypeEvents) {
        SOEvent *event = [_fetchedResultsController objectAtIndexPath:indexPath];
        SOWebViewController *eventVC = [[SOWebViewController alloc] initWithTitle:event.title url:[NSURL URLWithString:[NSString stringWithFormat:@"%@events/%d",kSOAPIHost,event.remoteID.integerValue]] eventID:event.remoteID.integerValue];
        [self.navigationController pushViewController:eventVC animated:YES];
    } else if (currentSegment == SOFavoritesSegmentTypeSpeakers) {
        SOSpeaker *speaker = [_fetchedResultsController objectAtIndexPath:indexPath];
        SOWebViewController *speakerVC = [[SOWebViewController alloc] initWithTitle:speaker.name url:[NSURL URLWithString:[NSString stringWithFormat:@"%@speakers/%d",kSOAPIHost,speaker.remoteID.integerValue]] speakerID:speaker.remoteID.integerValue];
        [self.navigationController pushViewController:speakerVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)didSelectSegment:(UIButton*)sender {
    if (sender == _segmentEventsBtn) {
        [_segmentSpeakersBtn setHighlighted:NO];
        currentSegment = SOFavoritesSegmentTypeEvents;
        
        if (!DEMO) {
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
                            
                            //                        Dates
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
            
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
            NSSortDescriptor *sortOrder = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:YES];
            
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"favorite == YES"]];
            
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortOrder]];
            
            _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:nil cacheName:@"Event"];
            _fetchedResultsController.delegate = self;
            [_fetchedResultsController performFetch:nil];
            [_tableView reloadData];
        }
    } else if (sender == _segmentSpeakersBtn) {
        [_segmentEventsBtn setHighlighted:NO];
        currentSegment = SOFavoritesSegmentTypeSpeakers;
        
        if (!DEMO) {
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
//                    NSLog(@"getSpeakers failed");
                });
            }];
            
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Speaker"];
            NSSortDescriptor *nameInitialSortOrder = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:nameInitialSortOrder]];
            
            _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:nil cacheName:@"Speaker"];
            _fetchedResultsController.delegate = self;
            [_fetchedResultsController performFetch:nil];
            [_tableView reloadData];
        }
    }
    if (DEMO) [_tableView reloadData];
    [_tableView setContentOffset:CGPointMake(0, 0)];
    [self performSelector:@selector(doHighlight:) withObject:sender afterDelay:0];
}

- (void)doHighlight:(UIButton*)b {
    [b setHighlighted:YES];
}

#pragma mark - Core Data

- (void)refetchData {
    _fetchedResultsController.fetchRequest.resultType = NSManagedObjectResultType;
    [_fetchedResultsController performFetch:nil];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_tableView reloadData];
}

@end
