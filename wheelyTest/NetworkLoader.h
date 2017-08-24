//
//  NetworkLoader.h
//  wheelyTest
//
//  Created by Artem Abramov on 1/9/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

@import UIKit;
#import "NetworkRecord.h"

typedef NS_ENUM(NSUInteger, NetworkLoaderErrorCodes)
{
    NetworkLoaderError_Success,
    NetworkLoaderError_ConnectionIsAlreadyRunning,
    NetworkLoaderError_IncompleteOrIncorrectJSON,
    NetworkLoaderError_NumberOfErrors
};

@protocol NetworkLoaderProtocol <NSObject>

@optional
- (void)recordWasPurged:(NSNumber*)recordID;
- (void)recordWasAdded:(NSNumber*)recordID;

@end

@interface NetworkLoader : NSObject

//Key is ID, object is NetworkRecord with appropriate fields
@property (nonatomic, strong) NSDictionary*          recordsStorage;
@property (nonatomic) NSTimeInterval            updateTimerInterval;

@property (nonatomic, weak) id<NetworkLoaderProtocol> delegate;

+ (instancetype)shared;
- (NSError*)forceUpdate;

@end
