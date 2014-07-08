//
//  AppDelegate.h
//  Rascal
//
//  Created by Phillip Ou on 6/28/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ParseLoginViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, PFLogInViewControllerDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FBSession *session;
@property (nonatomic, strong) NSMutableData *profilePictureData;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, assign) CLLocationAccuracy filterDistance;

-(void) presentLoginControllerControllerAnimated: (BOOL) animated; //this needs to be public to be used by other subclasses later

@end