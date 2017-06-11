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

@import Firebase;
@interface recordVideoViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *lecture;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *week;

-(IBAction)recordAndPlay:(id)sender;
-(BOOL)startCameraControllerFromViewController:(UIViewController*)controller
                                 usingDelegate:(id )delegate;
-(void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void*)contextInfo;

@end
