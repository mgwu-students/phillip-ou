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
#import "PostCameraViewController.h"
@interface CameraViewController ()
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (weak, nonatomic) IBOutlet UIImageView *chosenImageView;
@property (nonatomic) NSMutableArray *capturedImages;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) PFUser *user;
@end


@implementation CameraViewController

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)viewDidLoad
{
    PFUser *currentUser = [PFUser currentUser];
    self.view.frame = [[UIScreen mainScreen] bounds];
    [super viewDidLoad];
     self.capturedImages = [[NSMutableArray alloc] init];
    
    self.senderId = [self.message objectForKey:@"senderId"];
    self.targetId = [self.message objectForKey:@"victimId"];
    [self.message setObject:@"Yes" forKey: @"read"];
    if(![self.message[@"readUsers"] containsObject: currentUser.objectId]){
        NSMutableArray *readUsersArray = [NSMutableArray arrayWithArray:self.message[@"readUsers"]];
        [readUsersArray addObject:currentUser.objectId];
        [self.message  setObject:[NSArray arrayWithArray:readUsersArray]forKey:@"readUsers"];
    
        }
    [self.message saveEventually];
    
    NSLog(@"%@ , %@", self.senderId, self.targetId);
   
    self.tabBarController.tabBar.hidden = YES;
   /* if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // There is not a camera on this device, so don't show the camera button.
        NSMutableArray *toolbarItems = [self.toolBar.items mutableCopy];
        [toolbarItems removeObjectAtIndex:2];
        [self.toolBar setItems:toolbarItems animated:NO];
        //UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        
        //[self.chosenImageView setImage:[self.capturedImages objectAtIndex:0]];
    }
    */
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)finishAndUpdate
{
    //[self dismissViewControllerAnimated:YES completion:NULL];
    

        if ([self.capturedImages count] == 1)
        {
            // Camera took a single picture.
            [self.chosenImageView setImage:[self.capturedImages objectAtIndex:0]];
        }
    
        [self.capturedImages removeAllObjects];
    
    
    //self.imagePicker = nil;
}
- (IBAction)showImagePickerForPhotoPicker:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
}


- (IBAction)showImagePickerForCamera:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}


- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (self.chosenImageView.isAnimating)
    {
        [self.chosenImageView stopAnimating];
    }
    if (self.capturedImages.count > 0)
    {
        [self.capturedImages removeAllObjects];
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        /*
         The user wants to use the camera interface. Set up our custom overlay view for the camera.
         */
        imagePickerController.showsCameraControls =YES;
        
        /*
         Load the overlay view from the OverlayView nib file. Self is the File's Owner for the nib file, so the overlayView outlet is set to the main view in the nib. Pass that view to the image picker controller to use as its overlay view, and set self's reference to the view to nil.
         */
         /*[[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil];
         self.overlayView.frame = imagePickerController.cameraOverlayView.frame;
         imagePickerController.cameraOverlayView = self.overlayView;
         self.overlayView = nil;*/
    }
    
    self.imagePicker = imagePickerController;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = NO;
    /*
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;

    }
    else {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    self.imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
    [self presentViewController:self.imagePicker animated:NO completion:nil];*/
}
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self clear];
}
*/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    //UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.chosenImageView.image = chosenImage;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.capturedImages addObject: chosenImage];
    
    
    [self finishAndUpdate];


}/*
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    [self.capturedImages addObject:image];
    

    
    [self finishAndUpdate];
}
*/

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:NO completion:nil];
    self.tabBarController.hidesBottomBarWhenPushed=NO;
    //[self.tabBarController setSelectedIndex:0];
}

- (void)clear {
    self.chosenImageView.image = nil;
    self.titleTextField.text = nil;
    
}

- (IBAction)share:(id)sender {
    NSLog(@"Next");
    //self.testObject = @"boo";
   
    if (self.chosenImageView.image) {
        [self performSegueWithIdentifier: @"transition" sender: self];
        NSLog(@"segueperformed");
        
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please Take a Photo" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    NSLog(@"%@",[self.titleTextField text]);
    
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    
    if ([[segue identifier] isEqualToString:@"transition"]) {
        PostCameraViewController *b = segue.destinationViewController;
        
        NSData *imageData = UIImageJPEGRepresentation(self.chosenImageView.image, 0.05f); //reduce image file size
        
        PFFile *file = [PFFile fileWithName:@"image.png" data:imageData];
        // PFUser *currentUser = [PFUser currentUser];
        //self.message = [PFObject objectWithClassName:@"Messages"];
        b.imageData = imageData;
        b.whoTook = [PFUser currentUser];
        b.file = file;
        b.caption = [self.titleTextField text];
        b.chosenImageView = self.chosenImageView;
        b.targetId = self.targetId;
        b.senderId = self.senderId;
        b.selectedMessage = self.message;
        
        
        
        
        /*
         [b.message setObject: [PFUser currentUser] forKey:@"whoTook"];
         [b.message setObject:file forKey:@"file"];
         
         
         [b.message setObject:@"image" forKey:@"fileType"];
         
         [b.message setObject: [self.titleTextField text] forKey:@"caption"];*/
    }
}

- (void)reset {
        self.chosenImageView = nil;
    self.capturedImages = nil;
    self.titleTextField = nil;
    self.message = nil;
    self.imagePicker = nil;
    
    
}
- (IBAction)back:(id)sender {
    [self reset];
    //[self.tabBarController setSelectedIndex:0];
    
}

- (void)showError {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not post your photo, please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.titleTextField resignFirstResponder];
}









@end

