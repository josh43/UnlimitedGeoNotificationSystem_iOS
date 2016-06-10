//
//  MapViewController.m
//  UnlimitedGeoNotificationSystem
//
//  Created by joshua on 6/9/16.
//  Copyright © 2016 joshua. All rights reserved.
//

#import "MapViewController.h"
#define span 5000
// in meters i think
@interface MapViewController (){
    bool haveInitialized;
}
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    haveInitialized = false;
    self.mapView.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) initializeStartRegion :(CLLocationCoordinate2D) center{
    
    MKCoordinateRegion initial = MKCoordinateRegionMakeWithDistance(center, span, span);
    self.mapView.region = initial;
    
    
}
-(void)updateRegion{
    
    
   
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
