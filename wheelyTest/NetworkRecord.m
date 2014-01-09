//
//  NetworkRecord.m
//  wheelyTest
//
//  Created by Artem Abramov on 1/9/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import "NetworkRecord.h"

@implementation NetworkRecord

- (id)init
{
    NSLog(@"Initilizing with default paramertrs");
    return [self initWithDictionary:@{@"text" : @"No data",
                                      @"title" : @"No title" }];
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self)
    {
        if ([dict objectForKey:@"text"])
            _text = (NSString *)dict[@"text"];
        else
            _text = @"No text";
        
        if ([dict objectForKey:@"title"])
            _title = (NSString*)dict[@"title"];
        else
            _title = @"No title";
    }
    return self;
}

@end
