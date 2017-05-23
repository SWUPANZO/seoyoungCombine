//
//  combineViewController.h
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 5. 16..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
@import Firebase;

@interface combineViewController : UIViewController<UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIActionSheetDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    UIImagePickerController *picker;
    UIImage *image;
}

@property (strong, nonatomic) IBOutlet UIView *functionView;


- (IBAction)showView:(id)sender;
- (IBAction)exitView:(id)sender;
- (IBAction)pushCamera:(id)sender;
- (IBAction)pushVideo:(id)sender;
- (IBAction)pushMemo:(id)sender;

//video
-(BOOL)startCameraControllerFromViewController:(UIViewController*)controller
                                 usingDelegate:(id )delegate;
-(void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void*)contextInfo;

//주차별 리스트
@property (strong, nonatomic) IBOutlet UITableView *weekTable;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *week;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (nonatomic, strong) FIRRemoteConfig *remoteConfig;

@end
