//
//  AppDelegate.h
//  UnlimitedGeoNotificationSystem
//
//  Created by joshua on 6/9/16.
//  Copyright © 2016 joshua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
@class MapViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) CLLocationManager * locManager;
- (bool) checkStatus:(CLAuthorizationStatus) status;
+(void) setCurrentMapViewController: (MapViewController *) mv;

@end

