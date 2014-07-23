//
//  InboxViewController.h
//  Rascal
//
//  Created by Phillip Ou on 7/9/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ImageViewController.h"
@interface InboxViewController : PFQueryTableViewController
@property(nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) PFObject *selectedMessage;
@property(nonatomic, strong) NSArray *bounties;
@property(nonatomic, strong) NSArray *posts;


@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionFileType;

@property (strong, nonatomic) IBOutlet PFImageView *profileImageView;

@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;
@property (nonatomic) NSNumber *count;

-(IBAction) logout: (id)sender;
@end
