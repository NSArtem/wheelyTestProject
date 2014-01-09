//
//  NetworkRecord.h
//  wheelyTest
//
//  Created by Artem Abramov on 1/9/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkRecord : NSObject

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* text;

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@end
