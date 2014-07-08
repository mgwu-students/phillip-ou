//
//  HomeViewController.h
//  Rascal
//
//  Created by Phillip Ou on 6/29/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <Parse/Parse.h>
#import "SaveButton.h"


@interface HomeViewController : PFQueryTableViewController <CLLocationManagerDelegate,SaveButtonDelegate>

//@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocationManager *locationManager;
+ (void)geoPointForCurrentLocationInBackground:(void ( ^ ) ( PFGeoPoint *geoPoint , NSError *error ))geoPointHandler;
@end
