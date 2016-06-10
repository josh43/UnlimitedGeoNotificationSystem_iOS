//
//  GeoFenceTracker.m
//  UnlimitedGeoNotificationSystem
//
//  Created by joshua on 6/9/16.
//  Copyright © 2016 joshua. All rights reserved.
//

#import "GeoFenceTracker.h"
#include <map>
#include <string>
// latitude is y
// longitude is x
@interface GeoFenceTracker(){
    Algo::QuadTree * qt;
    std::map<std::pair<Precision,Precision> ,std::string> pointMapping;
    std::vector<CGPoint *> toFree;
    unsigned int numPointsTracking;
}@end
CGRect dummy = CGRectMake(0, 0, 0, 0);
@implementation GeoFenceTracker
typedef Algo::QuadPoint<Precision> QPoint;

-(instancetype)init{
    NSLog(@"Dont call me\n");
    
    exit(0);
}

-(instancetype)initWithCGRect:(struct CGRect)rect{
    self = [super init];
    
    // it auto static casted everything holla @ ya boi
    qt = new Algo::QuadTree({static_cast<Precision>(rect.origin.x),static_cast<Precision>(rect.origin.y),static_cast<Precision>(rect.size.width),static_cast<Precision>(rect.size.height)});
    
    
    return self;
}
+(QPoint) convertFromNegativeSystem:(Precision) longitude
                           withWhy :(Precision) latitude{
    QPoint toReturn = {longitude+180.0f,latitude+90.0f};
    return toReturn;
}

+(Algo::Rect) convertFromNegativeSystem:(CGRect) otherRect{
    Algo::Rect toReturn;
    toReturn.upperLeft = {static_cast<float>(otherRect.origin.x+180.0f),static_cast<float>(otherRect.origin.y+90.0f)};
    toReturn.width = otherRect.size.width;
    toReturn.height = otherRect.size.height;
    
    return toReturn;
}
+(CGPoint) convertToMapSystem:(QPoint) q{
    CGPoint toReturn = {q.x - 180.0f,q.y - 90.0f};
    return toReturn;
    
}
+(GeoFenceTracker *) getSingleton:(struct CGRect) withThisRect{
    static GeoFenceTracker * store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        if(withThisRect.size.height == 0 && withThisRect.size.width == 0){
            NSLog(@"Error you are trying to intialize with the dummy retangle");
            exit(0);
        }
        store = [[GeoFenceTracker alloc]initWithCGRect:withThisRect];
    });
    
    return store;
}
+(CGPoint *) getCurrentTrackedLocations{
    CGPoint * toReturn = new CGPoint[[self getSingleton:dummy]->numPointsTracking+1];
    // isnt c++ marvelous?!?!
    unsigned int i = 0;
    for(std::map<std::pair<Precision,Precision>,std::string>::iterator iter =
        [self getSingleton:dummy]->pointMapping.begin(); iter !=  [self getSingleton:dummy]->pointMapping.end(); iter++ ){
        QPoint point = {iter->first.first,iter->first.second};
        CGPoint toAdd = [self convertToMapSystem:point];
        toReturn[i++] = toAdd;
    }
    
   
    // il manage zee memory
    [self getSingleton:dummy]->toFree.push_back(toReturn);
    toReturn[i] = CGPointMake(SENTINEL, SENTINEL);
    return toReturn;
}
+(NSString *) getStringForKey:(float) longitude
                      withLat:(float) latitude{
    
    if([self getSingleton:dummy]->pointMapping.find({longitude,latitude}) != [self getSingleton:dummy]->pointMapping.end()){
        NSString * toReturn = [[NSString alloc] initWithUTF8String:[self getSingleton:dummy]->pointMapping[{longitude,latitude}].c_str()];
        return toReturn;
    }else{
        return @"";
    }
    
}
+(void)insertNotification:(float)longitude
            withLatitude:(float)latitude
             withPayLoard:(NSString *)message{
    QPoint point = [self convertFromNegativeSystem:longitude withWhy:latitude];
    [self getSingleton:CGRectMake(0,0,0,0)]->qt->insert(point);
    std::string value = std::string([message UTF8String]);
    [self getSingleton:CGRectMake(0,0,0,0)]->pointMapping.insert({{point.x,point.y},value});
    [self getSingleton:CGRectMake(0, 0, 0, 0)]->numPointsTracking++;

    
}

+(void)deleteNotification:(float)longitude
            withLatitude:(float)latitude{
    
    QPoint point =  [self convertFromNegativeSystem:longitude withWhy:latitude];

    [self getSingleton:CGRectMake(0,0,0,0)]->qt->remove(point);
    [self getSingleton:CGRectMake(0,0,0,0)]->pointMapping.erase({point.x,point.y});
    [self getSingleton:CGRectMake(0, 0, 0, 0)]->numPointsTracking--;

}

// this assumes you pass in the basic scrub rect
+(void)printAllPointsIntersecting:(CGRect) rect{
    

    // convert it
    Algo::Rect theRec = [self convertFromNegativeSystem:rect];
    theRec.upperLeft.x -= theRec.width/2;
    theRec.upperLeft.y -= theRec.height/2;

    std::vector<QPoint> intersected;
    
    
    Algo::QuadQuery::query([self getSingleton:CGRectMake(0, 0, 0, 0)]->qt, theRec, intersected);
    printf("\nTracking %d points \n",[self getSingleton:CGRectMake(0, 0, 0, 0)]->numPointsTracking);
    for(int i = 0; i < intersected.size();i ++){
        std::string toPrint = [self getSingleton:CGRectMake(0, 0, 0, 0)]->pointMapping.at({intersected[i].x,intersected[i].y});
        printf("We intersected location x(%f) y(%f) with payload %s\n",intersected[i].x,intersected[i].y,toPrint.c_str());
    }
}
-(void)dealloc{
    //[super dealloc];
    for(CGPoint * freeMe : toFree){
        delete freeMe;
    }
    delete qt;
}

@end
