//
//  AppDelegate.m
//  Rascal
//
//  Created by Phillip Ou on 6/28/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "HomeViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [Parse setApplicationId:@"yKPQyCref89CL3WLX8umBba2YEqanTcuNVVTQ8GA"
                  clientKey:@"CHT2hRkuerq5JOId4DpgvdEVYrgaDmYV68AlVri9"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    PFObject *testObject = [PFObject objectWithClassName:@"Photo"];
    PFObject *groups = [PFObject objectWithClassName:@"GroupName"];
    
    [self.window makeKeyAndVisible];
    
    
    
    // !!!!!
    if (![FBSession defaultAppID]) {
        [FBSession setDefaultAppID:@"773713522660443"];
        [PFFacebookUtils initializeFacebook];
    }
     
    //[PFFacebookUtils initializeFacebook];
    if(![PFUser currentUser] && ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){  //if user not logged in, show logincontroller
        [self presentLoginControllerControllerAnimated: NO];
    }
    return YES;
}
static NSString* const LocationChangeNotification= @"LocationChangeNotification";

// We also add a method to be called when the location changes.
// This is where we post the notification to all observers.
- (void)setCurrentLocation:(CLLocation *)aCurrentLocation
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject: aCurrentLocation
                                                         forKey:@"Location"];
    [[NSNotificationCenter defaultCenter] postNotificationName: LocationChangeNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

//present login to user
-(void) presentLoginControllerControllerAnimated: (BOOL) animated{
   /*
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    [PFFacebookUtils initializeFacebook];
   
    UINavigationController *loginNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"LoginNav"];
    [self.window.rootViewController presentViewController:loginNavigationController animated:animated completion:nil];*/
    
    
    //Facebook Login
    ParseLoginViewController *loginViewController = [[ParseLoginViewController alloc] init];
    loginViewController.delegate = self;
    [loginViewController setFields:PFLogInFieldsFacebook];
    [self.window.rootViewController presentViewController:loginViewController animated:animated completion:nil];
    
    
    
}
-(void)facebookRequestDidLoad: (id)result{
    PFUser *user = [PFUser currentUser];
    if(user){ //if user logged in
        NSString *facebookName = result[@"name"]; //access value under key name in result (result extracted from facebook profile)
        user.username = facebookName;
        NSString *facebookId = result[@"id"];
        user[@"facebookId"]=facebookId;
        
        //get profile picture
        NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square",facebookId]];
        NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL];
        [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
    }
}
-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        if(!error){
            [self facebookRequestDidLoad:result];
        }
        else{
            [self showErrorAndLogOut];
        }
    }];
    
}

//call this method when there is an error
-(void) logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error{
    
    [self showErrorAndLogOut];

}

-(void) showErrorAndLogOut{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Login Failed" message:@"Please Try Again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    [PFUser logOut];
}
//connection failure, ie can't get on the internet
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self showErrorAndLogOut];
}

//begin receiving data byinitializing the NSMutable data type
-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _profilePictureData = [[NSMutableData alloc]init]; //_variable same as self.variable
}

//receiving and appending the data
-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.profilePictureData appendData:data];
}

//finish receiving all the info for profile picture
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if(self.profilePictureData.length ==0 || !self.profilePictureData){
        [self showErrorAndLogOut];
    }
    else{
        PFFile *profilePictureFile = [PFFile fileWithData:self.profilePictureData];
        [profilePictureFile saveInBackgroundWithBlock:^(BOOL succeeded,NSError *error){
            if(!succeeded){
                [self showErrorAndLogOut];
            }
            else{
                PFUser *user = [PFUser currentUser];
                user[@"profilePicture"] = profilePictureFile;
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(!succeeded){
                        [self showErrorAndLogOut];
                    }
                    else{
                        [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
                    }
                }];
            }
            
        }];
    }
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    
    
    //Facebook Login
    //[FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

/*- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}*/



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}



- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
