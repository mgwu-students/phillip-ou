//
//  ProfileViewController.m
//  Rascal
//
//  Created by Phillip Ou on 7/2/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//


#import "ProfileViewController.h"
#import "AppDelegate.h"
#import <UIKit/UIKit.h>

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUserStatus];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return nil;
    }
    static NSString *CellIdentifier = @"SectionHeaderCell";
    UITableViewCell *sectionHeaderView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //get profile picture. tags were assigned in mainstory
    PFImageView *profileImageView = (PFImageView *)[sectionHeaderView viewWithTag:1];
    UILabel *userNameLabel = (UILabel *)[sectionHeaderView viewWithTag:2];
    UILabel *titleLabel = (UILabel *)[sectionHeaderView viewWithTag:3];
    
    PFObject *photo = [self.objects objectAtIndex:section];
    PFUser *user = [photo objectForKey:@"whoTook"]; //acquire user information from photo["whoTook"]
    PFFile *profilePicture = [user objectForKey:@"profilePicture"];
    NSString *title = photo[@"title"];
    
    userNameLabel.text = user.username; //username is built in variable in parse
    titleLabel.text = title;    //titleLabel.text given title of photo
    
    profileImageView.file = profilePicture;
    [profileImageView loadInBackground];
/*
    FollowButton *followButton = (FollowButton*)[sectionHeaderView viewWithTag:4]; //follow button was given tag 4
    
    ////!!!!!!
    //followButton.delegate = self;
   // followButton.sectionIndex = section;
    
    // if this is yourself hide the follow button
    if ([user.objectId isEqualToString: [PFUser currentUser].objectId]) {
        followButton.hidden = NO; //hide follow button
        NSInteger indexOfMatchedObject = [self.followingArray indexOfObject:user.objectId]; //assign index where user.objectId is to variable
        
        // if we can't find that person's objectID, he is not already being followed by us
        if(indexOfMatchedObject == NSNotFound){ //
            followButton.selected = NO;     //followButton.selected turned Unfollow, so by not being selected already, it will be labeled follow
        }
        //if we are able to find that person's user.objectID in our array
        //it means he is already being followed by us
        else{
            followButton.selected = YES;
        }
        
        
    }
    else{
        followButton.hidden = NO;
        NSInteger indexOfMatchedObject = [self.followingArray indexOfObject:user.objectId]; //assign index where user.objectId is to variable
        
        // if we can't find that person's objectID, he is not already being followed by us
        if(indexOfMatchedObject == NSNotFound){ //
            followButton.selected = NO;     //followButton.selected turned Unfollow, so by not being selected already, it will be labeled follow
        }
        //if we are able to find that person's user.objectID in our array
        //it means he is already being followed by us
        else{
            followButton.selected = YES;
        }
    }
    */
    return sectionHeaderView;
}

- (void)updateUserStatus {
    PFUser *user = [PFUser currentUser];
    self.profileImageView.file = user[@"profilePicture"];
    [self.profileImageView loadInBackground];
    self.userNameLabel.text = user.username;
    
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Activity"];
    [followingQuery whereKey:@"fromUser" equalTo:user];
    [followingQuery whereKey:@"type" equalTo:@"follow"];
    [followingQuery findObjectsInBackgroundWithBlock:^(NSArray *followingActivities, NSError *error) {
        if (!error) {
            self.followingNumberLabel.text = [[NSNumber numberWithInteger:followingActivities.count] stringValue];
        }
    }];
    
    PFQuery *followerQuery = [PFQuery queryWithClassName:@"Activity"];
    [followerQuery whereKey:@"toUser" equalTo:user];
    [followerQuery whereKey:@"type" equalTo:@"follow"];
    [followerQuery findObjectsInBackgroundWithBlock:^(NSArray *followerActivities, NSError *error) {
        if (!error) {
            self.followerNumberLabel.text = [[NSNumber numberWithInteger:followerActivities.count] stringValue];
        }
    }];
}

- (PFQuery *)queryForTable {
    if (![PFUser currentUser] || ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        return nil;
    }
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Activity"];
    [followingQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [followingQuery whereKey:@"type" equalTo:@"follow"];
    
    PFQuery *photosFromFollowedUsersQuery = [PFQuery queryWithClassName:@"Photo"];
    [photosFromFollowedUsersQuery whereKey:@"whoTook" matchesKey:@"toUser" inQuery:followingQuery];
    
    PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:@"Photo"];
    [photosFromCurrentUserQuery whereKey:@"whoTook" equalTo:[PFUser currentUser]];
    
    PFQuery *superQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:photosFromCurrentUserQuery,photosFromFollowedUsersQuery, nil]];
    [superQuery includeKey:@"whoTook"];
    [superQuery orderByDescending:@"createdAt"];
    
    return superQuery;
}

- (IBAction)logout:(id)sender {
    [PFUser logOut];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate presentLoginControllerControllerAnimated:YES];
}
















@end

/*

#import "ProfileViewController.h"
#import "AppDelegate.h"


@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *followerNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *followingNumberLabel;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateUserStatus];
}
-(void) updateUserStatus{
    PFUser *user = [PFUser currentUser];
    self.profileImageView.file = user[@"profilePicture"];
    self.userNameLabel.text = user.username;
    
    //edit here for groups instead of followers
    PFQuery *followingQuery = [PFQuery queryWithClassName: @"Activity"];
    [followingQuery whereKey: @"fromUser" equalTo: user];
    [followingQuery whereKey: @"type" equalTo: @"follow"];
    [followingQuery findObjectsInBackgroundWithBlock:^(NSArray *followingActivities, NSError *error){
        if(!error){
            self.followingNumberLabel.text = [[NSNumber numberWithInteger:followingActivities.count]stringValue];}
    }];
   
    PFQuery *followerQuery = [PFQuery queryWithClassName: @"Activity"];
    [followerQuery whereKey: @"toUser" equalTo: user];
    [followerQuery whereKey: @"type" equalTo: @"follow"];
    [followerQuery findObjectsInBackgroundWithBlock:^(NSArray *followerActivities, NSError *error){
        if(!error){
            if(followerActivities.count==0){
                self.followerNumberLabel.text=0;
            }
            self.followerNumberLabel.text = [[NSNumber numberWithInteger:followerActivities.count]stringValue];}
    }];
}





- (PFQuery *)queryForTable {
    //PROBLEMS WERE FROM HOMEVIEW VERSION, WE'RE JUST TESTING THIS!!!   
    
    //!!!! this won't crash when uncommented, but won't load photos
    if(![PFUser currentUser] || ![PFFacebookUtils isLinkedWithUser: [PFUser currentUser]]){
        NSLog(@"Photos Won't Load");
     return nil;
     }

    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Activity"];
    [followingQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [followingQuery whereKey:@"type" equalTo:@"follow"];
     
     PFQuery *photosFromFollowedUsersQuery = [PFQuery queryWithClassName:@"Photo"];
     
     [photosFromFollowedUsersQuery whereKey:@"whoTook" matchesKey:@"toUser" inQuery:followingQuery];
    
    PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:@"photo"];
    [photosFromCurrentUserQuery whereKey:@"whoTook" equalTo:[PFUser currentUser]];
    
    //display both photos from this user and photos from followed users
    /*PFQuery *superQuery = [PFQuery orQueryWithSubqueries: [NSArray arrayWithObjects: photosFromFollowedUsersQuery,photosFromCurrentUserQuery,nil]];
    [superQuery includeKey:@"whoTook"];
    [superQuery orderByDescending:@"createdAt"];
    
    return photosFromFollowedUsersQuery;*/
    //return superQuery;
  /*   return photosFromFollowedUsersQuery;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}
- (IBAction)logout:(id)sender {
    [PFUser logOut];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    [appDelegate presentLoginControllerControllerAnimated:YES];
}

    

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end*/
