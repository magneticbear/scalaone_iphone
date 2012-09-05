//
//  SOEventListViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOEventListViewController.h"
#import "SOEventViewController.h"
#import "SOListHeaderLabel.h"
#import "SOHTTPClient.h"
#import "SOEvent.h"

@interface SOEventListViewController () <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *moc;
}
- (void)refetchData;
@property (nonatomic, strong) NSArray *events;
@end

@implementation SOEventListViewController
@synthesize tableView = _tableView;
@synthesize searchBar = _searchBar;
@synthesize events = _events;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Events";
    
    _tableView.separatorColor = [UIColor colorWithWhite:0.85 alpha:1];
    _searchBar.placeholder = @"Find events";
    
    if (DEMO) {
        _events = @[@"Talk 1",@"Talk 2",@"Talk 3",@"Talk 4",@"Talk 5",@"Talk 6",@"Talk 7",@"Talk 8",@"Talk 9",@"Talk 10",@"Talk 11",@"Talk 12"];
    } else {
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
        
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortOrder]];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:@"day" cacheName:@"Root"];
        _fetchedResultsController.delegate = self;
        [_fetchedResultsController performFetch:nil];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    moc = nil;
    _tableView = nil;
    _searchBar = nil;
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
    if (DEMO) return _events.count;
    
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (DEMO) return 2;
    
    return [[_fetchedResultsController sections] count];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerTitleLabel = [[SOListHeaderLabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 24)];
    headerTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:16.0f];
    headerTitleLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.42f];
    headerTitleLabel.textColor = [UIColor whiteColor];
    headerTitleLabel.shadowOffset = CGSizeMake(0, -1);
    headerTitleLabel.text = [NSString stringWithFormat:@"Day %d",section+1];
    [headerTitleLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"list-category-repeat"]]];
    return headerTitleLabel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"EventCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
//        Background views
        UIView *bgColorView = [[UIView alloc] init];
        [bgColorView setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
        [cell setBackgroundView:bgColorView];
        
        UIView *bgColorViewSelected = [[UIView alloc] init];
        [bgColorViewSelected setBackgroundColor:[UIColor colorWithRed:0.051 green:0.643 blue:0.816 alpha:1]];
        [cell setSelectedBackgroundView:bgColorViewSelected];
        
//        Text Label Setup
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:19.0f];
        cell.textLabel.textColor = [UIColor colorWithRed:13.0f/255.0f green:164.0f/255.0f blue:208.0f/255.0f alpha:1.0f];
        cell.textLabel.backgroundColor = bgColorView.backgroundColor;
        
//        Detail Text Label Setup
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:12.0f];
        cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
        cell.detailTextLabel.backgroundColor = bgColorView.backgroundColor;
        
//        Accessory Image
        UIImage *accessoryImage = [UIImage imageNamed:@"list-arrow"];
        UIImageView *accImageView = [[UIImageView alloc] initWithImage:accessoryImage];
        [accImageView setFrame:CGRectMake(0, 0, 12, 17)];
        cell.accessoryView = accImageView;
        
//        Make imageView tappable
        cell.imageView.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] init];
        longPressRecognizer.minimumPressDuration = 0.15f;
        [cell.imageView addGestureRecognizer:longPressRecognizer];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapStar:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [cell.imageView addGestureRecognizer:tapRecognizer];
    }
    
//    Cell Content
    if (DEMO) {
        cell.textLabel.text = [_events objectAtIndex:indexPath.row];
        cell.imageView.image = [UIImage imageNamed:@"list-star-off"];
        cell.detailTextLabel.text = @"Today at 12:05PM, Room B202";
    } else {
        SOEvent *event = [_fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = event.title;
        cell.imageView.image = [UIImage imageNamed:@"list-star-off"];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MMM. d 'at' h:mma"];
        NSString *dateString = [df stringFromDate:event.start];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",dateString, event.location];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SOEventViewController *eventVC = [[SOEventViewController alloc] initWithNibName:@"SOEventViewController" bundle:nil];
    [self.navigationController pushViewController:eventVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [searchBar resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)didTapStar:(UITapGestureRecognizer*)g {
    NSLog(@"didTapStar");
    ((UIImageView *)g.view).image = [UIImage imageNamed:@"list-star-on"];
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
