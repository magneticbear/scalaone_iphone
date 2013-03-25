//
//  SOProfileViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//  http://www.magneticbear.com

// TODO (Optional): Better highlight feedback (too much lag)
// TODO (Optional): Convert name box to table
// TODO (Optional): Persistent @ symbol for twitter textfield

#import "SOProfileViewController.h"
#import "SOProfileInfoCell.h"
#import "SOChatViewController.h"
#import "SDWebImageManager.h"
#import "UIImage+SOAvatar.h"
#import "SOHTTPClient.h"
#import "SVProgressHUD.h"
#import "NSString+SOAdditions.h"
#import "UIAlertView+Blocks.h"
#import "UIActionSheet+Blocks.h"

@interface SOProfileViewController () {
    NSManagedObjectContext *moc;
}
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
@synthesize currentUser = _currentUser;
@synthesize firstNameField = _firstNameField;
@synthesize lastNameField = _lastNameField;
@synthesize nameLabel = _nameLabel;
@synthesize avatarBtn = _avatarBtn;
@synthesize imgPicker = _imgPicker;

- (id)init {
    self = [super init];
    if (self) {
        moc = [(id)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    return self;
}

- (id)initWithUser:(SOUser *)user {
    if (user.isMe.boolValue) {
        return [self initWithMe];
    }
    self = [self init];
    if (self) {
        self.title = [NSString stringWithFormat:@"%@ %@",user.firstName,user.lastName];
        isMyProfile = NO;
        _currentUser = user;
    }
    return self;
}

- (id)initWithMe {
    self = [self init];
    if (self) {
        self.title = kSOScreenTitleMyProfile;
        isMyProfile = YES;
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:moc]];
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"isMe == YES"]];
        
        NSArray *results = [moc executeFetchRequest:request error:nil];
        
        if (results.count) {
            _currentUser = [results lastObject];
        } else {
            SOUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc];
            user.isMe = @YES;
            [self saveContext];
            _currentUser = user;
        }
    }
    return self;
}

- (IBAction)didPressAvatar:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        RIButtonItem *cameraButton = [RIButtonItem itemWithLabel:@"Take Photo"];
        cameraButton.action = ^{
            _imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:_imgPicker animated:YES completion:nil];
        };
        
        RIButtonItem *libraryButton = [RIButtonItem itemWithLabel:@"Choose Existing"];
        libraryButton.action = ^{
            _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:_imgPicker animated:YES completion:nil];
        };
        
        RIButtonItem *cancelButton = [RIButtonItem itemWithLabel:@"Cancel"];
        
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:cancelButton destructiveButtonItem:nil otherButtonItems:cameraButton,libraryButton,nil];
        
        [actionsheet showInView:self.view];
        
        return;
    }
    
    _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:_imgPicker animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    if (kSOAnalyticsEnabled) [[Mixpanel sharedInstance] track:self.title];
    
    // Right bar button
    NSString *rightButtonTitle = isMyProfile ? @"Edit" : @"Chat";
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:rightButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(didPressRightButton:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // Data
    [self setCellHeadersAndPlaceholders];
    [self setCellContents];
    
    if (isMyProfile) {
        _imgPicker = [[UIImagePickerController alloc] init];
        _imgPicker.delegate = self;
        _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imgPicker.allowsEditing = YES;
        
        _firstNameField.tag = SOProfileCellTypeFirstName;
        _firstNameField.delegate = self;
        _firstNameField.accessibilityLabel = @"First";
        _lastNameField.tag = SOProfileCellTypeLastName;
        _lastNameField.delegate = self;
        
        [_avatarBtn setBackgroundImage:[UIImage avatarWithSource:[UIImage imageWithContentsOfFile:[self myAvatarPath]] type:SOAvatarTypeLarge] forState:UIControlStateNormal];
        
        if (_currentUser.remoteID.integerValue == 0) {
            [self toggleEditing];
        }
    } else {
        [_avatarBtn setBackgroundImage:[UIImage avatarWithSource:nil type:SOAvatarTypeLarge] forState:UIControlStateNormal];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:[NSURL URLWithString:[NSString stringWithFormat:kSOImageURLFormatForUser,kSOAPIHost,_currentUser.remoteID.integerValue]]
                         options:0
                        progress:nil
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                           if (finished && !error) [_avatarBtn setBackgroundImage:[UIImage avatarWithSource:image type:SOAvatarTypeLarge] forState:UIControlStateNormal];
                       }];
    }
}

- (void)setCellHeadersAndPlaceholders {
    _profileCellHeaders = @[@"Twitter",@"Facebook",@"Phone",@"Email",@"Website"];
    _profileCellContentPlaceholders = @[@"@scalaone",@"facebook username",@"1-555-555-5555",@"email@example.com",@"example.com"];
}

- (void)setCellContents {
    _profileCellContents = @[_currentUser.twitter ? _currentUser.twitter : @"",
    _currentUser.facebook ? _currentUser.facebook : @"",
    _currentUser.phone ? _currentUser.phone : @"",
    _currentUser.email ? _currentUser.email : @"",
    _currentUser.website ? _currentUser.website : @""];
    
    _nameLabel.text = [NSString stringWithFormat:@"%@ %@",_currentUser.firstName ? _currentUser.firstName : @"", _currentUser.lastName ? _currentUser.lastName : @""];
    _firstNameField.text = _currentUser.firstName ? _currentUser.firstName : @"";
    _lastNameField.text = _currentUser.lastName ? _currentUser.lastName : @"";
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setNameBox:nil];
    [self setAvatarEditImg:nil];
    [self setFirstNameField:nil];
    [self setLastNameField:nil];
    [self setNameLabel:nil];
    [self setAvatarBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Don't reset data if displaying imgPicker
    if (!self.modalViewController) {
        [[NSFileManager defaultManager] removeItemAtPath:[self myNewAvatarPath] error:nil];
        // Hitting back before profile is created
        if (isMyProfile) [moc reset];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didPressRightButton:(UIBarButtonItem *)sender {
    if (isMyProfile) {
        [self toggleEditing];
    } else {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:moc]];
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"isMe == YES && remoteID != nil"]];
        
        NSArray *results = [moc executeFetchRequest:request error:nil];
        
        if (results.count) {
            SOUser *me = [results lastObject];
            SOChatViewController *chatVC = [[SOChatViewController alloc]
                                            initWithChatURL:[NSString privateChatURLWithSenderID:me.remoteID.integerValue
                                                                                        targetID:_currentUser.remoteID.integerValue]
                                            andPusherChannel:[NSString privateChannelNameWithSenderID:me.remoteID.integerValue
                                                              targetID:_currentUser.remoteID.integerValue]];
            [self.navigationController pushViewController:chatVC animated:YES];
        } else {
            UIAlertView *noProfileAlert = [[UIAlertView alloc] initWithTitle:@"No Profile" message:@"Please create a TypesafeCon profile to enable chat." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [noProfileAlert show];
        }
    }
}

- (void)didCancelEditing {
    // Dismiss keyboard on done editing
    [self.view endEditing:YES];
    [[NSFileManager defaultManager] removeItemAtPath:[self myNewAvatarPath] error:nil];
    [moc rollback];
    [self setCellContents];
    
    BOOL editing = NO;
    
    // Reload table in editing mode
    _tableView.editing = editing;
    [_tableView reloadData];
    
    // Show/hide Cancel button
    if (editing && _currentUser.remoteID.boolValue) {
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(didPressRightButton:)];
        self.navigationItem.leftBarButtonItem = leftButton;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    self.navigationItem.rightBarButtonItem.title = editing ? @"Done" : @"Edit";
    
    // Show/Hide name box and avatar edit image
    _nameBox.hidden = !editing;
    _avatarEditImg.hidden = !editing;
    
    // Enable avatar button only when editing
    _avatarBtn.enabled = editing;
}

- (void)toggleEditing {
    BOOL editing = !_tableView.editing;
    
    // Dismiss keyboard on done editing
    [self.view endEditing:!editing];
    
    if (!editing) {
        // Check if first name is missing or if email is invalid
        if (!_currentUser.email.length || !_currentUser.firstName.length) {
            UIAlertView *missingFieldAlert = [[UIAlertView alloc] initWithTitle:@"Missing field" message:@"Your profile must contain at least a first name and a valid email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [missingFieldAlert show];
            return;
        } else if (_currentUser.email.length && ![self validateEmail:_currentUser.email]) {
            UIAlertView *invalidEmailAlert = [[UIAlertView alloc] initWithTitle:@"Email invalid" message:@"Please enter a valid email address to save your profile." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [invalidEmailAlert show];
            return;
        }
        
        [self setCellContents];
        [self saveContext];
        
        if (_currentUser.remoteID.integerValue == 0) {
            [self postCurrentUserToAPI];
        } else {
            [self putCurrentUserToAPI];
        }
    }
    
    // Reload table in editing mode
    _tableView.editing = editing;
    [_tableView reloadData];
    
    // Show/hide Cancel button
    if (editing && _currentUser.remoteID.boolValue) {
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(didCancelEditing)];
        self.navigationItem.leftBarButtonItem = leftButton;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    self.navigationItem.rightBarButtonItem.title = editing ? @"Done" : @"Edit";
    
    // Show/Hide name box and avatar edit image
    _nameBox.hidden = !editing;
    _avatarEditImg.hidden = !editing;
    
    // Enable avatar button only when editing
    _avatarBtn.enabled = editing;
}

- (void)postCurrentUserToAPI {
    [SVProgressHUD showWithStatus:@"Saving changes..." maskType:SVProgressHUDMaskTypeClear];
    [[SOHTTPClient sharedClient] createUser:_currentUser success:^(AFJSONRequestOperation *operation, id responseObject) {
        if ([[responseObject objectForKey:@"message"] isEqualToString:@"success"]) {
            _currentUser.remoteID = [NSNumber numberWithInt:
                                     [[[responseObject objectForKey:@"result"]
                                       objectForKey:@"id"] intValue]];
            [self saveContext];
            
            if ([self shouldUploadAvatar]) {
                [self uploadImage];
            } else {
                [SVProgressHUD showSuccessWithStatus:@"Changes saved successfully."];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Server could not be reached."];
    }];
}

- (void)putCurrentUserToAPI {
    [SVProgressHUD showWithStatus:@"Saving changes..." maskType:SVProgressHUDMaskTypeClear];
    [[SOHTTPClient sharedClient] updateUser:_currentUser success:^(AFJSONRequestOperation *operation, id responseObject) {
        if ([[responseObject objectForKey:@"result"] isEqualToString:@"Success"]) {
            [self saveContext];
            if ([self shouldUploadAvatar]) {
                [self uploadImage];
            } else {
                [SVProgressHUD showSuccessWithStatus:@"Changes saved successfully."];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Server could not be reached."];
    }];
}

- (void)uploadImage {
    [SVProgressHUD showWithStatus:@"Uploading image..." maskType:SVProgressHUDMaskTypeClear];
    [[SOHTTPClient sharedClient] postImage:[UIImage imageWithContentsOfFile:[self myNewAvatarPath]] forUserID:_currentUser.remoteID.integerValue success:^(AFJSONRequestOperation *operation, id responseObject) {
        [[NSFileManager defaultManager] moveItemAtPath:[self myNewAvatarPath] toPath:[self myAvatarPath] error:nil];
        [SVProgressHUD showSuccessWithStatus:@"Image uploaded successfully."];
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Server could not be reached."];
    }];
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
    
    // Set backgrounds for top and bottom cells (otherwise middle style is default)
    if (indexPath.row == 0) {
        cell.cellType = SOProfileInfoCellTypeTop;
    } else if (indexPath.row + 1 == [self tableView:tableView numberOfRowsInSection:indexPath.section]) {
        cell.cellType = SOProfileInfoCellTypeBottom;
    }
    
    // Set cell titles, content and placeholders for edit/read modes
    if (_tableView.editing) {
        cell.headerLabel.text = [_profileCellHeaders objectAtIndex:indexPath.row%_profileCellHeaders.count];
        cell.contentTextField.text = [_profileCellContents objectAtIndex:indexPath.row];
        cell.contentTextField.placeholder = [_profileCellContentPlaceholders objectAtIndex:indexPath.row];
        switch (indexPath.row) {
            case 0:
                cell.contentTextField.tag = SOProfileCellTypeTwitter;
                cell.contentTextField.keyboardType = UIKeyboardTypeTwitter;
                break;
                
            case 1:
                cell.contentTextField.tag = SOProfileCellTypeFacebook;
                cell.contentTextField.keyboardType = UIKeyboardTypeDefault;
                break;
                
            case 2:
                cell.contentTextField.tag = SOProfileCellTypePhone;
                cell.contentTextField.keyboardType = UIKeyboardTypePhonePad;
                break;
                
            case 3:
                cell.contentTextField.tag = SOProfileCellTypeEmail;
                cell.contentTextField.keyboardType = UIKeyboardTypeEmailAddress;
                break;
                
            case 4:
                cell.contentTextField.tag = SOProfileCellTypeWebsite;
                cell.contentTextField.keyboardType = UIKeyboardTypeURL;
                break;
                
            default:
                break;
        }
        cell.contentTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        cell.contentTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        cell.contentTextField.delegate = self;
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
    // Get non-empty data cell titles
    [_profileCellContents enumerateObjectsUsingBlock:^(NSString *cellContent, NSUInteger idx, BOOL *stop) {
        if (cellContent.length) {
            [dataCellTitles addObject:[_profileCellHeaders objectAtIndex:idx]];
        }
    }];
    return [dataCellTitles objectAtIndex:row%dataCellTitles.count];
}

- (NSString *)contentTextForCell:(NSInteger)row {
    NSMutableArray *dataCells = [[NSMutableArray alloc] initWithCapacity:_profileCellHeaders.count];
    // Get non-empty data cell contents
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Don't do anything if isMyProfile
    if (isMyProfile) return;
    
    // Otherwise, launch appropriate action
    __block NSMutableArray *nonEmptyArray = [NSMutableArray arrayWithCapacity:_profileCellContents.count];
    [_profileCellContents enumerateObjectsUsingBlock:^(NSString *string, NSUInteger idx, BOOL *stop) {
        if (![string isEqualToString:@""]) {
            [nonEmptyArray addObject:[NSNumber numberWithInt:idx]];
        }
    }];
    
    NSInteger selectedIndex = [[nonEmptyArray objectAtIndex:indexPath.row] integerValue];
    
    NSString *urlString = [_profileCellContents objectAtIndex:selectedIndex];
    
    NSString *alertString = kSOLeavingAppAlertString;
    
    switch (selectedIndex) {
        // Twitter
        case 0:
        {
            // Remove @ symbol if present
            urlString = [urlString stringByReplacingOccurrencesOfString:@"@" withString:@""];
            urlString = [NSString stringWithFormat:@"https://twitter.com/%@",urlString];
            NSString *alertString2 = [NSString stringWithFormat:kSOLeavingAppTwitter,self.title];
            alertString = [NSString stringWithFormat:alertString,alertString2];
            break;
        }
            
        // Facebook
        case 1:
        {
            urlString = [NSString stringWithFormat:@"https://facebook.com/%@",urlString];
            NSString *alertString2 = [NSString stringWithFormat:kSOLeavingAppFacebook,self.title];
            alertString = [NSString stringWithFormat:alertString,alertString2];
        }
            break;
            
        // Phone
        case 2:
        {
            urlString = [NSString stringWithFormat:@"tel://%@",urlString];
            NSString *alertString2 = [NSString stringWithFormat:kSOLeavingAppPhone,self.title];
            alertString = [NSString stringWithFormat:alertString,alertString2];
        }
            break;
            
        // Email
        case 3:
        {
            urlString = [NSString stringWithFormat:@"mailto://%@",urlString];
            NSString *alertString2 = [NSString stringWithFormat:kSOLeavingAppEmail,self.title];
            alertString = [NSString stringWithFormat:alertString,alertString2];
        }
            break;
            
        // Website
        case 4:
        {
            // Add HTTP scheme if necessary
            if ([urlString rangeOfString:@"://"].location == NSNotFound) {
                urlString = [NSString stringWithFormat:@"http://%@",urlString];
            }
            NSString *alertString2 = [NSString stringWithFormat:kSOLeavingAppWebsite,self.title];
            alertString = [NSString stringWithFormat:alertString,alertString2];
        }
            break;
            
        default:
            break;
    }
    
    RIButtonItem *yesButton = [RIButtonItem itemWithLabel:@"Yes"];
    yesButton.action = ^{
        NSURL *profileURL = [NSURL URLWithString:urlString];
        
        // If scheme is HTTP or HTTPS and Chrome is installed, open in Chrome
        // Otherwise, open in default app
        if ([profileURL.scheme rangeOfString:kSOHTTPScheme].location != NSNotFound &&
            [[UIApplication sharedApplication] canOpenURL:
             [NSURL URLWithString:[NSString stringWithFormat:@"%@://",kSOGoogleChromeScheme]]]) {
                NSString *scheme = profileURL.scheme;
                
                // Replace the URL Scheme with the Chrome equivalent.
                NSString *chromeScheme = nil;
                if ([scheme isEqualToString:kSOHTTPScheme]) {
                    chromeScheme = kSOGoogleChromeScheme;
                } else if ([scheme isEqualToString:kSOHTTPSchemeSecure]) {
                    chromeScheme = kSOGoogleChromeSchemeSecure;
                } else {
                    [[UIApplication sharedApplication] openURL:profileURL];
                }
                
                // Proceed only if a valid Google Chrome URI Scheme is available.
                if (chromeScheme) {
                    NSString *absoluteString = [profileURL absoluteString];
                    NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
                    NSString *urlNoScheme =
                    [absoluteString substringFromIndex:rangeForScheme.location];
                    NSString *chromeURLString =
                    [chromeScheme stringByAppendingString:urlNoScheme];
                    NSURL *chromeURL = [NSURL URLWithString:chromeURLString];
                    
                    // Open the URL with Chrome.
                    [[UIApplication sharedApplication] openURL:chromeURL];
                }
                
                // Everything else
            } else {
                [[UIApplication sharedApplication] openURL:profileURL];
            }
    };
    
    RIButtonItem *noButton = [RIButtonItem itemWithLabel:@"No"];
    
    UIAlertView *leaveAppAlert = [[UIAlertView alloc] initWithTitle:kSOLeavingAppAlertTitle message:alertString cancelButtonItem:noButton otherButtonItems:yesButton, nil];
    [leaveAppAlert show];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case SOProfileCellTypeFirstName:
            _currentUser.firstName = textField.text;
            break;
            
        case SOProfileCellTypeLastName:
            _currentUser.lastName = textField.text;
            break;
            
        case SOProfileCellTypeTwitter:
            _currentUser.twitter = textField.text;
            break;
            
        case SOProfileCellTypeFacebook:
            _currentUser.facebook = textField.text;
            break;
            
        case SOProfileCellTypePhone:
            _currentUser.phone = textField.text;
            break;
            
        case SOProfileCellTypeEmail:
            _currentUser.email = textField.text;
            break;
            
        case SOProfileCellTypeWebsite:
            _currentUser.website = textField.text;
            break;
            
        default:
            NSLog(@"default");
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    // Resize image to reduce UL/DL time
    image = [UIImage imageWithImage:image scaledToSize:CGSizeMake(160, 160)];
    
    [_avatarBtn setBackgroundImage:[UIImage avatarWithSource:image type:SOAvatarTypeLarge] forState:UIControlStateNormal];
    
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:[self myNewAvatarPath] atomically:YES];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (NSString*)myAvatarPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/my_avatar.jpg"];
}

- (NSString*)myNewAvatarPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/my_avatar_new.jpg"];
}

#pragma mark - Core Data

- (void)saveContext {
    NSError *error = nil;
    if ([moc hasChanges] && ![moc save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

#pragma mark - Utitilies

- (BOOL)validateEmail:(NSString *)candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

- (BOOL)shouldUploadAvatar {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self myNewAvatarPath]];
}

@end
