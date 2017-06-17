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
#import <AssetsLibrary/AssetsLibrary.h>

@import Firebase;

@interface combineViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UIImagePickerController *picker;
    UIImage *image;
}

@property (strong, nonatomic) NSString *loginId;
@property (strong, nonatomic) NSString *lectureTitle;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *lecture;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *imageArr;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *weekCell;

@property (strong, nonatomic) IBOutlet UIView *functionView;
@property (strong, nonatomic) IBOutlet UIButton *recordStop;


- (IBAction)showView:(id)sender;
- (IBAction)exitView:(id)sender;
- (IBAction)pushCamera:(id)sender;
- (IBAction)pushVideo:(id)sender;
- (IBAction)pushMemo:(id)sender;
- (IBAction)pushRecord:(id)sender;

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

- (IBAction)button:(id)sender;

@end
