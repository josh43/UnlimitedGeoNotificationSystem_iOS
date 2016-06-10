//
//  GeoFenceTracker.h
//  UnlimitedGeoNotificationSystem
//
//  Created by joshua on 6/9/16.
//  Copyright © 2016 joshua. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import "QuadTree/QuadTree.hpp"

//#import "QuadQuadTree.hpp"
/*
 If you are including it from /usr/local/lib ...
 you need to add that to header search paths not the frameworks!
 */



@interface GeoFenceTracker : NSObject

-(instancetype)initWithCGRect:(struct CGRect)rect;

+(GeoFenceTracker *) getSingleton:(struct CGRect) withThisRect;
+(void)insertNotification:(float)longitude
             withLatitude:(float)latitude
             withPayLoard:(NSString *)message;
+(void)deleteNotification:(float)longitude
             withLatitude:(float)latitude;
+(void)printAllPointsIntersecting:(CGRect) rect;
+(CGPoint *) getCurrentTrackedLocations;
+(NSString *) getStringForKey:(float) longitude
                      withLat:(float) latitude;

-(void)dealloc;
@end
