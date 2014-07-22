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
#import <MessageUI/MessageUI.h>

@interface EditFriendsViewController ()
{
    
    __block NSArray *FBfriends;
    __block NSMutableArray *mArray;
}

@end

@implementation EditFriendsViewController



- (void)viewDidLoad
{
    self.searchResults = [NSMutableArray arrayWithCapacity:[self.allUsers count]];
     self.allUsernames = [[NSMutableArray alloc]init];
    self.userDict = [[NSMutableDictionary alloc]init];
    
    
    PFQuery *query = [PFUser query];//get query of all users in this app
    [super viewDidLoad];
    [query orderByAscending: @"username"]; //alphabetize list
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error:%@ %@", error, [error userInfo]);
        }
        else{
            self.allUsers = objects;
            for (PFObject *obj in self.allUsers) {
                // access the username key of the PFObject and add it to the array we created.
                [self.allUsernames addObject:[obj objectForKey:@"username"]];
                [self.userDict setObject:obj forKey:[obj objectForKey:@"username"]];
                
                }
            [self.tableView reloadData];
        }
        NSLog(@"%@", self.userDict);
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
       
        return [self.searchResults count];}
    
    
    // Return the number of rows in the section.
    return [self.allUsers count]; //number of rows = number of users
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
       NSString *username= [self.searchResults objectAtIndex:indexPath.row];
        cell.textLabel.text = username;
        //cell = [self.userDict objectForKey:username];
        }
    else{
    cell.textLabel.text = user.username;
    
    //if user is a friend then have a check mark
    if([self isFriend:user]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType= UITableViewCellAccessoryNone;
    }
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *username = cell.textLabel.text;
        
        //cell.accessoryType = UITableViewCellAccessoryCheckmark; //put check mark
        //PFUser *user = [self.allUsers objectAtIndex: indexPath.row];
        PFUser *user = [self.userDict objectForKey:username];
        PFRelation *friendsRelation = [self.currentUser relationForKey: @"friendsRelation"];//adding friends
        NSLog(@"%@",user.username);
        
        if([self.friends containsObject:user.username]){
            
            //1. remove check mark
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
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
    }
else{
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
        for (PFUser *friend in[self.friends copy] ){
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
        }
    /*[self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        {
            if(error){
                NSLog(@"Error %@ %@, error", [error userInfo]);
            }
        }
    }];
   
        
        
    }*/
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        {
            if(error){
                NSLog(@"Error %@ %@, error", [error userInfo]);
            }
        }
    }];
    [self.tableView reloadData];

    
    
    
    
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{[self.searchResults removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    self.searchResults = [NSMutableArray arrayWithArray: [self.allUsernames filteredArrayUsingPredicate:resultPredicate]];
    
    NSLog(@"%@",self.searchResults);
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (IBAction)sendSMS:(id)sender {
    MFMessageComposeViewController *textComposer = [[MFMessageComposeViewController alloc] init];
    textComposer.messageComposeDelegate = self;
    //[textComposer setMessageComposeDelegate:self];
    //if there is a thing to send texts
    if([MFMessageComposeViewController  canSendText]){
        [textComposer setRecipients:[NSArray arrayWithObjects:nil]];
        [textComposer setBody:@"App Link Here"];
        //send to iMessage
        [self presentViewController:textComposer animated:YES completion:nil];
        
    }
    else{
        NSLog(@"unable to load iMessage");
    }
}
//dismiss sms view controller when we're done with it.
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [controller dismissModalViewControllerAnimated:YES];
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
