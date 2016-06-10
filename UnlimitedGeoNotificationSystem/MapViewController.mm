//
//  MapViewController.m
//  UnlimitedGeoNotificationSystem
//
//  Created by joshua on 6/9/16.
//  Copyright © 2016 joshua. All rights reserved.
//

#import "MapViewController.h"
#import "AppDelegate.h"

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
    self.mapView.showsUserLocation = YES;
    [AppDelegate setCurrentMapViewController:self];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)hitAddButton:(id)sender {
    
    
}

-(void)updateRegion{
    
    if(!haveInitialized){
        haveInitialized = true;
        CGPoint * points = [GeoFenceTracker getCurrentTrackedLocations];
        
        for(unsigned int i =0; i < 1000; i ++){
            // only monitor first 1000 points
            CGPoint toAdd = points[i];
            if(toAdd.x == SENTINEL){
                break;
            }else{
                // it expects latitude then longitude
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(toAdd.y, toAdd.x);
                MKCircle * circ = [MKCircle circleWithCenterCoordinate:coord radius:10];
                CustomAnnotation * ann = [[CustomAnnotation alloc] initWithLocation:coord];
                [_mapView addOverlay:circ];
                [_mapView addAnnotation:ann];
            }
        }
    }
    
    
    
    
    
}

-(void) initializeStartRegion :(CLLocationCoordinate2D) center{
    
    // it expects latitude then longitude
    MKCoordinateRegion initial = MKCoordinateRegionMakeWithDistance(center, span, span);
    
    self.mapView.region = initial;
    
    
}
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    
    if ([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleRenderer* aRenderer = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
        
        aRenderer.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.5];
        aRenderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        aRenderer.lineWidth = 3;
        return aRenderer;
    }else{
        return nil;
    }
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
