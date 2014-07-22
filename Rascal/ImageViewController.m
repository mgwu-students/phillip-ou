//
//  ImageViewController.m
//  Rascal
//
//  Created by Phillip Ou on 7/9/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    PFUser *currentUser = [PFUser currentUser];
    PFFile *imageFile = [self.message objectForKey: @"file"];
    
    
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageFile.url]];
    
   
    self.imageView.image = [UIImage imageWithData:imageData];
    
    
   
    if(![self.message[@"readUsers"] containsObject: currentUser.objectId]){
        NSMutableArray *readUsersArray = [NSMutableArray arrayWithArray:self.message[@"readUsers"]];
        [readUsersArray addObject:currentUser.objectId];
        [self.message  setObject:[NSArray arrayWithArray:readUsersArray]forKey:@"readUsers"];
       
    }
     [self.message saveInBackground];
    

}
-(void) viewDidAppear:(BOOL)animated{
    
    
    
    //who sent it?
   
    NSString *senderName = [self.message objectForKey:@"senderName"];
    NSString *caption = [self.message objectForKey:@"caption"];
    
    self.senderLabel.text=[NSString stringWithFormat:@"by %@",senderName];
    self.captionLabel.text = caption;
    self.captionLabel.numberOfLines = 1;
    self.captionLabel.minimumFontSize =10.;
    self.captionLabel.adjustsFontSizeToFitWidth = YES;
    
    int numberOfLikes = [self.message[@"listOfLikers"] count];
    
    [self.toolBarLabel setTitle: [NSString stringWithFormat: @"%d",numberOfLikes]];
    
    
    self.numberOfLikesLabel.text =[NSString stringWithFormat:@"%d",numberOfLikes];
    if([self.message[@"listOfLikers"] containsObject: [[PFUser currentUser]username]]){
        self.likeButton.selected = YES;}
    
}
-(IBAction)ButtonReleased:(id)sender
{
    self.likeButton.selected=YES;
    /*[self.likeButton setBackgroundImage:[UIImage imageNamed:@"ImageWhenReleased.png"] forState:UIControlStateNormal];*/
}

- (IBAction)Like:(id)sender {
    NSLog(@"Like Button Pressed");
    PFUser *currentUser  =[PFUser currentUser];
    [self ButtonReleased:self];
    self.listOfLikers = [NSMutableArray array];
   // NSString *user = [self.message objectForKey:@"senderName"];
   
    //ask benji whyit keeps adding users of hte same username
    //also ask why label doesn't update instantaneously
    if(![self.message[@"listOfLikers"] containsObject: currentUser.username]){
        [self.message addObject:currentUser.username forKey:@"listOfLikers"];
        NSNumber *numberOfLikes = [self.message objectForKey:@"numberOfLikes"];
        int numlikes = [numberOfLikes integerValue];
        numberOfLikes = [NSNumber numberWithInteger: numlikes+1];
        [self.message setObject:numberOfLikes forKey:@"numberOfLikes"];
        

    }
    
    
    
    [self.message saveEventually:^(BOOL succeeded, NSError *error) {
        if(error){
            NSLog(@"fuck");
        }
    }];
   
   
}






@end
