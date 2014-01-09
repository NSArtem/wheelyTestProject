//
//  DetailViewController.m
//  wheelyTest
//
//  Created by Artem Abramov on 1/9/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import "DetailViewController.h"

#import "NetworkRecord.h"

NSString* const kDetailCellIdentifier = @"kDetailCellIdentifier";
NSString* const kDetailLongTextIdentifier = @"kDetailLongTextIdentifier";

const CGFloat kTextVerticalPadding = 30.0f;
const CGFloat kTextHorizontalPadding = 15.0f;

typedef NS_ENUM(NSUInteger, DetailTableViewSections)
{
    DetailTableViewSection_Title,
    DetailTableViewSection_Text,
    DetailTableViewSection_NumberOfSections
};

@interface DetailViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation DetailViewController

#pragma mark - Initializer

- (instancetype)initWithNetworkRecord:(NetworkRecord*)networkRecord
{
    self = [super init];
    if (self)
    {
        _networkRecord = networkRecord;
    }
    return self;
}

- (id)init
{
    return [self initWithNetworkRecord:nil];
}

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad
{
    CGRect rect = CGRectMake(0, 0,
                             CGRectGetWidth(self.view.bounds),
                             CGRectGetHeight(self.view.bounds));
    self.tableView = [[UITableView alloc] initWithFrame:rect
                                                  style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.title = self.networkRecord.title;

    [self.view addSubview:self.tableView];

}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    //Fallback
    if (!self.networkRecord)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.textLabel.text = @"No data specified";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    switch (indexPath.section) {
        case DetailTableViewSection_Title:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDetailCellIdentifier];
            if (!cell)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                              reuseIdentifier:kDetailCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = self.networkRecord.title;
            return cell;
        }
            break;
        
        case DetailTableViewSection_Text:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDetailLongTextIdentifier];
            if (!cell)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                              reuseIdentifier:kDetailLongTextIdentifier];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.text = self.networkRecord.text;
            CGRect rect = [self getRectForText:label.text withWidth:tableView.bounds.size.width];
            rect.origin.y = kTextVerticalPadding / 2;
            rect.origin.x += kTextHorizontalPadding;
            label.frame = rect;
            [cell.contentView addSubview:label];

            return cell;
        }
            break;
            
        default:
            break;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case DetailTableViewSection_Title:
            return @"Title";
            break;
            
        case DetailTableViewSection_Text:
            return nil;
            
        default:
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return DetailTableViewSection_NumberOfSections;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == DetailTableViewSection_Text)
    {
        CGRect rect = [self getRectForText:self.networkRecord.text
                                 withWidth:tableView.bounds.size.width];
        rect.size.height += kTextVerticalPadding;
        return rect.size.height;
    }
    return 44.0f;
}

#pragma mark - Utility
- (CGRect)getRectForText:(NSString*)text withWidth:(CGFloat)width
{
    CGSize constraintSize = CGSizeMake(width - kTextHorizontalPadding * 2, MAXFLOAT);
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:17.0f]};
    CGRect rect = [text boundingRectWithSize:constraintSize
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil];
    NSLog(@"Calculated rect: %@", NSStringFromCGRect(rect));
    return rect;
}




@end
