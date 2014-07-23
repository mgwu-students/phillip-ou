//
//  PostCameraViewController.m
//  Rascal
//
//  Created by Phillip Ou on 7/10/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "PostCameraViewController.h"
#import "Parse/Parse.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CameraViewController.h"
#import "InboxViewController.h"
#import <time.h>


@interface PostCameraViewController ()

@end
//NSString *objectIdString;
@implementation PostCameraViewController

@synthesize photoJustPosted;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
    self.recipients = [[NSMutableArray alloc] init];
   
    //have sender of bounty and victim of bounty be checked automatically
    
    [self.recipients addObjectsFromArray:@[self.senderId,self.targetId]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    PFQuery *query = [self.friendsRelation query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
        else {
            self.friends = objects;
            [self.tableView reloadData];
        }
    }];
    

    
    
   
   
 
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
   PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    
    //if the user is in the array of people we want to send to have them checked
    if ([self.recipients containsObject:user.objectId]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else { //if they're not, then don't have them checked off
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
        
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
   PFUser *user = [self.friends objectAtIndex:indexPath.row];
    PFUser *currentUser = [PFUser currentUser];
    
   
    
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        NSLog(@"Add");
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.highlighted=NO;
        if(![user.objectId isEqualToString:currentUser.objectId]){
            [self.recipients addObject:user.objectId];
        
        }
        
        
        
    }
    else {
        NSLog(@"Remove");
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.recipients removeObject:user.objectId];
    }
    
    NSLog(@"%@", self.recipients); //log list of recipients
}



#pragma mark - Image Picker Controller delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    //[self.tabBarController dismissViewControllerAnimated:NO completion:nil];
    [self.tabBarController setSelectedIndex:0];
}


#pragma mark - IBActions

- (IBAction)cancel:(id)sender {
    [self reset];
    //[self.tabBarController dismissModalViewControllerAnimated:YES];
 
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)send:(id)sender {
            [self uploadMessage];
        [self reset];
    [self.tabBarController dismissViewControllerAnimated:NO completion:nil];
        //[self.tabBarController setSelectedIndex:0];
     //self.tabBarController.hidesBottomBarWhenPushed = NO;
   // }
}

#pragma mark - Helper methods

- (void)uploadMessage {
    //NSLog(@"final list %@",self.recipients);
    if([self.recipients count]!=0) {
    PFUser *currentUser = [PFUser currentUser];
    
    //the more users sent to, the more points you get.
    
    
    PFObject *message = [PFObject objectWithClassName:@"Messages"];
    NSArray *recipients = [NSArray arrayWithArray:self.recipients];
        //need to convert from mutableArray to array to send into parse
    NSString *payForId = self.selectedMessage[@"senderId"]; //sender of bounty
    NSNumber *payAmount = self.selectedMessage[@"bountyValue"];
    
        [message setObject:payForId forKey:@"payForId"]; //have bounty sender have his investment returned
        [message setObject:payAmount forKey:@"payAmount"];
       
        
    
                for(PFUser *friends in self.friends){
                    [self.allFriends addObject:friends.objectId];
                    
                }

        
        
    
    message[@"caption"] = self.caption;
    message[@"whoTook"] = currentUser;
    message[@"file"] = self.file;
    message[@"fileType"] = @"image";
    message[@"recipientIds"]=recipients;
    message[@"senderId"]=currentUser.objectId;
    message[@"senderName"] =currentUser.username;
   // message[@"friendsofUser"] = self.allFriends;
//if this is his first time using this bounty
    
    
    NSNumber *userPoints = currentUser[@"Points"];
    int points = [userPoints integerValue];
    int length = [self.recipients count];
    userPoints = [NSNumber numberWithInteger:points+length];
    [currentUser setObject: userPoints forKey: @"Points"];
    [currentUser saveInBackground];
        [self.selectedMessage setObject:@"Yes" forKey: @"read"];
        if(![self.selectedMessage[@"readUsers"] containsObject: currentUser.objectId]){
            NSMutableArray *readUsersArray = [NSMutableArray arrayWithArray:self.selectedMessage[@"readUsers"]];
            [readUsersArray addObject:currentUser.objectId];
            [self.selectedMessage  setObject:[NSArray arrayWithArray:readUsersArray]forKey:@"readUsers"];
            
        }
        [self.selectedMessage saveInBackground];


        
        //delete current user from recipientId's array
        //so that once you upload the picture bounty is gone.
        if(![self.selectedMessage[@"placeholder"] isEqualToString:@"placeholder"]){
       
        NSMutableArray *deleteArray = [NSMutableArray arrayWithArray:self.selectedMessage[@"recipientIds"]] ;

        [deleteArray removeObject:[[PFUser currentUser] objectId] ];
        [deleteArray removeObject:[[PFUser currentUser] objectId] ];
        NSLog(@"RecipientIds:%@",deleteArray);
        NSArray *arrayUpdate = [NSArray arrayWithArray:deleteArray];
        [self.selectedMessage setObject:arrayUpdate forKey:@"recipientIds"];
            [self.selectedMessage saveInBackground];
        }

    
        /*[message setObject:self.recipients forKey:@"recipientIds"];
        [message setObject:currentUser.objectId forKey:@"senderId"];
        [message setObject:currentUser.username forKey:@"senderName"];*/
       [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error){
                [self reset];
                
                //NSLog(@"god this work");
            }
    
            
        }];

          }
    
        else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You Didn't Select Anyone!"
                                                            message:@"Please Select People To Send To."
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
    }
    
    
    
    
}


- (void)reset {
    self.image = nil;
    self.videoFilePath = nil;
    self.file = nil;
    self.caption = nil;
    self.photoObjectId=nil;
    self.chosenImageView = nil;
    self.imagePicker = nil;
    [self.recipients removeAllObjects];
    [self performSegueWithIdentifier:@"backToTab" sender:self];
    //[self.tabBarController dismissViewControllerAnimated:NO completion:nil];
    //[self.tabBarController setSelectedIndex:0];
    
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"backToTab"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        InboxViewController *inboxViewController = (InboxViewController *)segue.destinationViewController;
}

}
@end
