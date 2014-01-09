//
//  NetworkLoader.m
//  wheelyTest
//
//  Created by Artem Abramov on 1/9/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import "NetworkLoader.h"

NSString* const kNetworkLoaderErrorDomain = @"NetworkLoader";

NSString* const kCrazyDevURL = @"http://crazy-dev.wheely.com/";

const CGFloat kDefaultTimer = 5.0f;

@interface NetworkLoader()<NSURLConnectionDataDelegate>

@property(nonatomic, strong) NSTimer *updateTimer;
@property(nonatomic, strong) NSURLConnection *connection;
@property(nonatomic, strong) NSMutableData *connectionData;

@end

@implementation NetworkLoader

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setUpTimerWithInterval:kDefaultTimer];
    }
    return self;
}

#pragma mark - Singleton
+ (instancetype)shared
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Interface
- (NSError *)forceUpdate
{
    NSError *error = nil;
    
    [self.connection cancel];
    self.connection = nil;
    error = [self fetch];
    
    if (error)
    {
        NSLog(@"Failed to force update: %@", error);
        return error;
    }
    
    [self setUpTimerWithInterval:kDefaultTimer];
    return error;
}


#pragma mark - Internal
- (NSError*)fetch
{
    NSError *error = nil;
    if (self.connection)
    {
        error = [NSError errorWithDomain:kNetworkLoaderErrorDomain
                                    code:NetworkLoaderError_ConnectionIsAlreadyRunning
                                userInfo:@{ NSLocalizedDescriptionKey :
                                                @"Connection is already running" }]; //TODO: localize
        return error;
    }
    
    NSURL *url = [NSURL URLWithString:kCrazyDevURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    return error;
}

- (void)setUpTimerWithInterval:(CGFloat)interval
{
    if (interval <= 0) {
        NSLog(@"Incorrect interval: %g", interval);
        return;
    }
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                        target:self
                                                      selector:@selector(fetch)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (NSError*)parseJSON:(NSArray*)incomingJSON
{
    NSError *error = nil;

    if (!incomingJSON)
    {
        error = [NSError errorWithDomain:kNetworkLoaderErrorDomain
                                    code:NetworkLoaderError_IncompleteOrIncorrectJSON
                                userInfo:@{ NSLocalizedDescriptionKey :
                                                @"Incorrect JSON"}];
        return error;
    }
    
    NSMutableDictionary *recordsStorage = [NSMutableDictionary dictionary];
    for (NSDictionary *nextItem in incomingJSON)
    {
        if ([nextItem objectForKey:@"id"])
        {
            NSNumber *idNumber = nextItem[@"id"];
            NetworkRecord *record = [[NetworkRecord alloc] initWithDictionary:nextItem];
            [recordsStorage setObject:record forKey:idNumber];
        }
    }
    
    NSMutableSet *existingKeys = [NSMutableSet setWithArray:self.recordsStorage.allKeys];
    NSMutableSet *newKeys = [NSMutableSet setWithArray:recordsStorage.allKeys];
    
    if ([existingKeys isEqualToSet:newKeys])
    {
        NSLog(@"No new records detected");
        return nil;
    }
    else
    {
        NSMutableSet *purgedKeys = [NSMutableSet setWithSet:existingKeys];
        [purgedKeys minusSet:newKeys];
        NSMutableSet *addedKeys = [NSMutableSet setWithSet:newKeys];
        [addedKeys minusSet:existingKeys];
        NSLog(@"Following records were added: %@", addedKeys);
        NSLog(@"Following records were purged: %@", purgedKeys);
        
        self.recordsStorage = recordsStorage;
        
        if ([self.delegate respondsToSelector:@selector(recordWasAdded:)])
        {
            for (NSNumber *addedItem in addedKeys)
            {
                [self.delegate recordWasAdded:addedItem];
            }

        }
        if ([self.delegate respondsToSelector:@selector(recordWasAdded:)])
        {
            for (NSNumber *purgedItem in purgedKeys)
            {
                [self.delegate recordWasPurged:purgedItem];
            }
        }
    }

    
    return error;
}

#pragma mark - NSURLConnection
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed: %@", error);
    [self.connection cancel];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.connectionData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpURLResponce = (NSHTTPURLResponse*)response;
    NSLog(@"HTTP response: %d", httpURLResponce.statusCode);
    self.connectionData = [NSMutableData new];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    NSArray *jsonDictionary = [NSJSONSerialization JSONObjectWithData:self.connectionData
                                                                   options:kNilOptions
                                                                     error:&error];
    NSLog(@"Fetched JSON, parsing...");
    error = [self parseJSON:jsonDictionary];
    self.connection = nil;
}

@end
