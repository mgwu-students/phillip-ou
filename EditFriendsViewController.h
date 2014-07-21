//
//  EditFriendsViewController.h
//  Rascal
//
//  Created by Phillip Ou on 7/8/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface EditFriendsViewController : UITableViewController
@property (nonatomic, strong) NSArray *allUsers;
@property (nonatomic, strong) NSMutableArray *allUsernames;
@property (nonatomic, strong) NSMutableDictionary *userDict;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSMutableArray *friends; //array of friends we can edit 
-(BOOL) isFriend:(PFUser*) user;

@end
