//
//  AppDelegate.m
//  UnlimitedGeoNotificationSystem
//
//  Created by joshua on 6/9/16.
//  Copyright © 2016 joshua. All rights reserved.
//

#import "AppDelegate.h"
#import "GeoFenceTracker.h"
#import "MapViewController.h"
#include "parser.h"

@interface AppDelegate (){
    
}
@end

@implementation AppDelegate
// 1 deg of lat = 110.57 km @ the equator
// 1deg = 110.57 * 1000 m
// .00000904 deg = 1m m
// longitude is a little bit different
// 1 deg o long = 111.32 * 1000 m
// .00000899 deg(long) = 1 m
CGRect quadRect;
float meterInDegrees = 0.00000904;
// aka 100 meters in degrees
// it is fairly accurate up to about 25 meters
// if you want improved accuracy try improving the precision of the quad tree
// and most importantly you need to improve the precision of the degrees to meters
float searchDistance = 25 * meterInDegrees;
float myLocationLat = 37.643403200981;
//                    37.643480105360638
float myLocationLong = -121.816427986;
//                    -121.8164225110056

MapViewController * mapVC = NULL;
bool haveInitializedMap = false;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //                    long  lat  long lat

    //    quadRect =  CGRectMake(-180,-90, 360, 180);

    quadRect =  CGRectMake(0,0, 360, 180);
    // initialize geofence
    [GeoFenceTracker getSingleton:quadRect];
    
    self.locManager = [[CLLocationManager alloc]init];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if(![self checkStatus:status]){
        // wait a second to let user update and then check again
    }
    
    self.locManager.delegate = self;
    self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locManager requestAlwaysAuthorization];

    [self.locManager startUpdatingLocation];
    
    
    
    [self addTestPoints];
    return YES;
}

-(void) addTestPoints{
    NSString *path = [[NSBundle mainBundle] resourcePath];
   struct DataPair * pairs = parse([path UTF8String]);
    for(int i = 0; i < 51 ; i++){
        // painful
        [GeoFenceTracker insertNotification:pairs[i].longitude withLatitude:pairs[i].latitude withPayLoard:[NSString stringWithUTF8String:pairs[i].state]];
        
    }
    free(pairs);
    [GeoFenceTracker insertNotification:myLocationLong withLatitude:myLocationLat withPayLoard:@"Heyyyy brother"];
}
- (bool) checkStatus:(CLAuthorizationStatus) status{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            NSLog(@"Requesting auth status\n");
            [self requestAlwaysAuthorization];
            return false;
            break;
            
        default:
            return true;
    }
    
    return true;
}
+(void)setCurrentMapViewController:(MapViewController *)mv{
    mapVC = mv;
}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    
   
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
   
    if (abs(howRecent) < 15.0) {
      
        // this will have the midpoint be at the current location
        // remember that my rect starts at the upper left corner not the midpoint of the rect
        [GeoFenceTracker printAllPointsIntersecting:CGRectMake(location.coordinate.longitude, location.coordinate.latitude, searchDistance, searchDistance)];
      
        
       
    }
    
    if(mapVC){
        if(!haveInitializedMap){
            // map wants lat then longitude
            [mapVC initializeStartRegion:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)];
            haveInitializedMap = true;
        }
        
        [mapVC updateRegion];
    }
}

// got this from http://nevan.net/2014/09/core-location-manager-changes-in-ios-8/
- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status != kCLAuthorizationStatusNotDetermined) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
    }// The user has not enabled any location services. Request background authorization.
    else  {
        [self.locManager requestAlwaysAuthorization];
    }
}
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    BOOL canUseLocationNotifications = (status == kCLAuthorizationStatusAuthorizedAlways);
    
    if (canUseLocationNotifications) {
        NSLog(@"Can track user location!\n");
      //  [self startShowingNotifications]; // Custom method defined below
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
