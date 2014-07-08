//
//  CameraViewController.m
//  Rascal
//
//  Created by Phillip Ou on 6/30/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <Parse/Parse.h>

@interface CameraViewController ()
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *chosenImageView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@end

@implementation CameraViewController

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
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    
    //crop image into a square like instagram
    
    self.imagePicker.allowsEditing=YES;
    //if device has camera show camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
    }
    //if not show library of photos
    else{
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    //pictures only
    self.imagePicker.mediaTypes = [NSArray arrayWithObjects: (NSString *) kUTTypeImage, nil];
    
    [self presentViewController:self.imagePicker animated:NO completion:nil];
}
- (IBAction)share:(id)sender {
    if (self.chosenImageView.image){
        NSData *imageData = UIImagePNGRepresentation(self.chosenImageView.image);
        PFFile *photoFile = [PFFile fileWithData:imageData];
        PFObject *photo = [PFObject objectWithClassName:@"Photo"];
        photo[@"image"] = photoFile;    //create a data type where key "image" stores value photoFile;
        photo[@"whoTook"]= [PFUser currentUser];
        photo[@"title"] = self.titleTextField.text;
        
        //groups!!!
        
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
                
                photo[@"Location"]=geoPoint;
                
                [photo saveInBackground];
            }
            else{
                NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
                
                photo[@"Location"]=geoPoint;
                
                [photo saveInBackground];
                
            }
        }];
        //TESTING ONLY!
         /*PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:80.0 longitude:80.0];
         photo[@"Location"] = point;
        NSLog(@"photo at: %f, %f", point.latitude, point.longitude);
         [photo saveInBackground];*/


        
        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *erorr){
            if(!succeeded){
                [self showError];
            }
        }];
    }
    else{ [self showError];}
    [self clear];
    [self.tabBarController setSelectedIndex:0];
}

-(void) showError{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not post your photo, please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
//person finished taking picture
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.chosenImageView.image = chosenImage;
    [self dismissViewControllerAnimated:YES completion: nil];
    
}
///person decides to cancel picture
-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //go back to home screen and clear camera of data
    [self.tabBarController setSelectedIndex:0];
    [self clear];
    
}
-(void) clear{
    self.chosenImageView.image=nil;
    self.titleTextField.text= nil;
}

//every timescreen is touched in CameraViewController, this is activated

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.titleTextField resignFirstResponder]; //resign first responder take away keyboard once photo chosen
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

@end
