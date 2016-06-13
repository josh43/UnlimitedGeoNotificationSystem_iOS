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


MapViewController * mapVC = NULL;
bool haveInitializedMap = false;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //                    long  lat  long lat

    //    quadRect =  CGRectMake(-180,-90, 360, 180);

    quadRect =  CGRectMake(0,0, 360, 180);
    // initialize geofence
    // cal this first!!
    [GeoFenceTracker getSingleton:quadRect];
    
  
    [self canCheckFromBackground];
    [GeoFenceTracker loadFromFile];
    self.locManager = [[CLLocationManager alloc]init];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    // 20 meters 29 seconds
    
    if(![self checkStatus:status]){
        // wait a second to let user update and then check again
    }
    
    // SETUP NOTIFICATIONS
    UIUserNotificationType types = (UIUserNotificationType) (UIUserNotificationTypeBadge |
                                                             UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
    
    
    
    //runTest();
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
   
    // END SETTING UP NOTIFICATIONS
    self.locManager.delegate = self;
    self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locManager requestAlwaysAuthorization];
    _locManager.allowsBackgroundLocationUpdates = YES;

    [self.locManager startUpdatingLocation];
    [self.locManager allowDeferredLocationUpdatesUntilTraveled:20 timeout:20];

    
    
   [self addTestPoints];
    return YES;
}

-(void) addTestPoints{
      /*
    NSString *path = [[NSBundle mainBundle] resourcePath];
    [GeoFenceTracker insertNotification:-122.099444 withLatitude:37.409197 withPayLoard:[NSString stringWithFormat:@"%@",@"Welcome to a copy notification of monta loma park"]];

  
    [GeoFenceTracker insertNotification:-122.0310273 withLatitude:37.3270145 withPayLoard:[NSString stringWithFormat:@"%@",@"Welcome to apple"]];
    [GeoFenceTracker insertNotification:-122.084058 withLatitude:37.422 withPayLoard:[NSString stringWithFormat:@"%@",@"Welcome to google"]];
    [GeoFenceTracker insertNotification:-122.099444 withLatitude:37.409197 withPayLoard:[NSString stringWithFormat:@"%@",@"Welcome to monta loma park"]];
    [GeoFenceTracker insertNotification:-121.973648 withLatitude:37.402619 withPayLoard:[NSString stringWithFormat:@"%@",@"Welcome to levi stadium"]];
    [GeoFenceTracker insertNotification:-121.886101 withLatitude:37.333041 withPayLoard:[NSString stringWithFormat:@"%@",@"Welcome to San jose convention center"]];

    
    struct DataPair * pairs = parse([path UTF8String]);
    
    for(int i = 0; i < 51 ; i++){
        // painful
        //[GeoFenceTracker insertNotification:pairs[i].longitude withLatitude:pairs[i].latitude withPayLoard:[NSString stringWithUTF8String:pairs[i].state]];
        
    }
    free(pairs);
   // [GeoFenceTracker insertNotification:myLocationLong withLatitude:myLocationLat withPayLoard:@"Heyyyy brother"];
     */
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
   // if (_isBackgroundMode)
    //{
    //   [manager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:10];
   // }else{
   
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];

    if (abs(howRecent) < 15.0) {
      
        // this will have the midpoint be at the current location
        // remember that my rect starts at the upper left corner not the midpoint of the rect
        [GeoFenceTracker printAllPointsIntersecting:CGRectMake(location.coordinate.longitude, location.coordinate.latitude, searchDistance, searchDistance)];
        NSMutableArray * notifications = [GeoFenceTracker getNotifications:CGRectMake(location.coordinate.longitude, location.coordinate.latitude, searchDistance, searchDistance)];
        for(NSString * str in notifications){
            [self notification:@"Notifications" withMessage:str];
        }
        
       
    }
    
    if(mapVC){
        if(!haveInitializedMap){
            // map wants lat then longitude
            [mapVC initializeStartRegion:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)];
            haveInitializedMap = true;
        }
        
        [mapVC updateRegion];
    }
   // }
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
-(void) notification:(NSString *) title
         withMessage:(NSString *) mes{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = mes;
    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
    localNotif.alertTitle = title;
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    //localNotif.applicationIconBadgeNumber = 1;
  
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];

}
// http://www.creativeworkline.com/2014/12/core-location-manager-ios-8-fetching-location-background/
-(void) canCheckFromBackground{
    UIAlertView * alert;
    
    //We have to make sure that the Background app Refresh is enabled for the Location updates to work in the background.
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied)
    {
        
        // The user explicitly disabled the background services for this app or for the whole system.
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The app doesn't work without the Background app Refresh enabled. To turn it on, go to Settings > General > Background app Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
    {
        
        // Background services are disabled and the user cannot turn them on.
        // May occur when the device is restricted under parental control.
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The functions of this app are limited because the Background app Refresh is disable."
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else
    {
        
        // Background service is enabled, you can start the background supported location updates process
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    
    _isBackgroundMode = YES;
    
    [_locManager stopUpdatingLocation];
    [_locManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [_locManager setDistanceFilter:kCLDistanceFilterNone];
    _locManager.pausesLocationUpdatesAutomatically = NO;
    _locManager.activityType = CLActivityTypeAutomotiveNavigation;
    [_locManager startUpdatingLocation];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [GeoFenceTracker writeToFile];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    //make a file name to write the data to using the documents directory:
    
    
   // NSString * dataLocator = [[NSBundle mainBundle] resourcePath];
   // NSString * finalPath = [NSString stringWithFormat:@"%@/Documents/geoData.store",dataLocator];
    [GeoFenceTracker writeToFile];

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
