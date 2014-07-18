//
//  HomeViewController.h
//  Rascal
//
//  Created by Phillip Ou on 6/29/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <Parse/Parse.h>
#import "FollowButton.h"

@interface HomeViewController : PFQueryTableViewController <FollowButtonDelegate>
@property (nonatomic, weak) id <FollowButtonDelegate> delegate;







@end
