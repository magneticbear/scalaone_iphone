//
//  SOProfileViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

// TODO (Optional): Better highlight feedback (too much lag)
// TODO (Optional): Convert name box to table

#import "SOProfileViewController.h"
#import "SOProfileInfoCell.h"
#import "SOChatViewController.h"

@interface SOProfileViewController ()
@property (nonatomic, strong) NSArray *profileCellHeaders;
@property (nonatomic, strong) NSArray *profileCellContents;
@property (nonatomic, strong) NSArray *profileCellContentPlaceholders;
@end

@implementation SOProfileViewController {
    BOOL isMyProfile;
}
@synthesize tableView = _tableView;
@synthesize nameBox = _nameBox;
@synthesize avatarEditImg = _avatarEditImg;
@synthesize profileCellHeaders = _profileCellHeaders;
@synthesize profileCellContents = _profileCellContents;
@synthesize profileCellContentPlaceholders = _profileCellContentPlaceholders;

- (id)initWithUser:(SOUser *)user
{
    self = [super init];
    if (self) {
        self.title = [NSString stringWithFormat:@"%@ %@",user.firstName,user.lastName];
        isMyProfile = NO;
    }
    return self;
}

- (id)initWithMe
{
    self = [super init];
    if (self) {
        self.title = @"My Profile";
        isMyProfile = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    Right bar button
    NSString *rightButtonTitle = isMyProfile ? @"Edit" : @"Meet up";
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:rightButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(didPressRightButton:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
//    Data
    [self setCellHeadersAndPlaceholders];
    [self setCellContents];
}

- (void)setCellHeadersAndPlaceholders {
    _profileCellHeaders = @[@"Twitter",@"Facebook",@"Phone",@"Email",@"Website"];
    _profileCellContentPlaceholders = @[@"@scalaone",@"facebook username",@"1-555-555-5555",@"email@example.com",@"example.com"];
}

- (void)setCellContents {
    _profileCellContents = @[@"@simjp",@"SimardJP",@"",@"jp@magneticbear.com",@""];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setNameBox:nil];
    [self setAvatarEditImg:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didPressRightButton:(id)sender {
    if (isMyProfile) {
        [self toggleEditing];
    } else {
        SOChatViewController *chatVC = [[SOChatViewController alloc] init];
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

- (void)toggleEditing {
    BOOL editing = !_tableView.editing;
    
    //    Reload table in editing mode
    _tableView.editing = editing;
    [_tableView reloadData];
    
    //    Show/hide Cancel button
    if (editing) {
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(didPressRightButton:)];
        self.navigationItem.leftBarButtonItem = leftButton;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    self.navigationItem.rightBarButtonItem.title = editing ? @"Done" : @"Edit";
    
    //    Show/Hide name box and avatar edit image
    _nameBox.hidden = !editing;
    _avatarEditImg.hidden = !editing;
    
    //    Dismiss keyboard on done editing
    [self.view endEditing:!editing];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (_tableView.editing)
        return _profileCellHeaders.count;
    NSInteger cellsWithDataCount = 0;
    for (NSString *cellData in _profileCellContents) {
        if ([cellData length] > 0) cellsWithDataCount++;
    }
    return cellsWithDataCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SOProfileInfoCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"infoCell"];
    
    if (cell == nil || TRUE) {
        cell = [[SOProfileInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"infoCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
//    Set backgrounds for top and bottom cells (otherwise middle style is default)
    if (indexPath.row == 0) {
        cell.cellType = SOProfileInfoCellTypeTop;
    } else if (indexPath.row + 1 == [self tableView:tableView numberOfRowsInSection:indexPath.section]) {
        cell.cellType = SOProfileInfoCellTypeBottom;
    }
    
//    Set cell titles, content and placeholders for edit/read modes
    if (_tableView.editing) {
        cell.headerLabel.text = [_profileCellHeaders objectAtIndex:indexPath.row%_profileCellHeaders.count];
        cell.contentTextField.text = [_profileCellContents objectAtIndex:indexPath.row];
        cell.contentTextField.placeholder = [_profileCellContentPlaceholders objectAtIndex:indexPath.row];
        switch (indexPath.row) {
            case 0:
                cell.contentTextField.keyboardType = UIKeyboardTypeTwitter;
                break;
                
            case 1:
                cell.contentTextField.keyboardType = UIKeyboardTypeDefault;
                break;
                
            case 2:
                cell.contentTextField.keyboardType = UIKeyboardTypePhonePad;
                break;
                
            case 3:
                cell.contentTextField.keyboardType = UIKeyboardTypeEmailAddress;
                break;
                
            case 4:
                cell.contentTextField.keyboardType = UIKeyboardTypeURL;
                break;
                
            default:
                break;
        }
        cell.contentTextField.enabled = YES;
    } else {
        cell.headerLabel.text = [self headerTextForCell:indexPath.row];
        cell.contentTextField.text = [self contentTextForCell:indexPath.row];
        cell.contentTextField.enabled = NO;
    }
    
    return cell;
}

- (NSString *)headerTextForCell:(NSInteger)row {
    NSMutableArray *dataCellTitles = [[NSMutableArray alloc] initWithCapacity:_profileCellHeaders.count];
    //    Get non-empty data cell titles
    [_profileCellContents enumerateObjectsUsingBlock:^(NSString *cellContent, NSUInteger idx, BOOL *stop) {
        if (cellContent.length) {
            [dataCellTitles addObject:[_profileCellHeaders objectAtIndex:idx]];
        }
    }];
    return [dataCellTitles objectAtIndex:row%dataCellTitles.count];
}

- (NSString *)contentTextForCell:(NSInteger)row {
    NSMutableArray *dataCells = [[NSMutableArray alloc] initWithCapacity:_profileCellHeaders.count];
    //    Get non-empty data cell contents
    [_profileCellContents enumerateObjectsUsingBlock:^(NSString *cellContent, NSUInteger idx, BOOL *stop) {
        if (cellContent.length > 0) {
            [dataCells addObject:cellContent];
        }
    }];
    return [dataCells objectAtIndex:row];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath: %d",indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didTapAvatar:(UITapGestureRecognizer*)g {
    NSLog(@"didTapAvatar");
}

@end
