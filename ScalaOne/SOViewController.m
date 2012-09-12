//
//  SOViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/26/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOViewController.h"

@interface SOViewController ()

@end

@implementation SOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:25.0]];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:242.0/255.0 green:250.0/255.0 blue:252.0/255.0 alpha:1.0];
    label.shadowColor = [UIColor colorWithRed:10.0/255.0 green:137.0/255.0 blue:179.0/255.0 alpha:1.0];
    label.text = self.title;
    [label sizeToFit];
    self.navigationItem.titleView = label;
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

@end
