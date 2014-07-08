//
//  HomeViewController.m
//  Rascal
//
//  Created by Phillip Ou on 6/29/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "HomeViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "SaveButton.h"

static PFGeoPoint *geoPoint;

 @interface HomeViewController ()
@property (nonatomic, strong) NSMutableArray *savePhotosArray;

 @end
 
 

 @implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)startStandardUpdates {
	if (nil == _locationManager) {
		_locationManager = [[CLLocationManager alloc] init];
	}
    
	_locationManager.delegate = self;
	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
	// Set a movement threshold for new events.
	_locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    
	[_locationManager startUpdatingLocation];
    
	CLLocation *currentLocation = _locationManager.location;
	if (currentLocation) {
		AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		appDelegate.currentLocation = currentLocation;
	}
}

- (void)startSignificantChangeUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == _locationManager)
        _locationManager = [[CLLocationManager alloc] init];
    
    _locationManager.delegate = self;
    [_locationManager startMonitoringSignificantLocationChanges];
    CLLocation *location = self.locationManager.location;
    
	// Configure the new event with information from the location.
	
    ///*************************************************************//
    
    CLLocationCoordinate2D coordinate = [location coordinate];
    
   geoPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    
   

}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // This table displays items in the Todo class
        self.parseClassName = @"Photo";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES; //allows scrolling down to load more pages
        self.objectsPerPage = 3;
    }
    
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self startStandardUpdates];
    
	// Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated {
    //[_locationManager startUpdatingLocation];
    [super viewWillAppear:animated];
    
    [self loadObjects];
}

- (void)viewDidDisappear:(BOOL)animated {
	//[_locationManager stopUpdatingLocation];
	[super viewDidDisappear:animated];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    

    // Dispose of any resources that can be recreated.
}

#pragma mark - PFQueryTableViewDataSource and Delegates



//load objects
-(void)objectsDidLoad:(NSError *)error{
    [super objectsDidLoad: error];
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey: @"fromUser" equalTo: [PFUser currentUser]]; //followActivity from User
    [query whereKey:@"type" equalTo:@"save"];
    [query includeKey:@"toUser"]; //the user who owns the photo
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        {
            if (!error){
                self.savePhotosArray = [NSMutableArray array];
                if(objects.count >0){
                    for(PFObject *activity in objects){
                        PFUser *user = activity[@"toUser"];
                        [self.savePhotosArray addObject:user.objectId]; //this is where we add the user's objectId;
                    }
                }
                [self.tableView reloadData];
            }
            
        }
    }];

}


// return objects in a different indexpath order. in this case we return object based on the section, not row, the default is row

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.section];
    }
    else {
        return nil;
    }
}

- (CLLocationManager *)locationManager {
    if (_locationManager != nil) {
        return _locationManager;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [_locationManager setDelegate:self];
   // [_locationManager setPurpose:@"Your current location is used to demonstrate PFGeoPoint and Geo Queries."];
    
    return _locationManager;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return nil;
    }
    //[CLLocationManager locationServicesEnabled];
    //[self.locationManager startUpdatingLocation];
   // NSLog(@"Updating Location");
   
    static NSString *CellIdentifier = @"SectionHeaderCell";
    UITableViewCell *sectionHeaderView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //get profile picture. tags were assigned in mainstory
    PFImageView *profileImageView = (PFImageView *)[sectionHeaderView viewWithTag:1];
    UILabel *userNameLabel = (UILabel *)[sectionHeaderView viewWithTag:2];
    UILabel *titleLabel = (UILabel *)[sectionHeaderView viewWithTag:3];
    
    UILabel *dateLabel = (UILabel*)[sectionHeaderView viewWithTag:5];
    
    
    
    PFObject *photo = [self.objects objectAtIndex:section];
    PFUser *user = [photo objectForKey:@"whoTook"]; //acquire user information from photo["whoTook"]
    PFFile *profilePicture = [user objectForKey:@"profilePicture"];
    NSString *title = photo[@"title"];
    
 
    
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMM/dd/yyy"];
    NSString *dateString = [df stringFromDate:photo.createdAt];
    
    //PFGeoPoint *geoPoint = user[@"Location"];
    
   
    
    
    [self loadObjects];
  
    
    //NSLog(@"%f,%f", geoPoint.latitude,geoPoint.longitude);
   
    PFGeoPoint *photoLocation= photo[@"Location"];
    
  
    
    
    //NSLog(@"%f,%f", geoPoint.latitude, geoPoint.longitude);

    
    double earthRadius = 6371; //kilometers
    double dLat = (geoPoint.latitude-photoLocation.latitude)* M_PI/180;
    double dLng = (geoPoint.longitude-photoLocation.longitude)* M_PI/180;
    double a =sin(dLat/2) * sin(dLat/2) + cos((geoPoint.latitude)* M_PI/180) * cos((photoLocation.latitude)* M_PI/180) *
    sin(dLng/2) * sin(dLng/2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    float dist = (float) (earthRadius * c);
   // NSLog(@"Distance: %f",dist);
    //*****************************************************************//
    
    userNameLabel.text = user.username; //username is built in variable in parse
    titleLabel.text = title;    //titleLabel.text given title of photo
    
    dateLabel.text = dateString;
    
    profileImageView.file = profilePicture;
    [profileImageView loadInBackground];
    //save button
    
    SaveButton *saveButton = (SaveButton *) [sectionHeaderView viewWithTag:4];
    saveButton.delegate = self;
    saveButton.sectionIndex = section;
    
    if (!self.savePhotosArray ||[user.objectId isEqualToString:[PFUser currentUser].objectId]){
        saveButton.hidden= YES;
    }
    else{
        saveButton.hidden = NO;
        NSInteger indexOfMatchedObject = [self.savePhotosArray indexOfObject:user.objectId];//!!!!
        //NSLog(@"%@",indexOfMatchedObject);
        if(indexOfMatchedObject==NSNotFound){
            saveButton.selected = NO;
            //NSLog(@"This is being Called");
        }
        else{
            saveButton.selected = YES;
            //NSLog(@"Other thing being Called");
        }
    }
    
    return sectionHeaderView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = self.objects.count; //number of sections = number of objects
    if (self.paginationEnabled && sections >0) {
        sections++; //add 1 to sections so we can keep scrolling
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;   //1 row per section
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    if (indexPath.section == self.objects.count) { //if we're at the end (the last section)
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath]; //get that cell(LoadMoreCell)
        return cell;
    }
    static NSString *CellIdentifier = @"PhotoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    PFImageView *photo = (PFImageView *)[cell viewWithTag:1];
    photo.file = object[@"image"]; //save photo.file in key image
    [photo loadInBackground]; //load photo
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f; //make loadmore cell disappear
    }
    return 50.0f; //width of cell
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.objects.count) {
        return 50.0f;
    }
    return 320.0f; //height of cell
}

//use this cell to load next page
- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"LoadMoreCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if we select the loadmorecell
    
    if (indexPath.section == self.objects.count && self.paginationEnabled) {
        [self loadNextPage];
    }
}



        
- (PFQuery *)queryForTable {
 
    
    if (![PFUser currentUser] || ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
         return nil;
         }
    
     PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
   
    
    
    [self startSignificantChangeUpdates];
    // And set the query to look by location
    //*************************/ control which posts we see based on location
    
    CLLocation *location = self.locationManager.location;
	if (!location) {
		NSLog(@"NO");
	}
    
	// Configure the new event with information from the location.
	CLLocationCoordinate2D coordinate = [location coordinate];
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    PFUser *user = [PFUser currentUser];
    
   
    PFGeoPoint *userPosition = [PFGeoPoint geoPointWithLatitude:geoPoint.latitude
                                               longitude:geoPoint.longitude];
    user[@"Location"]=userPosition;
    //[user setObject:userPosition forKey:@"Location"];
   //NSLog(@"%f,%f is the user position", userPosition.latitude, userPosition.longitude);
    
    
    [query whereKey:@"Location" nearGeoPoint:userPosition
   withinKilometers:4200];
    
    
    [user saveInBackground];
    //[self loadObjects];
    
    
    
    
    //***************************/
    //[query includeKey:kPAWParseUserKey];
    
        
        [query includeKey:@"whoTook"];
        
        [query orderByDescending:@"createdAt"];
        return query;
    }




-(void) saveButton:(SaveButton *)button didTapWithSectionIndex:(NSInteger)index{
    PFObject *photo = [self.objects objectAtIndex:index];
    PFUser *user = photo[@"whoTook"];//user who took the photo
    if(!button.selected){
        [self saveUser:user];
    }
    else{
        [self unSave:user];
    }
    [self.tableView reloadData];
}

-(void) saveUser:(PFUser *) user{
    if(![user.objectId isEqualToString: [PFUser currentUser].objectId]){
        [self.savePhotosArray addObject: user.objectId]; //ADD PHOTOS
        PFObject *saveActivity = [PFObject objectWithClassName:@"Activity"];
        saveActivity[@"fromUser"] =[PFUser currentUser];
        saveActivity[@"toUser"] = user;
        saveActivity[@"type"] = @"save";
        [saveActivity saveEventually];
        NSLog(@"Save");
        
        
    }
}

-(void) unSave:(PFUser *) user{
    [self.savePhotosArray removeObject:user.objectId]; //REMOVE PHOTOS
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"toUser"equalTo:user];
    [query whereKey:@"type" equalTo:@"save"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *saveActivities, NSError *error) {
        {
            
            if(!error){
                for (PFObject *saveActivity in saveActivities){
                    [saveActivity deleteEventually];
                }
            }
        }
    }];
    NSLog(@"Unsave");
    
}

@end
