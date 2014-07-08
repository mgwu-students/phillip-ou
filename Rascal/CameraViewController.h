//
//  CameraViewController.h
//  Rascal
//
//  Created by Phillip Ou on 6/30/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate,MKAnnotation>
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title andSubtitle:(NSString *)subtitle;
- (void)setTitleAndSubtitleOutsideDistance:(BOOL)outside;
- (id)initWithPFObject:(PFObject *)object;
@end
