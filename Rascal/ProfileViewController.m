//
//  ProfileViewController.m
//  Rascal
//
//  Created by Phillip Ou on 7/2/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//


#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import <UIKit/UIKit.h>

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UILabel *followerNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingNumberLabel;
@property (nonatomic, strong) NSMutableArray *followingArray;

@end




@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // This table displays items in the Todo class
        self.parseClassName = @"Messages";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES; //allows scrolling down to load more pages
        self.objectsPerPage = 3;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PFUser *currentUser = [PFUser currentUser];
    PFFile *profilePicture = [currentUser objectForKey:@"profilePicture"];
    //make profile picture circular
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.cornerRadius = 20;
    
    self.profileImageView.file = profilePicture;
    [self.profileImageView loadInBackground];
    NSLog(@"Current User is %@", currentUser.username);
    
    
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    PFUser *currentUser = [PFUser currentUser];
    NSNumber *points = currentUser[@"Points"];
    self.pointsLabel.text = [NSString stringWithFormat: @"Income: %@",points];
    self.userNameLabel.text = currentUser.username;
    
    if(currentUser){
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"senderName" equalTo:[[PFUser currentUser]username]];
    [query whereKey:@"fileType" equalTo:@"image"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *songs, NSError *error) {
        if (error){
            NSLog (@"can't retrieve....");
        };
        
    }];}
    //[self loadObjects];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return nil;
    }
    static NSString *CellIdentifier = @"SectionHeaderCell";
    UITableViewCell *sectionHeaderView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *senderLabel = (UILabel *)[sectionHeaderView viewWithTag:2];
    
    PFUser *currentUser = [PFUser currentUser];
    PFObject *photo = [self.objects objectAtIndex:section];
    NSString *userName = [photo objectForKey:@"senderName"];
    
    UILabel *titleLabel = (UILabel *) [sectionHeaderView viewWithTag:3];
    UILabel *numberOfLikesLabel = (UILabel *) [sectionHeaderView viewWithTag:4];
    NSString *caption = [photo objectForKey:@"caption"];
    
    titleLabel.text=caption;
    senderLabel.text = [NSString stringWithFormat: @"by %@",userName];
   
    NSInteger *numberOfLikes = [photo[@"listOfLikers"] count];
    numberOfLikesLabel.text = [NSString stringWithFormat: @"%d",numberOfLikes];
    
    //get user profile picture and displayUILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 250, 15)];
    
    sectionHeaderView.backgroundColor = [UIColor whiteColor];
    

    
    
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
    photo.file = object[@"file"]; //save photo.file in key image
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
    return 400.0f; //height of cell
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
  
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"senderId" equalTo:currentUser.objectId];
    [query whereKey:@"fileType" equalTo:@"image"];
    
    //[query includeKey:@"whoTook"];
    
    
    
    [query orderByDescending:@"createdAt"];
    return query;
}




 
 
 
 
- (IBAction)logout:(id)sender {
    [PFUser logOut];
    
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    [appDelegate presentLoginControllerAnimated:YES];
    
}

- (IBAction)back:(id)sender {
    [self.tabBarController setSelectedIndex:0];
}



@end
