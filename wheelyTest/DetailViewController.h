//
//  DetailViewController.h
//  wheelyTest
//
//  Created by Artem Abramov on 1/9/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NetworkRecord;

@interface DetailViewController : UIViewController

@property (nonatomic, strong) NetworkRecord *networkRecord;

- (instancetype)initWithNetworkRecord:(NetworkRecord*)networkRecord;

@end
