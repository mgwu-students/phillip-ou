//
//  TutorialViewController.m
//  Rascal
//
//  Created by Phillip Ou on 7/26/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//


#import "TutorialViewController.h"
#import "InboxViewController.h"

@interface TutorialViewController ()

@end

@implementation TutorialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad

{
    self.doneButton.hidden=YES;
     [self.navigationController.navigationBar setHidden:YES];
    self.label.text = @"the app where you are rewarded for embarassing your loved ones";
    [self.label setFont:[UIFont fontWithName:@"Raleway-Thin" size:15.0]];
    [self.titleLabel setFont:[UIFont fontWithName:@"Raleway-Medium" size:18]];
   // [self.imageView setUserInteractionEnabled:YES];
    [self.view setUserInteractionEnabled:YES];
    self.imageView.contentMode=UIViewContentModeScaleAspectFit;
    
    
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(postBountyButton:)];
    
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
   // [self.imageView addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)done:(id)sender {
    [self.tabBarController setSelectedIndex:0];
    [self.doneButton.titleLabel setFont:[UIFont fontWithName:@"Raleway-Medium" size:18]];
}
- (IBAction)firstPage:(id)sender {
    self.titleLabel.text=@"welcome to rascal";
    self.label.text = @"where you are rewarded for embarassing your loved ones";
    [self.label setFont:[UIFont fontWithName:@"Raleway-Thin" size:15.0]];
    [self.titleLabel setFont:[UIFont fontWithName:@"Raleway-Medium" size:18]];
    // [self.imageView setUserInteractionEnabled:YES];
    [self.view setUserInteractionEnabled:YES];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(postBountyButton:)];
    
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    // [self.imageView addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeLeft];
    self.pageController.currentPage=0;
    
    //!!! BLANK FOR NOW
    self.imageView.image=nil;
    
    
}
- (IBAction)postBountyButton:(id)sender {
    UIImage *tutorial1 = [UIImage imageNamed:@"tutorial1"];
    self.titleLabel.text=@"Posting Bounties";
    self.imageView.image = tutorial1;
    self.label.text=@"tell your friends to take a funny photo of someone! costs 5 credits but returns 1 when a friend responds.";
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(activeBountiesButton:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(firstPage:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
   // [self.imageView addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
    
    self.pageController.currentPage = 1;
    
    
    
   
}
- (IBAction)activeBountiesButton:(id)sender {
    self.titleLabel.text = @"Sharing Photos";
    UIImage *tutorial2 = [UIImage imageNamed:@"tutorial2"];
    self.imageView.image = tutorial2;
    self.label.text=@"click to take a funny photo of them and add to your porfolio. the more people you send to, the more credits you get!";
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(completedBountiesButton:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(postBountyButton:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    //[self.imageView addGestureRecognizer:swipeLeft];
   // [self.imageView addGestureRecognizer:swipeRight];
    
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
     self.pageController.currentPage = 2;
}
- (IBAction)completedBountiesButton:(id)sender {
    self.titleLabel.text = @"Seeing Photos";
    UIImage *tutorial3 = [UIImage imageNamed:@"tutorial3"];
    self.imageView.image = tutorial3;
    self.label.text=@"these are funny photos people want to share with you. click to have a good laugh. the best ones are in the highlights(haha!)";
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(activeBountiesButton:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
   // [self.imageView addGestureRecognizer:swipeRight];
   
    [self.view addGestureRecognizer:swipeRight];
     self.pageController.currentPage = 3;
    self.doneButton.hidden=NO;
}

@end
