//
//  HomeViewController.m
//  Rascal
//
//  Created by Phillip Ou on 6/29/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "HomeViewController.h"
#import "FollowButton.h"


 @interface HomeViewController ()
 @property (nonatomic, strong) NSMutableArray *followingArray; //store array of followers
@property (nonatomic, strong) NSMutableArray *savedPhotosArray;

 @end
 
 
 
 @implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // This table displays items in the Todo class
        self.parseClassName = @"Messages";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES; //allows scrolling down to load more pages
        self.objectsPerPage = 3;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   
      
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PFQueryTableViewDataSource and Delegates

//load objects
-(void)objectsDidLoad:(NSError *)error{
    [super objectsDidLoad: error];
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    
    // Retrieve the top songs by sales
    //[query orderByDescending:@"listOfLikers"];
    
    // Limit to retrieving ten songs
    query.limit = 25;
    
   
    
    // Issue the query
    [query findObjectsInBackgroundWithBlock:^(NSArray *songs, NSError *error) {
        if (error) return;
        
    }];
    
}

// return objects in a different indexpath order. in this case we return object based on the section, not row, the default is row

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.section];
    }
    else {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return nil;
    }
    static NSString *CellIdentifier = @"SectionHeaderCell";
    UITableViewCell *sectionHeaderView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     //UILabel *senderLabel = (UILabel *)[sectionHeaderView viewWithTag:2];
    
    
    PFObject *photo = [self.objects objectAtIndex:section];
    NSString *username = [photo objectForKey:@"senderName"];
    //PFUser *user = [photo objectForKey:@"whoTook"];
    //PFFile *profilePictureFile= [user objectForKey:@"profilePicture"];
//PFImageView *profileImageView = (PFImageView*) [sectionHeaderView viewWithTag:6];
   // profileImageView.image = profilePictureFile;
    
            // image can now be set on a UIImageView
    
    
    
    UILabel *userNameLabel = (UILabel *) [sectionHeaderView viewWithTag: 2];
    UILabel *titleLabel = (UILabel *) [sectionHeaderView viewWithTag:3];
    UILabel *numberOfLikesLabel = (UILabel *) [sectionHeaderView viewWithTag:4];
    NSString *caption = [photo objectForKey:@"caption"];
    
    titleLabel.text=caption;
    userNameLabel.text = [NSString stringWithFormat:@"by %@",username];
    NSInteger *numberOfLikes = [photo[@"listOfLikers"] count];
    numberOfLikesLabel.text = [NSString stringWithFormat: @"%d",numberOfLikes];
    
    
    sectionHeaderView.backgroundColor = [UIColor whiteColor];
    
       return sectionHeaderView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = self.objects.count; //number of sections = number of objects
    if (self.paginationEnabled && sections >0) {
        sections++; //add 1 to sections so we can keep scrolling
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;   //1 row per section
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    if (indexPath.section == self.objects.count) { //if we're at the end (the last section)
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath]; //get that cell(LoadMoreCell)
        return cell;
    }
    static NSString *CellIdentifier = @"PhotoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    PFImageView *photo = (PFImageView *)[cell viewWithTag:1];
    photo.file = object[@"file"]; //save photo.file in key image
    [photo loadInBackground]; //load photo
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f; //make loadmore cell disappear
    }
    return 50.0f; //width of cell
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.objects.count) {
        return 50.0f;
    }
    return 400.0f; //height of cell
}

//use this cell to load next page
- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"LoadMoreCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if we select the loadmorecell
    if (indexPath.section == self.objects.count && self.paginationEnabled) {
        [self loadNextPage];
    }
}



        
- (PFQuery *)queryForTable {
        //if user isn't signed in, don't initialize the query;  !!!!!!!!!!
        
        //!!!!! we don't have fb installed yet so this method can't be used just yet
        
        //profile view will crash if this is not commented out
        
        //need if statement to sign in, but page won't load
        
        //when not commented out, logging out and signing works without crashing. but home and profile won't load
        //when commented out, home and profile load but cannot sign in once logged out.
    
    
    
   /* if (![PFUser currentUser] || ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
         return nil;
         }*/
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query whereKey:@"fileType" equalTo:@"image"];
        
        //[query includeKey:@"whoTook"];
    
    
    
        [query orderByDescending:@"numberOfLikes"];
    [query addDescendingOrder:@"createdAt"];
        return query;
}








@end
