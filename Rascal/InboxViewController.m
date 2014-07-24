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
       self.pullToRefreshEnabled = YES;
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        self.objectsPerPage = 50;
        
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
       
    NSLog(@"call1");
        

        
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
        
        //NSLog(@"%@",self.sections);
        //{fileType:[0,1,2], fileType:[0,1]} <--row
        
    }
    
    //NSLog(@"%@",self.sections);
}
   
}
#pragma mark - header font
- (void)viewDidLoad

{
    NSLog(@"%@",self.count);
    self.bountyButton.selected=NO;
    /*if([self.count intValue]!=1){
        NSLog(@"calling this!!");
        PFUser *currentUser = [PFUser currentUser];
        PFObject *bountyNotice = [PFObject objectWithClassName:@"Messages"];
        [bountyNotice setObject:@"bountyNotice" forKey:@"fileType"];
        //[bountyNotice setACL: readAccess2];
        [bountyNotice setObject:@"placeholder" forKey:@"placeholder"];
        [bountyNotice setObject:@[currentUser.objectId] forKey:@"recipientIds"];//notification goes to all friends
        [bountyNotice setObject:@"Innocent Bystander" forKey:@"recipientUsername"];
        [bountyNotice setObject:currentUser.username forKey:@"senderName"];
        [bountyNotice setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
        [bountyNotice setObject:[[PFUser currentUser] objectId] forKey:@"victimId"];
        NSNumber *zero = [NSNumber numberWithInt:0];
        [bountyNotice setObject:zero  forKey:@"bountyValue"];
        [bountyNotice setObject: @"A" forKey:@"payForId"];
        
        [bountyNotice saveInBackground];
        self.count=[NSNumber numberWithInt:2];}*/
     
    [self loadObjects];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIFont fontWithName:@"Raleway-Thin" size:25.0], NSFontAttributeName, nil]];
    
    self.sectionFileType = [[NSMutableDictionary alloc] init];
    self.sections = [[NSMutableDictionary alloc]init];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    
    [self.tableView insertRowsAtIndexPaths: 0 withRowAnimation:NO];
    
    
    
    
    
    
    
    
   
    
    self.tabBarController.tabBar.hidden = YES; //!!!this hides the tab bar!!!
    //PFUser *currentUser = [PFUser currentUser];
   
    
    //ensures new users have points to start off with
    /*if(![currentUser objectForKey:@"Points"]){
        
        [currentUser setObject: [NSNumber numberWithInt:20] forKey:@"Points"];
        [currentUser save];
    }*/

    
    [super viewDidLoad];
    }
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    PFUser *currentUser = [PFUser currentUser];
   
    //[self.tableView reloadData];
    //PFUser *currentUser = [PFUser currentUser];
    PFFile *profilePicture = [currentUser objectForKey:@"profilePicture"];
     self.pointsLabel.text = [NSString stringWithFormat:@"Income: %@", currentUser[@"Points"]];
    
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.cornerRadius = 20;
    
    self.profileImageView.file = profilePicture;
    [self.profileImageView loadInBackground];
    
    self.userNameLabel.adjustsFontSizeToFitWidth=YES;
    
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
   
    return rowIndecesInSection.count; //this is some times too much
    
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
static int rowNumber;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{   //NSLog(@"This is being called");
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
   /* UITableViewCell *customCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:0];
    customCell.textLabel.text = @"test";
    if ([self.sectionFileType[@"bountyNotice"] count] ==0){
        return customCell;}*/
   
    cell.textLabel.adjustsFontSizeToFitWidth=YES;
    
    
    
    UIImage *icon = [UIImage imageNamed: @"image-bigger"];
    UIImage *icon2 = [UIImage imageNamed:@"camera-2"];
    UIImage *icon3 = [UIImage imageNamed:@"database"];
    UIImage *icon4 = [UIImage imageNamed:@"tick"];
    
    UIButton *photoUnread = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 16, 16)];
    
    UIButton *bountyLogo = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 16, 16)];
    
    
    UIButton *moneyLogo = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 16, 16)];
    
    UIButton *checkedOff = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 16, 16)];


    
    [UIButton buttonWithType: UIButtonTypeCustom];
    [photoUnread setBackgroundImage:icon forState:UIControlStateNormal];
     photoUnread.backgroundColor = [UIColor clearColor];
    
    [bountyLogo setBackgroundImage:icon2 forState:UIControlStateNormal];
     bountyLogo.backgroundColor = [UIColor clearColor];
    
    [moneyLogo setBackgroundImage:icon3 forState:UIControlStateNormal];
    moneyLogo.backgroundColor = [UIColor clearColor];
    
    [checkedOff setBackgroundImage:icon4 forState:UIControlStateNormal];
    checkedOff.backgroundColor = [UIColor clearColor];
    
    
    
    
    
    PFUser *currentUser = [PFUser currentUser];
    if (indexPath.section == self.objects.count) { //if we're at the end (the last section)
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath]; //get that cell(LoadMoreCell)
        return cell;
    }
    
    //NSLog(@"%@",self.objects);
    //NSLog(@"%@",self.sections);
   // NSLog(@"%@",self.sectionFileType);
    //get row number independent of section
    rowNumber = 0;
    
    for (NSInteger i = 0; i < indexPath.section; i++) {
        rowNumber += [self tableView:tableView numberOfRowsInSection:i];
    }
    
    rowNumber += indexPath.row;
    if(self.objects==nil){
        NSLog(@"waiting");
    }
    
   
   
    PFObject *message = [self.objects objectAtIndex:rowNumber];
    
        //NSLog(@"%@",message);
    //PFObject *message = [self.objects objectForKey:[NSNumber numberWithInteger:indexPath.row ]];
    
    //cell.textLabel.text = [NSString stringWithFormat:@"FileType:%@",message[@"fileType"]];
    
    cell.accessoryType=UITableViewCellAccessoryNone;
    [cell.textLabel setFont:[UIFont fontWithName:@"Raleway-Medium" size:14]];
     NSString *fileType = [message objectForKey:@"fileType"];
     NSArray *listOfRecipients = [message objectForKey:@"recipientIds"];
    // NSString* read = [message objectForKey:@"read"];     //determine if cell is read
    if([fileType isEqualToString:@"bountyNotice"]){
        //if([listOfRecipients containsObject:currentUser.objectId]){
        cell.imageView.image = [UIImage imageNamed:@"user-3-big"];
        
        cell.accessoryView=bountyLogo;
        cell.textLabel.text = [[NSString stringWithFormat:@"%@", [message objectForKey:@"recipientUsername"]] lowercaseString];
        }
     //if message is an image
     //if ([fileType isEqualToString:@"image"]) {
    else{
     //PUT IN IMAGE ICON HERE LATER TO SIGNIFY IT'S AN IMAGE
         //cell.imageView.image = [UIImage imageNamed:@"image"];
         cell.textLabel.text= [NSString stringWithFormat:@"%@ ",[[message objectForKey:@"senderName"]lowercaseString]];
         cell.imageView.image = [UIImage imageNamed:@"image-big"];
         
         //for read messages
        
         if([[message objectForKey:@"readUsers"] containsObject:currentUser.objectId]){
             UIImage *marquee =[UIImage imageNamed:@"marquee"];
             
             cell.imageView.image =marquee;
             
         }
         //show this is a return of his investment
         
         if([message[@"payForId"] isEqualToString:currentUser.objectId]){
             if([message[@"fileType"] isEqualToString:@"image"]){
                 if(![message[@"readUsers"] containsObject:currentUser.objectId]){
             cell.accessoryView = moneyLogo;
                 }
             }
         }
     
     
     }
    
    
    /* if([fileType isEqualToString: @"bounty"] &&[listOfRecipients containsObject:currentUser.objectId]) {
     cell.textLabel.text= [NSString stringWithFormat:@"%@ set a Bounty on you!",[message objectForKey:@"senderName"]];
     
   
     }
    
                    
            
            cell.imageView.image = [UIImage imageNamed:@"user-3-big"];
            cell.accessoryView=bountyLogo;
         
        }*/
        
    
   
    
    
    
    return cell;
    
    
}

//allows right swiping
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    //prevents you from deleting last row
    //innocent by standers
    NSMutableArray *bountyNoticeArray =[self.sections objectForKey:@"bountyNotice"];
    
    if(indexPath.row==[bountyNoticeArray count]-1){
        return NO;}
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
        [self.selectedMessage saveInBackground]; //ensures array gets updated before there is index error after delete
        }
    
    
    [self.tableView reloadData];
        
        
    
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser *currentUser = [PFUser currentUser];
    NSInteger rowNumber = 0;
    
    self.count = [NSNumber numberWithInt:0];
    
    for (NSInteger i = 0; i < indexPath.section; i++) {
        rowNumber += [self tableView:tableView numberOfRowsInSection:i];
    }
    
    rowNumber += indexPath.row;
    self.selectedMessage = [self.objects objectAtIndex:rowNumber];
    //self.selectedMessage = [self.messages objectAtIndex:indexPath.row];
    
    NSString *fileType = [self.selectedMessage objectForKey:@"fileType"];
    //NSLog(@"%@ is filetype",fileType);
    NSLog(@"ROW NUMBER:%d",rowNumber);
    if([fileType isEqualToString:@"image"]) {
        
        
        //if this photo is a reply to a bounty set by this user give him his points (give back his investment)
        
        
    if([self.selectedMessage[@"payForId"] isEqualToString:currentUser.objectId])
        {if(![self.selectedMessage[@"readUsers"] containsObject:currentUser.objectId]){
            int earned = [self.selectedMessage[@"payAmount"] intValue];
            int currentPoints = [currentUser[@"Points"] intValue];
            NSNumber *points = [NSNumber numberWithInt: earned+currentPoints];
            [currentUser setObject:points forKey:@"Points"];
            NSLog(@"Points earned");
            [currentUser saveInBackground];
            [self.selectedMessage saveInBackground];
            
        }
        
        
        
       
        
        
            
        
       
            [self.tableView reloadData];}
         [self performSegueWithIdentifier:@"showImage" sender:self];
    }
  
     
    if([fileType isEqualToString:@"bountyNotice"]){
            NSLog(@"show camera");
        //if(![self.selectedMessage[@"readUsers"] containsObject:currentUser.objectId]){
            NSString *bountyMessage = [NSString stringWithFormat:@"Bounty set by %@", self.selectedMessage[@"senderName"]];
                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:bountyMessage
                                                                    message:@"You Will Be Rewarded For This Photo"
                                                                   delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:nil];
                [alertView show];
            [self performSegueWithIdentifier:@"transferBountyData" sender:self];
        
       // }
       // else{
      //      NSLog(@"You've done this bounty already");
      //  }
    
        
        
        
        
        }
        
        
        //[self.tabBarController setSelectedIndex:2];
    }

    
 
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

//Customize header view section


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /// Create custom view to display section header...
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    
   
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    //NSString *string =[self.messages objectAtIndex:section];
    if (section==0 ){
        NSString *string = @"active bounties";
        [label setText:string];
        [label setTextColor: [UIColor whiteColor] ];
        
        [label setFont:[UIFont fontWithName:@"Raleway-Medium" size:15]];
        [view addSubview:label];
        [view setAlpha: 0.9];
        [view setBackgroundColor:[UIColor colorWithRed:41.0/255.0 green:166.0/255.0 blue:121.0/255.0 alpha:1.0]]; //your background color...
            return view;}

    else{
        NSString  *string = @"completed bounties";
        [label setText:string];
        [label setTextColor: [UIColor whiteColor] ];
        [label setFont:[UIFont fontWithName:@"Raleway-Medium" size:15]];
        [view addSubview:label];
        [view setAlpha: 0.9];
        [view setBackgroundColor:[UIColor colorWithRed:51/255.0 green:70/255.0 blue:192/255.0 alpha:1.0]]; //your background color...
        
        //button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 30.0, 330, 40.0)]; //(x,y,width,height)
        button.tag = section;
        [button setTitle: @"See Highlights" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:51/255.0 green:70/255.0 blue:192/255.0 alpha:1.0] forState:UIControlStateNormal];
        [button setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:18]];
        [[button layer] setBorderWidth:2.0f];
        [[button layer] setBorderColor:[UIColor colorWithRed:51/255.0 green:70/255.0 blue:192/255.0 alpha:1.0].CGColor];
        button.hidden = NO;
        [button setBackgroundColor:[UIColor whiteColor]];
        [button addTarget:self action:@selector(topButton:) forControlEvents:UIControlEventTouchDown];
        [view addSubview:button];
        
        
        
        return view;

        }
    // Section header is in 0th index...
   }

//heights of section headers
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return 30.f;}
    return 70.f;
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
    
    if([segue.identifier isEqualToString:@"transferBountyData"]){
            NSLog(@"Passing to Camera");
            [segue.destinationViewController setHidesBottomBarWhenPushed:NO];
            CameraViewController *cameraViewController = (CameraViewController *)segue.destinationViewController;
            cameraViewController.message = self.selectedMessage;
           
            
        }
    else {
        [segue.destinationViewController setHidesBottomBarWhenPushed:NO];
        ImageViewController *imageViewController = (ImageViewController *)segue.destinationViewController;
        imageViewController.message = self.selectedMessage;}
    //passing variables to cameraViewController (sender & recipient of bounties)

    }

- (IBAction)setBounties:(id)sender {
    //self.bountyButton.selected = YES;
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

