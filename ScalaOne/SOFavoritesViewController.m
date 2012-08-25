//
//  SOFavoritesViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOFavoritesViewController.h"
#import "SOEventViewController.h"
#import "SOSpeakerViewController.h"

@interface SOFavoritesViewController ()
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
    self.title = @"Favorites";
    _tableView.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1];
    _events = @[@"Talk 1",@"Talk 2",@"Talk 3",@"Talk 4",@"Talk 5",@"Talk 6",@"Talk 7",@"Talk 8",@"Talk 9",@"Talk 10",@"Talk 11",@"Talk 12"];
    _speakers = @[@"Speaker 1",@"Speaker 2",@"Speaker 3",@"Speaker 4",@"Speaker 5",@"Speaker 6",@"Speaker 7",@"Speaker 8",@"Speaker 9",@"Speaker 10",@"Speaker 11",@"Speaker 12"];
    
    _segmentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"segment_bg"]];
    
    [self didSelectSegment:_segmentEventsBtn];
}

- (void)viewDidUnload
{
    [self setSegmentView:nil];
    [self setTableView:nil];
    [self setSegmentEventsBtn:nil];
    [self setSegmentSpeakersBtn:nil];
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
    return (currentSegment == SOFavoritesSegmentTypeEvents) ? _events.count : _speakers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentSegment == SOFavoritesSegmentTypeEvents) {
        NSString *cellIdentifier = @"EventCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.text = [_events objectAtIndex:indexPath.row];
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"list-star-%@",indexPath.row%2 ? @"on" : @"off"]];
        
        return cell;
    }   else if (currentSegment == SOFavoritesSegmentTypeSpeakers) {
        NSString *cellIdentifier = @"SpeakerCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.text = [_speakers objectAtIndex:indexPath.row];
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"list-star-%@",indexPath.row%2 ? @"on" : @"off"]];
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (currentSegment == SOFavoritesSegmentTypeEvents) {
        NSLog(@"selected %@",[_events objectAtIndex:indexPath.row]);
        SOEventViewController *eventVC = [[SOEventViewController alloc] initWithNibName:@"SOEventViewController" bundle:nil];
        [self.navigationController pushViewController:eventVC animated:YES];
    } else if (currentSegment == SOFavoritesSegmentTypeSpeakers) {
        NSLog(@"selected %@",[_speakers objectAtIndex:indexPath.row]);
        SOSpeakerViewController *speakerVC = [[SOSpeakerViewController alloc] initWithNibName:@"SOSpeakerViewController" bundle:nil];
        [self.navigationController pushViewController:speakerVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)didSelectSegment:(UIButton*)sender {
    NSLog(@"selected %@",sender.titleLabel.text);
    if (sender == _segmentEventsBtn) {
        [_segmentSpeakersBtn setHighlighted:NO];
        currentSegment = SOFavoritesSegmentTypeEvents;
    } else if (sender == _segmentSpeakersBtn) {
        [_segmentEventsBtn setHighlighted:NO];
        currentSegment = SOFavoritesSegmentTypeSpeakers;
    }
    [_tableView reloadData];
    [_tableView setContentOffset:CGPointMake(0, 0)];
    [self performSelector:@selector(doHighlight:) withObject:sender afterDelay:0];
}

- (void)doHighlight:(UIButton*)b {
    [b setHighlighted:YES];
}

@end
