//
//  SOSpeakerListViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOSpeakerListViewController.h"
#import "SOSpeakerViewController.h"

@interface SOSpeakerListViewController ()
    @property (nonatomic, strong) NSArray *speakers;
@end

@implementation SOSpeakerListViewController
@synthesize tableView = _tableView;
@synthesize searchBar = _searchBar;
@synthesize speakers = _speakers;

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    cell.textLabel.text = [_speakers objectAtIndex:indexPath.row];
    NSArray *cellAvatars = @[@"list-avatar-mo",@"list-avatar-jp",@"list-avatar-mo",@"list-avatar-speaker",@"list-avatar-favorite"];
    cell.imageView.image = [UIImage imageNamed:[cellAvatars objectAtIndex:indexPath.row%cellAvatars.count]];
    
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

@end
