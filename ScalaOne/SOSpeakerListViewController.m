//
//  SOSpeakerListViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

// TODO: Move all cell stuff to cell class
// TODO: Check all fringe cases for avatarState

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
    _tableView.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1];
    _speakers = @[@"Speaker 1",@"Speaker 2",@"Speaker 3",@"Speaker 4",@"Speaker 5",@"Speaker 6",@"Speaker 7",@"Speaker 8",@"Speaker 9",@"Speaker 10",@"Speaker 11",@"Speaker 12"];
    _searchBar.placeholder = @"Find speakers";
    _avatarState = SOAvatarStateDefault;
    ((SOUniqueTouchView*)self.view).viewDelegate = self;
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
    return _speakers.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    Setup header label style and text
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
//    Remove this later
    NSArray *cellAvatars = @[@"list-avatar-mo",@"list-avatar-jp",@"list-avatar-mo",@"list-avatar-speaker",@"list-avatar-favorite"];
    
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
//    Content
    cell.textLabel.text = [_speakers objectAtIndex:indexPath.row];
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
        [self performSelector:@selector(cancelAvatar) withObject:nil afterDelay:0.15f];
        return;
    }
    _avatarState = SOAvatarStateAnimatingToFavorite;
    _currentAvatar = nil;
    [UIView animateWithDuration:0.33f delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         CATransform3D frontTransform = CATransform3DIdentity;
                         frontTransform.m34 = 1.0 / -850.0;
                         frontTransform = CATransform3DMakeRotation(M_PI_2,0.0,1.0,0.0); //flip halfway
                         frontTransform = CATransform3DScale(frontTransform, 0.835, 0.835, 0.835);
                         gestureRecognizer.view.layer.transform = frontTransform;
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             ((UIImageView*)gestureRecognizer.view).image = [UIImage imageNamed:@"list-avatar-favorite"];
                             [UIView animateWithDuration:0.33f
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseOut
                                              animations:^{
                                                  CATransform3D backTransform = CATransform3DIdentity;
                                                  backTransform.m34 = 0.0f;
                                                  backTransform = CATransform3DMakeRotation(M_PI,0.0,1.0,0.0); //finish the flip
                                                  backTransform = CATransform3DScale(backTransform, 1.0, 1.0, 1.0);
                                                  gestureRecognizer.view.layer.transform = backTransform;
                                              }
                                              completion:^(BOOL finished){
                                                  _avatarState = SOAvatarStateFavorite;
                                                  _currentAvatar = (UIImageView *)gestureRecognizer.view;
                                              }
                              ];
                         }
                     }
     ];
}

- (void)cancelAvatar {
    _avatarState = SOAvatarStateAnimatingToDefault;
    [UIView animateWithDuration:0.33f delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         CATransform3D frontTransform = CATransform3DIdentity;
                         frontTransform.m34 = 1.0 / -850.0;
                         frontTransform = CATransform3DMakeRotation(-M_PI_2,0.0,1.0,0.0); //flip halfway
                         frontTransform = CATransform3DScale(frontTransform, 0.835, 0.835, 0.835);
                         _currentAvatar.layer.transform = frontTransform;
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             _currentAvatar.image = [UIImage imageNamed:@"list-avatar-mo"];
                             [UIView animateWithDuration:0.33f
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseOut
                                              animations:^{
                                                  CATransform3D backTransform = CATransform3DIdentity;
                                                  backTransform.m34 = 0.0f;
                                                  backTransform = CATransform3DMakeRotation(0.0,0.0,1.0,0.0); //finish the flip
                                                  backTransform = CATransform3DScale(backTransform, 1.0, 1.0, 1.0);
                                                  _currentAvatar.layer.transform = backTransform;
                                              }
                                              completion:^(BOOL finished){
                                                  _avatarState = SOAvatarStateDefault;
                                                  _currentAvatar = nil;
                                              }
                              ];
                         }
                     }
     ];
}

- (UIView *)view:(SOUniqueTouchView *)view hitTest:(CGPoint)point
       withEvent:(UIEvent *)event hitView:(UIView *)hitView;
{
//    NSLog(@"_avatarState: %d\nhitView: %@",_avatarState,hitView);
//    If the avatar is in default state, or the user is tapping the "favorite" image
    if (_avatarState == SOAvatarStateDefault ||
        (hitView == _currentAvatar && _avatarState == SOAvatarStateFavorite)) {
        return hitView;
    } else if (_avatarState == SOAvatarStateFavorite && hitView != _currentAvatar) {
//        NSLog(@"_currentAvatar: %@",_currentAvatar);
        [self cancelAvatar];
    }
    
    return nil;
}

@end
