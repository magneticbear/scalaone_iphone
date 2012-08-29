//
//  SOSpeakerListViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

// TODO: Move all cell stuff to cell class
// TODO (Optional): Improve way alphabet and section content is generated

#import "SOSpeakerListViewController.h"
#import "SOSpeakerViewController.h"
#import "SOListHeaderLabel.h"

static inline double radians (double degrees) {return degrees * M_PI/180;}

@interface SOSpeakerListViewController ()
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
//    Mock Speakers (sorted alphabetically)
    _speakers = @[@"Abraham Lincoln",@"Franklin D. Roosevelt",@"George Washington",@"Thomas Jefferson",@"Theodore Roosevelt",@"Woodrow Wilson",@"Harry S. Truman",@"Andrew Jackson",@"Dwight D. Eisenhower",@"James K. Polk",@"John F. Kennedy",@"John Adams",@"James Madison",@"James Monroe",@"Lyndon B. Johnson",@"Barack Obama",@"Ronald Reagan",@"John Quincy Adams",@"Grover Cleveland",@"William McKinley",@"Bill Clinton",@"William Howard Taft",@"George H. W. Bush"];
    _speakers = [_speakers sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
//    Setup
    _searchBar.placeholder = @"Find speakers";
    _avatarState = SOAvatarStateDefault;
    ((SOUniqueTouchView*)self.view).viewDelegate = self;
    
//    Alpha list
    NSMutableArray *preAlphabet = [[NSMutableArray alloc] initWithCapacity:26];
    for (NSString *speaker in _speakers) {
        if ([preAlphabet indexOfObject:[speaker substringToIndex:1].uppercaseString] == NSNotFound) {
            [preAlphabet addObject:[speaker substringToIndex:1].uppercaseString];
        }
    }
    _alphabet = [preAlphabet copy];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
//    return [_speakers count];
    // Return the number of rows in the section.
    int count=0;
    for (NSString *speaker in _speakers) {
        if ([[speaker substringToIndex:1].uppercaseString rangeOfString:[_alphabet objectAtIndex:sectionIndex]].location != NSNotFound) {
            count++;
        }
    }
    return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_alphabet count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([_alphabet count] <= 4) {
        return nil;
    }
    return _alphabet;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_alphabet objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [_alphabet indexOfObject:title];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    Setup header label style and text
    UILabel *headerTitleLabel = [[SOListHeaderLabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 24)];
    headerTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:16.0f];
    headerTitleLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.42f];
    headerTitleLabel.textColor = [UIColor whiteColor];
    headerTitleLabel.shadowOffset = CGSizeMake(0, -1);
    headerTitleLabel.text = [_alphabet objectAtIndex:section];
    [headerTitleLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"list-category-repeat"]]];
    return headerTitleLabel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    Remove this later
    NSArray *cellAvatars = @[@"list-avatar-mo",@"list-avatar-jp",@"list-avatar-speaker"];
    
    NSString *cellIdentifier = @"SpeakerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
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
    }
    NSMutableArray *mSpeakers = [[NSMutableArray alloc] initWithCapacity:[_speakers count]];
    for (NSString *speaker in _speakers) {
        if ([[speaker substringToIndex:1].uppercaseString rangeOfString:[_alphabet objectAtIndex:indexPath.section]].location != NSNotFound) {
            [mSpeakers addObject:speaker];
        }
    }
//    Content
    cell.textLabel.text = [mSpeakers objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[cellAvatars objectAtIndex:indexPath.row%cellAvatars.count]];
    
//    Make imageView tappable
    cell.imageView.tag = indexPath.row;
    cell.imageView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] init];
    longPressRecognizer.minimumPressDuration = 0.15f;
    [cell.imageView addGestureRecognizer:longPressRecognizer];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAvatar:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [cell.imageView addGestureRecognizer:tapRecognizer];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SOSpeakerViewController *speakerVC = [[SOSpeakerViewController alloc] initWithNibName:@"SOSpeakerViewController" bundle:nil];
    [self.navigationController pushViewController:speakerVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    NSLog(@"searchBarTextDidBeginEditing");
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
//    NSLog(@"searchBarTextDidEndEditing");
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [searchBar resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)didTapAvatar:(UIGestureRecognizer *)gestureRecognizer {
    if (_avatarState == SOAvatarStateFavorite) {
        ((UIImageView *)gestureRecognizer.view).image = [UIImage imageNamed:@"list-avatar-favorite-on"];
        [self performSelector:@selector(dismissAvatar) withObject:nil afterDelay:0.15f];
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

- (void)dismissAvatar {
    _avatarState = SOAvatarStateAnimatingToDefault;
    [UIView transitionWithView:_currentAvatar
                      duration:0.66f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        _currentAvatar.image = [UIImage imageNamed:@"list-avatar-mo"];
                    }
                    completion:^(BOOL finished){
                        _avatarState = SOAvatarStateDefault;
                        _currentAvatar = nil;
                    }];
}

- (UIView *)view:(SOUniqueTouchView *)view hitTest:(CGPoint)point withEvent:(UIEvent *)event hitView:(UIView *)hitView {
    
//    If the avatar is in default state, or the user is tapping the "favorite" image
    if (_avatarState == SOAvatarStateDefault ||
        (hitView == _currentAvatar && _avatarState == SOAvatarStateFavorite)) {
        return hitView;
    } else if (_avatarState == SOAvatarStateFavorite && hitView != _currentAvatar) {
        [self dismissAvatar];
    }
    
    return nil;
}

@end
