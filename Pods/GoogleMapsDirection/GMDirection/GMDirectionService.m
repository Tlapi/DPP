//
//  GMDirectionService.m
//  speakeasy
//
//  Created by Djengo on 8/02/13.
//  Copyright (c) 2013 Djengo. Under MIT Licence.
//  http://opensource.org/licenses/MIT

#import "GMDirectionService.h"

static NSString *DIRECTION = @"directions/json";
static NSString *SENSOR = @"true";
static GMDirectionService *sharedInstance = nil;

@implementation GMDirectionService

+ (GMDirectionService*)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
}

- (void)getDirectionsFrom:(NSString*)origin to:(NSString*)destination succeeded:(void(^)(GMDirection *directionResponse))success failed: (void (^)(NSError *error))failure{
    
    NSDate* referenceDate = [NSDate dateWithTimeIntervalSince1970: 0];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Europe/Prague"];
    int offset = [timeZone secondsFromGMTForDate: referenceDate];
    
    NSString *timeStampValue = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970] - offset];
    //int pragueTimestamp = timeStampValue - offset;
    
    NSString *path = [[NSString alloc] initWithFormat:@"%@?sensor=%@&origin=%@&destination=%@&mode=transit&departure_time=%@&alternatives=true",
                      DIRECTION,
                      SENSOR,
                      origin,
                      destination,
                      timeStampValue];
    
    NSLog(@"PATH: %@", path);
    
    [[GMHTTPClient sharedInstance] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success)
            success([GMDirection initWithDirectionResponse:responseObject]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure)
            failure(error);
    }];
}

@end