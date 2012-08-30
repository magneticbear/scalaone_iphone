//
//  SOProfileViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOProfileViewController.h"
#define kCellIdentifier @"infoCell"

@interface SOProfileViewController ()
    @property (nonatomic, strong) NSArray *profileCells;
    @property (nonatomic, strong) NSArray *profileCellContents;
@end

@implementation SOProfileViewController
@synthesize tableView = _tableView;
@synthesize profileCells = _profileCells;
@synthesize profileCellContents = _profileCellContents;

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
    self.title = @"My Profile";
    NSString *rightButtonTitle = FALSE ? @"Meet up" : @"Edit";
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:rightButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(didPressRightButton:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    _profileCells = @[@"Twitter",@"Facebook",@"Phone",@"Email",@"Website"];
    _profileCellContents = @[@"@simjp",@"",@"1-800-744-0098",@"",@""];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didPressRightButton:(id)sender {
    BOOL editing = !_tableView.editing;
    NSLog(@"didPressRightButton");
    [self.navigationItem setHidesBackButton:editing animated:YES];
    
//    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:_profileCells.count];
//    Get indices of empty array elements
//    [_profileCellContents enumerateObjectsUsingBlock:^(NSString *cellContent, NSUInteger idx, BOOL *stop) {
//        if (!cellContent.length) {
//            [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
//        }
//    }];
//    [_tableView beginUpdates];
    [_tableView setEditing:editing animated:NO];
//    if (editing) {
//        [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//    } else {
//        [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//    }
//    [_tableView endUpdates];
    [_tableView reloadData];

    self.navigationItem.rightBarButtonItem.title = editing ? @"Done" : @"Edit";
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (_tableView.editing)
        return _profileCells.count;
    NSInteger cellsWithDataCount = 0;
    for (NSString *cellData in _profileCellContents) {
        if ([cellData length] > 0) cellsWithDataCount++;
    }
    return cellsWithDataCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil || TRUE) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 160, 30)];
        NSMutableArray *dataCells = [[NSMutableArray alloc] initWithCapacity:_profileCells.count];
        //    Get non-empty data cell contents
        [_profileCellContents enumerateObjectsUsingBlock:^(NSString *cellContent, NSUInteger idx, BOOL *stop) {
            if (cellContent.length > 0) {
                [dataCells addObject:cellContent];
            }
        }];
        if (_tableView.editing) {
            tf.text = [_profileCellContents objectAtIndex:indexPath.row];
            tf.enabled = YES;
        } else {
            tf.text = [dataCells objectAtIndex:indexPath.row];
            tf.enabled = NO;
        }
        [cell addSubview:tf];
    }
    if (_tableView.editing)
        cell.textLabel.text = [_profileCells objectAtIndex:indexPath.row%_profileCells.count];
    else {
        NSMutableArray *dataCellTitles = [[NSMutableArray alloc] initWithCapacity:_profileCells.count];
        //    Get non-empty data cell titles
        [_profileCellContents enumerateObjectsUsingBlock:^(NSString *cellContent, NSUInteger idx, BOOL *stop) {
            if (cellContent.length) {
                [dataCellTitles addObject:[_profileCells objectAtIndex:idx]];
            }
        }];
        cell.textLabel.text = [dataCellTitles objectAtIndex:indexPath.row%dataCellTitles.count];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath: %d",indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
