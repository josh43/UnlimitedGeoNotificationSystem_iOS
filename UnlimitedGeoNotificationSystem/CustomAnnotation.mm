//
//  CustomAnnotation.m
//  UnlimitedGeoNotificationSystem
//
//  Created by joshua on 6/9/16.
//  Copyright © 2016 joshua. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation
//
//  CustomAnnotation.m
//  Push
//
//  Created by joshua on 6/7/16.
//  Copyright © 2016 joshua. All rights reserved.
//


@synthesize coordinate;

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        coordinate = coord;
    }
    return self;
}



@end
