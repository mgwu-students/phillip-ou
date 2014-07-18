//
//  EditFriendsViewController.m
//  Rascal
//
//  Created by Phillip Ou on 7/8/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "EditFriendsViewController.h"
#import <Parse/Parse.h>
#import<AddressBook/AddressBook.h>

@interface EditFriendsViewController ()

@end

@implementation EditFriendsViewController



- (void)viewDidLoad
{
        
    
    
    PFQuery *query = [PFUser query];//get query of all users in this app
    [super viewDidLoad];
    [query orderByAscending: @"username"]; //alphabetize list
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error:%@ %@", error, [error userInfo]);
        }
        else{
            self.allUsers = objects;
            [self.tableView reloadData];
        }
    }];
    self.currentUser = [PFUser currentUser];
    
    
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
    return [self.allUsers count]; //number of rows = number of users
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    //if user is a friend then have a check mark
    if([self isFriend:user]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType= UITableViewCellAccessoryNone;
    }
    return cell;
}
#pragma mark - Helper Methods
-(BOOL) isFriend:(PFUser *)user{
    for(PFUser *friend in self.friends){
        if([friend.objectId isEqualToString:user.objectId]){ //found friend
            return YES;
        }
    }
    return NO;
    
       }


-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //cell.accessoryType = UITableViewCellAccessoryCheckmark; //put check mark
    PFUser *user = [self.allUsers objectAtIndex: indexPath.row];
    PFRelation *friendsRelation = [self.currentUser relationForKey: @"friendsRelation"];//adding friends
    
    //if user tapped is a friend remove them
    if([self isFriend:user]){
        //1. remove check mark
        cell.accessoryType = UITableViewCellAccessoryNone;
        //2. remove from the array of friends
        for (PFUser *friend in self.friends){
            if([friend.objectId isEqualToString:user.objectId]){
                [self.friends removeObject:friend];
                
            }
        //3. remove from the backend
        [friendsRelation removeObject:user];
            
        }
        
    }
    ///else add them
    

    else{
        cell.accessoryType = UITableViewCellAccessoryCheckmark; //add checkmark
        [self.friends addObject:user];
        
        [friendsRelation addObject: user ];
        
    }
    
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        {
            if(error){
                NSLog(@"Error %@ %@, error", [error userInfo]);
            }
        }
    }];
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
