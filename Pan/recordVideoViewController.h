//
//  recordVideoViewController.h
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 4. 25..
//  Copyright © 2017년 Pan. All rights reserved.
//
//  https://www.raywenderlich.com/13418/how-to-play-record-edit-videos-in-ios

#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface recordVideoViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

-(IBAction)recordAndPlay:(id)sender;
-(BOOL)startCameraControllerFromViewController:(UIViewController*)controller
                                 usingDelegate:(id )delegate;
-(void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void*)contextInfo;

@end
