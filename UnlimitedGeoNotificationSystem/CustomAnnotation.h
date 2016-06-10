//
//  CustomAnnotation.h
//  Push
//
//  Created by joshua on 6/7/16.
//  Copyright © 2016 joshua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject <MKAnnotation>{
    
    CLLocationCoordinate2D coordinate;
    
}
@property(nonatomic) CLLocationCoordinate2D  coordinate;
-(id) initWithLocation:(CLLocationCoordinate2D) coord;
@end

