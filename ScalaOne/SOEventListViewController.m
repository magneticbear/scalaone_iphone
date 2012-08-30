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

@interface SOEventListViewController ()
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
    _events = @[@"Talk 1",@"Talk 2",@"Talk 3",@"Talk 4",@"Talk 5",@"Talk 6",@"Talk 7",@"Talk 8",@"Talk 9",@"Talk 10",@"Talk 11",@"Talk 12"];
    _searchBar.placeholder = @"Find events";
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _events.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
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
    }
//    Cell Content
    cell.textLabel.text = [_events objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"list-star-%@",indexPath.row%2 ? @"on" : @"off"]];
    cell.detailTextLabel.text = @"Today at 12:05PM, Room B202";
    
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

@end
