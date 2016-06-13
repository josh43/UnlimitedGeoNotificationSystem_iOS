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
/*
  actuallu useful command  in lldb 
 
 thread backtrace shows backtracks
 */

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) CLLocationManager * locManager;
@property BOOL  isBackgroundMode;
- (bool) checkStatus:(CLAuthorizationStatus) status;
+(void) setCurrentMapViewController: (MapViewController *) mv;

@end

