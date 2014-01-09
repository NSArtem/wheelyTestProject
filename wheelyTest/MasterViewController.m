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
@property(nonatomic, strong) UIView *overlayView;

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
    
    [self displayOverlay:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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
    
    NetworkRecord *record = [self networkRecordForIndexPath:indexPath];
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
    [self displayOverlay:NO];
}

- (void)recordWasAdded:(NSNumber*)recordID
{
    //TODO: add records with animation
    [self.tableView reloadData];
    [self displayOverlay:NO];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:YES];
    DetailViewController *detailViewController =
        [[DetailViewController alloc] initWithNetworkRecord:[self networkRecordForIndexPath:indexPath]];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - Utility
- (NetworkRecord*)networkRecordForIndexPath:(NSIndexPath*)indexPath
{
    NSUInteger row = indexPath.row;
    
    NSMutableArray *keys = [[NetworkLoader shared].recordsStorage.allKeys mutableCopy];
    
    
    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [keys sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    
    NSNumber *currentRecordID = keys[row];
    
    return [[NetworkLoader shared].recordsStorage objectForKey:currentRecordID];
}

#pragma mark - Overlay
- (void)displayOverlay:(BOOL)state
{
    if (!state)
    {
        [self.overlayView removeFromSuperview];
        return;
    }
    
    //TODO: Offset
    self.overlayView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    UIActivityIndicatorView *activityIndicator =
        [[UIActivityIndicatorView alloc]
         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.center = self.overlayView.center;
    [self.overlayView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    [self.tableView addSubview:self.overlayView];
}


@end
