//
//  BountiesViewController.m
//  Rascal
//
//  Created by Phillip Ou on 7/20/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "BountiesViewController.h"
#import "EditFriendsViewController.h"
@interface BountiesViewController ()

@end

@implementation BountiesViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bountyCost = 10;
    self.recipientsOfBounties = [[NSMutableArray alloc] init];
    self.allFriends = [[NSMutableArray alloc] init];
    self.friends = [[NSArray alloc]init];
    FBSession.activeSession = [[FBSession alloc] initWithPermissions:[NSArray arrayWithObjects:@"user_friends", nil]];
    
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSLog(@"Found: %i friends", friends.count);
        for (NSDictionary<FBGraphUser>* friend in friends) {
            NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
        }
    }];
    
    
}








-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    PFUser *currentUser = [PFUser currentUser];
    self.points = currentUser[@"Points"];
    NSLog(@"Points:%@",self.points);
    [self.recipientsOfBounties removeAllObjects];
    self.clickCount = 0;
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
    PFQuery *query = [self.friendsRelation query]; //create query of our friends
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@ %@", error,[error userInfo]);
        }
        else{
            self.friends=objects;   //self.friends array = objects array returned in findObjectsinBackgroundwithblock
            for(PFUser *friends in self.friends){
                [self.allFriends addObject:friends.objectId];
                
            }
            [self.tableView reloadData];
        }
    }];
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showEditFriends"]){
        EditFriendsViewController *viewController = (EditFriendsViewController *)segue.destinationViewController;
        viewController.friends = [NSMutableArray arrayWithArray: self.friends];
    }
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
    //refresh each time table loads so there are no check marks
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    return cell;
}


-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.clickCount==0){
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if(cell.accessoryType==UITableViewCellAccessoryNone){
            cell.accessoryType = UITableViewCellAccessoryCheckmark; //put check mark
            self.user = [self.friends objectAtIndex: indexPath.row];
            NSLog(@"bounty on %@",self.user.objectId);
            
            [self.recipientsOfBounties addObject:self.user.objectId];
            [self.allFriends addObject:self.user.objectId];
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.clickCount = 1;
            
            
        }
        
        
        
    }
    else{
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.user = [self.friends objectAtIndex: indexPath.row];
        if(cell.accessoryType==UITableViewCellAccessoryCheckmark ){
            //1. remove check mark
            cell.accessoryType = UITableViewCellAccessoryNone;
            //2. remove from the array of friends
            [self.recipientsOfBounties removeObject: self.user.objectId];
            self.clickCount=0;
            
        }
        
        
        
        
    }
    NSLog(@"Click Count:%d",self.clickCount);
    NSLog(@"RecipientsofBounties:%@",self.recipientsOfBounties);
    NSLog(@"%@",self.user.username);
}
-(BOOL) isFriend:(PFUser *)user{
    for(PFUser *friend in self.friends){
        if([friend.objectId isEqualToString:user.objectId]){ //found friend
            return YES;
        }
    }
    return NO;
    
}
#pragma mark - TO DO
- (void)uploadMessage {
    if([self.points doubleValue] < [@10.0f doubleValue]){
        //if users don't have enough points, don't let them set bounties
        
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You Don't Have Enough Points"
                                                            message:@"Send More Photos!"
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        NSLog(@"you actually have %@",self.points);
        [alertView show];
        [self reset];
    }
    
    else{
        if ([self.recipientsOfBounties count] !=0){
            PFUser *currentUser = [PFUser currentUser];
            PFObject *bounty = [PFObject objectWithClassName:@"Messages"];
            PFObject *bountyNotice = [PFObject objectWithClassName:@"Messages"];
            
            //self.allFriends addObjectsFromArray:currentUser[@"]
            PFACL *readAccess = [[PFACL alloc]init];
            //PFACL *readAccess2 = [[PFACL alloc]init];
            [readAccess setReadAccess:YES forUserId:self.user.objectId];
            //[readAccess2 setReadAccess:NO forUserId:self.user.objectId];
            [bounty setObject:@"bounty" forKey:@"fileType"];
            [bounty setObject:self.recipientsOfBounties forKey:@"recipientIds"];
            [bounty setACL: readAccess];
            [bounty setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
            
            UIAlertView *bountyAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"You Have Set Bounty on %@!",self.user.username]
                                                                  message:@"Good Work."
                                                                 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [bountyAlert show];
            
            [bounty setObject:currentUser.username forKey:@"senderName"];
            [bounty saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                        message:@"Please try sending your message again."
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                    
                }
            }];
            [self.allFriends removeObject:self.user.objectId]; //so guy receiving bounty won't get duplicate notification
            [self.allFriends removeObject: currentUser.objectId]; //so current user doesn't get notifications (might have crash if current user isn't in the array but we'll see)
            self.friends = [NSArray arrayWithArray: self.allFriends];
            NSLog(@"Receiving Bounty Notice: %@",self.friends);
            [bountyNotice setObject:@"bountyNotice" forKey:@"fileType"];
            //[bountyNotice setACL: readAccess2];
            [bountyNotice setObject:self.friends forKey:@"recipientIds"];//notification goes to all friends
            [bountyNotice setObject:self.user.username forKey:@"recipientUsername"];
            [bountyNotice setObject:currentUser.username forKey:@"senderName"];
            [bountyNotice setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
            [bountyNotice setObject: self.user.objectId forKey: @"victimId"];
            [bountyNotice saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                        message:@"Please try sending your message again."
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
                
            }];
            
            [self reset];}
    }
    NSLog (@"No Bounties Set");
}


///PUT PUSH NOTIFICATION FOR ALL CURRENT USERS FRIENDS

-(void) reset{
    PFUser *currentUser = [PFUser currentUser];
    [self.recipientsOfBounties removeAllObjects];
    self.points=currentUser[@"Points"];
    [self.allFriends removeAllObjects];
    
    
    
    
}

- (IBAction)setBounty:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    [self uploadMessage];
    int points = [self.points intValue];
    if ([self.points doubleValue] >[@10.0f doubleValue]){
        self.points = [NSNumber numberWithInt:points-self.bountyCost];
        [currentUser setObject: self.points forKey:@"Points" ];
        [currentUser saveInBackground];}
    NSLog(@"%@",self.points);
    [self.tabBarController setSelectedIndex:0];
    
}
- (IBAction)back:(id)sender {
    [self.tabBarController setSelectedIndex:0];
}


@end
