//
//  SOSpeakerListViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOSpeakerListViewController.h"
#import "SOSpeakerViewController.h"
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
- (void)refetchData;
@property (nonatomic, strong) NSArray *speakers;
@end

@implementation SOSpeakerListViewController
@synthesize tableView = _tableView;
@synthesize searchBar = _searchBar;
@synthesize speakers = _speakers;
@synthesize avatarState = _avatarState;
@synthesize currentAvatar = _currentAvatar;
@synthesize alphabet = _alphabet;

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
    self.title = @"Speakers";
    
    _tableView.separatorColor = [UIColor colorWithWhite:0.85 alpha:1];
    
//    Setup
    _searchBar.placeholder = @"Find speakers";
    _avatarState = SOAvatarStateDefault;
    ((SOUniqueTouchView*)self.view).viewDelegate = self;
    
    if (DEMO) {
//        Mock Speakers (sorted alphabetically)
        _speakers = @[@"Abraham Lincoln",@"Franklin D. Roosevelt",@"George Washington",@"Thomas Jefferson",@"Theodore Roosevelt",@"Woodrow Wilson",@"Harry S. Truman",@"Andrew Jackson",@"Dwight D. Eisenhower",@"James K. Polk",@"John F. Kennedy",@"John Adams",@"James Madison",@"James Monroe",@"Lyndon B. Johnson",@"Barack Obama",@"Ronald Reagan",@"John Quincy Adams",@"Grover Cleveland",@"William McKinley",@"Bill Clinton",@"William Howard Taft",@"George H. W. Bush"];
        _speakers = [_speakers sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
//        Alpha list
        NSMutableArray *preAlphabet = [[NSMutableArray alloc] initWithCapacity:26];
        for (NSString *speaker in _speakers) {
            if ([preAlphabet indexOfObject:[speaker substringToIndex:1].uppercaseString] == NSNotFound) {
                [preAlphabet addObject:[speaker substringToIndex:1].uppercaseString];
            }
        }
        _alphabet = [preAlphabet copy];
    } else {
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
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Speaker"];
        NSSortDescriptor *nameInitialSortOrder = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:nameInitialSortOrder]];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:@"firstInitial" cacheName:@"Root"];
        _fetchedResultsController.delegate = self;
        [_fetchedResultsController performFetch:nil];
    }
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
    if (DEMO) {
        int count=0;
        for (NSString *speaker in _speakers) {
            if ([[speaker substringToIndex:1].uppercaseString rangeOfString:[_alphabet objectAtIndex:section]].location != NSNotFound) {
                count++;
            }
        }
        return count;
    }
    
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (DEMO) return [_alphabet count];
    
    return [[_fetchedResultsController sections] count];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerTitleLabel = [[SOListHeaderLabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 24)];
    headerTitleLabel.text = DEMO ? [_alphabet objectAtIndex:section] : [[[_fetchedResultsController sections] objectAtIndex:section] name];
    
    return headerTitleLabel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"SpeakerCell";
    SOSpeakerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[SOSpeakerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier favorite:NO];
        
//        Make imageView tappable
        cell.imageView.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] init];
        longPressRecognizer.minimumPressDuration = 0.15f;
        [cell.imageView addGestureRecognizer:longPressRecognizer];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAvatar:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [cell.imageView addGestureRecognizer:tapRecognizer];
    }
    
//    Content
    if (DEMO) {
        NSMutableArray *mSpeakers = [[NSMutableArray alloc] initWithCapacity:[_speakers count]];
        for (NSString *speaker in _speakers) {
            if ([[speaker substringToIndex:1].uppercaseString rangeOfString:[_alphabet objectAtIndex:indexPath.section]].location != NSNotFound) {
                [mSpeakers addObject:speaker];
            }
        }
//        Text
        cell.textLabel.text = [mSpeakers objectAtIndex:indexPath.row];
//        Image
        cell.imageView.image = [UIImage avatarWithSource:nil favorite:NO];
    } else {
//        Text
        SOSpeaker *speaker = [_fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = speaker.name;
        
//        Image
        cell.imageView.image = [UIImage avatarWithSource:nil favorite:SOAvatarFavoriteTypeOff];
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:
         [NSURL URLWithString:[NSString stringWithFormat:@"%@assets/img/profile/%d.jpg",kSOAPIHost,speaker.remoteID.integerValue]]
                        delegate:self
                         options:0
                         success:^(UIImage *image) {
                             cell.imageView.image = [UIImage avatarWithSource:image favorite:SOAvatarFavoriteTypeOff];
                         } failure:^(NSError *error) {
//                             NSLog(@"Image retrieval failed");
                         }];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SOSpeakerViewController *speakerVC = [[SOSpeakerViewController alloc] initWithNibName:@"SOSpeakerViewController" bundle:nil speaker:[_fetchedResultsController objectAtIndexPath:indexPath]];
    [self.navigationController pushViewController:speakerVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
                        _currentAvatar.image = [UIImage avatarWithSource:[UIImage imageNamed:@"jp.jpeg"] favorite:SOAvatarFavoriteTypeOn];
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
                        _currentAvatar.image = [UIImage avatarWithSource:[UIImage imageNamed:@"jp.jpeg"] favorite:SOAvatarFavoriteTypeOn];
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

- (void)refetchData {
    _fetchedResultsController.fetchRequest.resultType = NSManagedObjectResultType;
    [_fetchedResultsController performFetch:nil];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    _currentAvatar = nil;
    _avatarState = SOAvatarStateDefault;
    [_tableView reloadData];
}

@end
