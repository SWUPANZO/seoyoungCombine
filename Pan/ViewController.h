//
//  ViewController.h
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 4. 4..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

//fkfkfkfkfkfkfkdskkkssk
//ajdoaisjdoisajdosajdjas

@interface ViewController : UIViewController <UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIActionSheetDelegate>
{
    UIImagePickerController *picker;
    UIImage *image;
}
@property BOOL newMedia;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)useCamera:(id)sender;
- (IBAction)useCameraRoll:(id)sender;

@end

