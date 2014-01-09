//
//  MasterViewController.m
//  wheelyTest
//
//  Created by Artem Abramov on 1/9/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "NetworkLoader.h"

NSString* const kReusableCellIdentifier = @"cellTableView";

@interface MasterViewController ()<UITableViewDataSource, UITableViewDelegate, NetworkLoaderProtocol>

@property(nonatomic, strong) UITableView *tableView;

@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [NetworkLoader shared].delegate = self;
    
    //TableView
    CGRect rect = CGRectMake(0, 0,
                              CGRectGetWidth(self.view.bounds),
                              CGRectGetHeight(self.view.bounds));
    self.tableView = [[UITableView alloc] initWithFrame:rect
                                                  style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    self.title = @"Crazy Wheel";
    
    //Top Right Button
    UIBarButtonItem *reloadButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                      target:self
                                                      action:@selector(reloadButtonPressed:)];
    self.navigationItem.rightBarButtonItem = reloadButtonItem;
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReusableCellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:kReusableCellIdentifier];
    }
    
    NSMutableArray *keys = [[NetworkLoader shared].recordsStorage.allKeys mutableCopy];

    
    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [keys sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    
    NSNumber *currentRecordID = keys[indexPath.row];
    
    NetworkRecord *record = [[NetworkLoader shared].recordsStorage objectForKey:currentRecordID];
    cell.textLabel.text = record.title;
    cell.detailTextLabel.text = record.text;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [NetworkLoader shared].recordsStorage.count;
}

#pragma mark - Actions
- (void)reloadButtonPressed:(id)sender
{
    [[NetworkLoader shared] forceUpdate];
}

#pragma mark - NetworkLoaderProtocol
- (void)recordWasPurged:(NSNumber*)recordID
{
    //TODO: remove records with animation
    [self.tableView reloadData];
}

- (void)recordWasAdded:(NSNumber*)recordID
{
    //TODO: add records with animation
    [self.tableView reloadData];
}


@end
