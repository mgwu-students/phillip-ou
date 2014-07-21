//
//  InboxViewController.m
//  Rascal
//
//  Created by Phillip Ou on 7/9/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//



#import "InboxViewController.h"
#import "ImageViewController.h"
#import "CameraViewController.h"

@interface InboxViewController ()

@end

@implementation InboxViewController

-(id) initWithCoder:(NSCoder *)aCoder{
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        self.parseClassName = @"Messages";
        
        
        // Whether the built-in pull-to-refresh is enabled
       // self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        self.objectsPerPage = 30;
        
        // The number of objects to show per page
        
    }
    //NSLog(@"%@",self.objects);
    return self;
}
-(void) objectsDidLoad: (NSError *)error{
    [super objectsDidLoad: error];
    if(![PFUser currentUser] && ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
        NSLog(@"ByPass");
    }
    else{
       
    NSLog(@"%@",self.objects);
    
    [self.sections removeAllObjects];
    [self.sectionFileType removeAllObjects];
    
    
    NSInteger section = 0;
    NSInteger rowIndex = 0;
    
    for (PFObject *object in self.objects){
        // NSLog(@"%@",self.sections);
        NSString *fileType = [object objectForKey:@"fileType"];
        
        NSMutableArray *objectsInSection = [self.sections objectForKey: fileType];
        
        
        
        //all objects of a particular file type go in that section ^
        
        if (!objectsInSection){
            objectsInSection = [NSMutableArray array];
            //this is the first time we see this sportType
            
            //increment section index
            [self.sectionFileType setObject:fileType forKey: [NSNumber numberWithInt: section++]]; //{0 : fileType, 1: fileType}
            
            // NSLog(@"%@", [self.sectionFileType objectForKey:0]);
            //check which sports type belongs to section 0
            //use section number to get
        }
        
        
        [objectsInSection addObject: [NSNumber numberWithInt: rowIndex++]]; //[0,1,2];
        //NSLog(@"filetypeeee:%@",objectsInSection);
        [self.sections setObject: objectsInSection forKey:fileType];
        
        NSLog(@"%@",self.sections);
        //{fileType:[0,1,2], fileType:[0,1]} <--row
        
    }
    
    //NSLog(@"%@",self.sections);
}
}
#pragma mark - header font
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIFont fontWithName:@"Raleway-Thin" size:25.0], NSFontAttributeName, nil]];
    self.sectionFileType = [[NSMutableDictionary alloc] init];
    self.sections = [[NSMutableDictionary alloc]init];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    PFUser *currentUser = [PFUser currentUser];
    
    
    
    
    
   
    
    
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.username);
    }
    else {
       // [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
}
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES; //!!!this hides the tab bar!!!
    PFUser *currentUser = [PFUser currentUser];
    self.pointsLabel.text = [NSString stringWithFormat:@"Income: %@", currentUser[@"Points"]];
    
    //ensures new users have points to start off with
    if(![currentUser objectForKey:@"Points"]){
       
        [currentUser setObject: [NSNumber numberWithInt:20] forKey:@"Points"];
        [currentUser save];
    }
    //PFUser *currentUser = [PFUser currentUser];
    PFFile *profilePicture = [currentUser objectForKey:@"profilePicture"];
    
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.cornerRadius = 20;
    
    self.profileImageView.file = profilePicture;
    [self.profileImageView loadInBackground];
    
    self.userNameLabel.text = currentUser.username;
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSString *fileType = [self fileTypeForSection:indexPath.section];
    //NSLog(@"files:%@",fileType);
    
    NSArray *rowIndecesInSection = [self.sections objectForKey:fileType];
    
    NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row];
    return [self.objects objectAtIndex:[rowIndex intValue]];
}
//load up messages sent to you

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    PFUser *currentUser = [PFUser currentUser];
   
    if(currentUser !=nil){
        [query whereKey:@"recipientIds" containsAllObjectsInArray:@[currentUser.objectId]];
        [query whereKey:@"fileType" containedIn:@[@"image",@"bountyNotice"]];
        
        [query orderByAscending:@"fileType"];
        [query addDescendingOrder:@"createdAt"];
    
    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
   
   
  
    }
    return query;
}

-(NSString *) fileTypeForSection: (NSInteger) section{
    
    return [self.sectionFileType objectForKey: [NSNumber numberWithInt: section]];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    return self.sections.allKeys.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSString *fileType = [self fileTypeForSection:section];
    //NSLog(@"section:%d",section);
    NSArray *rowIndecesInSection = [self.sections objectForKey:fileType];
    // Return the number of rows in the section.
    //NSLog(@"using %@:",rowIndecesInSection);
    return rowIndecesInSection.count;
    
}

-(NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *fileType = [self fileTypeForSection:section];
    if([fileType isEqualToString:@"bountyNotice"]){
        return @"Active Bounties";
    }
    
    else{
        return @"Photos";
    }
    //return fileType;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{   //NSLog(@"This is being called");
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    UIImage *icon = [UIImage imageNamed: @"image"];
    UIImage *icon2 = [UIImage imageNamed:@"camera-2-smaller"];
    
    UIButton *photoUnread = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 16, 16)];
    
    UIButton *bountyLogo = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 16, 16)];

    
    [UIButton buttonWithType: UIButtonTypeCustom];
    [photoUnread setBackgroundImage:icon forState:UIControlStateNormal];
     photoUnread.backgroundColor = [UIColor clearColor];
    
    [bountyLogo setBackgroundImage:icon2 forState:UIControlStateNormal];
     bountyLogo.backgroundColor = [UIColor clearColor];
    
    
    
    
    PFUser *currentUser = [PFUser currentUser];
    if (indexPath.section == self.objects.count) { //if we're at the end (the last section)
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath]; //get that cell(LoadMoreCell)
        return cell;
    }
    
    //NSLog(@"%@",self.objects);
    //NSLog(@"%@",self.sections);
   // NSLog(@"%@",self.sectionFileType);
    //get row number independent of section
    NSInteger rowNumber = 0;
    
    for (NSInteger i = 0; i < indexPath.section; i++) {
        rowNumber += [self tableView:tableView numberOfRowsInSection:i];
    }
    
    rowNumber += indexPath.row;
    PFObject *message = [self.objects objectAtIndex:rowNumber];
    
        //NSLog(@"%@",message);
    //PFObject *message = [self.objects objectForKey:[NSNumber numberWithInteger:indexPath.row ]];
    
    //cell.textLabel.text = [NSString stringWithFormat:@"FileType:%@",message[@"fileType"]];
    
    
    
    
     NSString *fileType = [message objectForKey:@"fileType"];
     NSArray *listOfRecipients = [message objectForKey:@"recipientIds"];
     NSString* read = [message objectForKey:@"read"];     //determine if cell is read
    
     //if message is an image
     if ([fileType isEqualToString:@"image"]) {
     //PUT IN IMAGE ICON HERE LATER TO SIGNIFY IT'S AN IMAGE
         //cell.imageView.image = [UIImage imageNamed:@"image"];
         cell.textLabel.text= [NSString stringWithFormat:@"%@ ",[message objectForKey:@"senderName"]];
         cell.imageView.image = [UIImage imageNamed:@"image"];
         
         //for read messages
         if([read isEqualToString:@"Yes"]){
             //cell.accessoryView= photoUnread;
             cell.imageView.image = [UIImage imageNamed:@"marquee-smaller"];
         }
         

     
     
     }
    
     
     if([fileType isEqualToString: @"bounty"] &&[listOfRecipients containsObject:currentUser.objectId]) {
     cell.textLabel.text= [NSString stringWithFormat:@"%@ set a Bounty on you!",[message objectForKey:@"senderName"]];
     
   
     }
     if([fileType isEqualToString:@"bountyNotice"]&&[listOfRecipients containsObject:currentUser.objectId]){
     cell.textLabel.text = [NSString stringWithFormat:@"Bounty on %@", [message objectForKey:@"recipientUsername"]];
     //cell.textLabel.text= [NSString stringWithFormat:@"%@ ----> %@",[message objectForKey:@"senderName"],[message objectForKey: @"recipientUsername"]];
     cell.imageView.image = [UIImage imageNamed:@"spam-2"];
         //if bounty is unread
         if(![read isEqualToString:@"Yes"]){
             cell.accessoryView = bountyLogo;
             
         }
         
        
     }
    
    
    
    
    return cell;
    
    
}- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES - we will be able to delete all rows
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    //add code here for when you hit delete
    NSLog(@"Delete");
        NSInteger rowNumber = 0;
        
        for (NSInteger i = 0; i < indexPath.section; i++) {
            rowNumber += [self tableView:tableView numberOfRowsInSection:i];
        }
        
        rowNumber += indexPath.row;
    self.selectedMessage = [self.objects objectAtIndex:rowNumber];
        NSString *fileType = self.selectedMessage[@"fileType"];
        
        
     
       //delete form sections
        NSLog (@"%@",self.selectedMessage);
        NSMutableArray *deleteArray = [NSMutableArray arrayWithArray:self.selectedMessage[@"recipientIds"]] ;
        
        [deleteArray removeObject:[[PFUser currentUser] objectId] ];
        NSArray *updateArray =[self.sections objectForKey:fileType];
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:updateArray];
        [newArray removeObjectAtIndex:indexPath.row];
        updateArray = [NSArray arrayWithArray: newArray];
        [self.sections removeObjectForKey:fileType];
        [self.sections setObject:updateArray forKey:fileType];
        
        
        NSLog (@"%@",self.selectedMessage);
   //delete from array
        
        [deleteArray removeObject:[[PFUser currentUser] objectId] ];
        NSLog(@"RecipientIds:%@",deleteArray);
        NSArray *arrayUpdate = [NSArray arrayWithArray:deleteArray];
        [self.selectedMessage setObject:arrayUpdate forKey:@"recipientIds"];
        [self.selectedMessage save]; //ensures array gets updated before there is index error after delete
    [self.tableView reloadData];
    [self viewDidLoad];
        
        
    }
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser *currentUser = [PFUser currentUser];
    NSInteger rowNumber = 0;
    
    
    
    for (NSInteger i = 0; i < indexPath.section; i++) {
        rowNumber += [self tableView:tableView numberOfRowsInSection:i];
    }
    
    rowNumber += indexPath.row;
    self.selectedMessage = [self.objects objectAtIndex:rowNumber];
    //self.selectedMessage = [self.messages objectAtIndex:indexPath.row];
    NSString *fileType = [self.selectedMessage objectForKey:@"fileType"];
    NSLog(@"%@ is filetype",fileType);
    
    if([fileType isEqualToString:@"image"]) {
        [self performSegueWithIdentifier:@"showImage" sender:self];
        NSLog(@"load image");}
    if([fileType isEqualToString:@"bountyNotice"]){
        NSLog(@"show camera");
        NSString *bountyMessage = [NSString stringWithFormat:@"Bounty set by %@", self.selectedMessage[@"senderName"]];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:bountyMessage
                                                            message:@"You Will Be Rewarded For This Photo"
                                                           delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:nil];
        [alertView show];
        
               
        
        
        [self performSegueWithIdentifier:@"transferBountyData" sender:self];
        
        
        
        //[self.tabBarController setSelectedIndex:2];
    }
       else{NSLog(@"error come on dude");}
 
    // Delete it!
    /*NSMutableArray *recipientIds = [NSMutableArray arrayWithArray:[self.selectedMessage objectForKey:@"recipientIds"]];
    NSLog(@"Recipients: %@", recipientIds);
    
    if ([recipientIds count] == 1) {
        // Last recipient - delete!
     
    }
    else {
        // Remove the recipient and save
        [recipientIds removeObject:[[PFUser currentUser] objectId]];
        [self.selectedMessage setObject:recipientIds forKey:@"recipientIds"];
        [self.selectedMessage saveInBackground];
    }*/
    
}
- (IBAction)logout:(id)sender {
   
    [PFFacebookUtils unlinkUser:[PFUser currentUser]];
    [PFUser logOut];
    if([PFUser currentUser]){
        NSLog(@"You haven't logged out");
    }
    //[self performSegueWithIdentifier:@"showLogin" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   /* if ([segue.identifier isEqualToString:@"showLogin"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    }*/
    /*else*/ if ([segue.identifier isEqualToString:@"showImage"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        ImageViewController *imageViewController = (ImageViewController *)segue.destinationViewController;
        imageViewController.message = self.selectedMessage;}
        //passing variables to cameraViewController (sender & recipient of bounties)
        
        else{
            NSLog(@"Passing to Camera");
            [segue.destinationViewController setHidesBottomBarWhenPushed:NO];
            CameraViewController *cameraViewController = (CameraViewController *)segue.destinationViewController;
            cameraViewController.message = self.selectedMessage;
            
        }
    }

- (IBAction)setBounties:(id)sender {
    [self.tabBarController setSelectedIndex:5];
}

- (IBAction)profileButton:(id)sender {
    [self.tabBarController setSelectedIndex:3];
}

- (IBAction)topButton:(id)sender {
    [self.tabBarController setSelectedIndex:1];
}


- (IBAction)editFriends:(id)sender {
    [self.tabBarController setSelectedIndex:4];
}



@end

