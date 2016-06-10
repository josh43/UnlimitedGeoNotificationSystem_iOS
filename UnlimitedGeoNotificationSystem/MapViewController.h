//
//  MapViewController.h
//  UnlimitedGeoNotificationSystem
//
//  Created by joshua on 6/9/16.
//  Copyright © 2016 joshua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GeoFenceTracker.h"
#import "CustomAnnotation.h"
@interface MapViewController : UIViewController <MKMapViewDelegate>
-(void) initializeStartRegion :(CLLocationCoordinate2D) center;
-(void) updateRegion;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UITextField *text;

@end
