//
//  combineViewController.m
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 5. 16..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import "combineViewController.h"
#import "CollectionViewController.h"

@interface combineViewController ()<UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
FIRInviteDelegate> {
    FIRDatabaseHandle _refHandle;
    FIRDatabaseHandle _lectureRefHandle;
    FIRDatabaseHandle _imgRefHandle;
    NSUInteger _weekLength;
    NSUInteger _lectureLength;
    NSUInteger _imageLength;
    int lectureBool;

    FIRDatabaseHandle _weekRefHandle;


//    int _msglength;
}

@end

@implementation combineViewController

//@synthesize imageView;
//@synthesize newMedia;
@synthesize remoteConfig;
@synthesize loginId;
@synthesize lecture;
@synthesize imageArr;


@synthesize functionView;
@synthesize weekTable;
@synthesize week;
@synthesize weekCell;
@synthesize ref;
@synthesize storageRef;
//@class remoteConfig;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.functionView setHidden:YES];
    
    week = [[NSMutableArray alloc] init];
    weekCell = [[NSMutableArray alloc] init];
    lecture = [[NSMutableArray alloc] init];
    imageArr = [[NSMutableArray alloc] init];


    
    [self configureDatabase];
    [self configureStorage];
    [self configureRemoteConfig];

    [weekTable registerClass:UITableViewCell.self forCellReuseIdentifier:@"weekTableViewCell"];

    // Do any additional setup after loading the view.
}

- (void)dealloc {
    [[ref child:@"AcademicCalendar"] removeObserverWithHandle:_refHandle];
}

- (void)configureDatabase {
    ref = [[FIRDatabase database] reference];
    // Listen for new messages in the Firebase database

    _weekRefHandle = [[ref child:@"AcademicCalendar"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [week addObject:snapshot];
        
        _weekLength = week.count;
    }];
    

    
    _imgRefHandle = [[[[[[ref child:@"Week"] child:@"2013111564"] child:@"week14"] child:@"팀플"] child: @"album"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [imageArr addObject:snapshot];
        
        _imageLength = imageArr.count;
    }];
    
    _lectureRefHandle = [[[[ref child:@"Students"] child:loginId] child:@"lecture"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        NSLog(@"lecture : %@",snapshot);
        [lecture addObject:snapshot];
        
        _lectureLength = lecture.count;
    }];
    /*
    _refHandle = [[ref child:@"AcademicCalendar"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [week addObject:snapshot];
        NSLog(@"haha");
        [weekTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:week.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationAutomatic];
    }];
    */
    
    //주차별 테이블
    NSLog(@"주차 출력");
    _refHandle = [[ref child:@"AcademicCalendar"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        if([snapshot.key isEqualToString: @"week0"]){
            NSLog(@"snapshot");
        }
        else{
            [weekCell addObject:snapshot];
            NSLog(@"week table : %@", snapshot);
            
            [weekTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weekCell.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationAutomatic];
        }

        NSLog(@"snapshot : %lu", (unsigned long)weekCell.count);
    }];
    
}

- (void)configureRemoteConfig {
    NSLog(@"configureRemoteConfig");
    remoteConfig = [FIRRemoteConfig remoteConfig];
    
    FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] initWithDeveloperModeEnabled:YES];
    self.remoteConfig.configSettings = remoteConfigSettings;
}

- (void)configureStorage {
    NSLog(@"configureStorge");
    self.storageRef = [[FIRStorage storage] reference];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//주차별 리스트
- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return weekCell.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // Dequeue cell
    UITableViewCell *cell = [weekTable dequeueReusableCellWithIdentifier:@"weekTableViewCell" forIndexPath:indexPath];
    
    // Unpack message from Firebase DataSnapshot
    FIRDataSnapshot *weekSnapshot = weekCell[indexPath.row];
    NSString *title = weekSnapshot.key;
    NSLog(@"%@", title);
    NSString *subString = [title substringFromIndex:4];
    cell.textLabel.text = [NSString stringWithFormat:@"%@주차", subString];
  //  [weekTable reloadData];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self performSegueWithIdentifier:@"toCollectionView" sender:self];
}


- (IBAction)showView:(id)sender {
    [self.functionView setHidden:NO];
}


- (IBAction)exitView:(id)sender {
    [self.functionView setHidden:YES];
}


- (IBAction)pushCamera:(id)sender {
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)pushVideo:(id)sender {
    [self startCameraControllerFromViewController:self usingDelegate:self];
}

-(BOOL)startCameraControllerFromViewController:(UIViewController*)controller
                                 usingDelegate:(id )delegate {
    // 1 - Validattions
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil)) {
        return NO;
    }
    // 2 - Get image picker
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    // Displays a control that allows the user to choose movie capture
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = delegate;
    // 3 - Display image picker
    [self presentViewController: cameraUI animated:YES completion:nil];
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //Camera
 //   image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
   // [imageView setImage:image];
    
    NSData *imgData = UIImageJPEGRepresentation(image, 0.8);
    NSString *imagePath = [NSString stringWithFormat:@"%@/images/%lld.jpg", loginId, (long long)([NSDate date].timeIntervalSince1970 * 1000.0)];
    FIRStorageMetadata *CameraMetadata = [FIRStorageMetadata new];
    CameraMetadata.contentType = @"image/jpeg";
    [[storageRef child:imagePath] putData:imgData metadata:CameraMetadata                               completion:^(FIRStorageMetadata * _Nullable CameraMetadata, NSError * _Nullable error) {
                                   if (error) {
                                       NSLog(@"Error uploading: %@", error);
                                       return;
                                   }
                                   NSDate *currentDate = [NSDate date];
                                   NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                   [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
                                   NSTimeZone *krTimeZone =[NSTimeZone timeZoneWithName:@"Asia/Seoul"];
                                   [dateFormatter setTimeZone:krTimeZone];
                                   NSString *krDate = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:currentDate]];
                                   
                                   NSMutableDictionary *imgDiction = [[NSMutableDictionary alloc] init];
                                   NSString *capturedDate = [NSString stringWithFormat:@"%@", krDate];
                                   
                                   [imgDiction setObject:[storageRef child:CameraMetadata.path].description forKey:capturedDate];
                                   
                                   
                                   
                                   NSCalendar *calendar = [NSCalendar currentCalendar];
                                   NSDateComponents *comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday
                                                                        fromDate:currentDate];
                                   NSInteger weekday = [comp weekday];
                                   
                                   NSString *subDateString = [krDate substringWithRange:NSMakeRange(0, 8)];
                                   NSString *subTimeString = [krDate substringWithRange:NSMakeRange(8, 4)];
                                   
                                   for(int i = 0; i < _lectureLength; i++){
                                       FIRDataSnapshot *lectureSnapshot = lecture[i];
                                       
                                       FIRDatabaseReference *snapshotRef = lectureSnapshot.ref;
                                       [[snapshotRef child:@"time"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                                           FIRDatabaseReference *tempSnapshot = snapshot.ref;
                                           [[tempSnapshot child:@"week"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot2) {
                                               if([snapshot2.value integerValue] == weekday){
                                                   [[tempSnapshot child:@"start"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot3){
                                                       if([subTimeString integerValue] > [snapshot3.value integerValue]){
                                                           [[tempSnapshot child:@"end"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot4){
                                                               if([subTimeString integerValue] < [snapshot4.value integerValue]){
                                                                   [[tempSnapshot.parent child:@"name"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull nameSnapshot) {
                                                                       
                                                                       FIRDataSnapshot *beforeWeekSnapshot = nil;
                                                                       NSString *beforeWeekDate;
                                                                       for(int i = 0; i < _weekLength; i++){
                                                                           FIRDataSnapshot *weekSnapshot = week[i];
                                                                           NSString *weekDate = weekSnapshot.value;
                                                                           
                                                                           if(beforeWeekSnapshot != nil){
                                                                               if([subDateString integerValue] > [beforeWeekDate integerValue] && [subDateString integerValue] < [weekDate integerValue]){
                                                                                   //                                                                                   [[[[[[[ref child:@"Week"] child: loginId] child: nameSnapshot.value] child: weekSnapshot.key] child: @"album"] childByAutoId] setValue:imgDiction];
                                                                                   [[[[[[ref child:@"Week"] child: loginId] child: weekSnapshot.key] child: nameSnapshot.value] child: @"album"] updateChildValues:imgDiction];
                                                                                   
                                                                                   NSLog(@"week save : %@", weekSnapshot.key);
                                                                                   i = 100;
                                                                               }
                                                                           }
                                                                           beforeWeekSnapshot = weekSnapshot;
                                                                           beforeWeekDate = beforeWeekSnapshot.value;
                                                                       }
                                                                       
                                                                   }];
                                                               }
                                                               
                                                           }];
                                                       }
                                                   }];
                                                   
                                               }
                                           }];
                                           
                                       }];
                                       if((i == _lectureLength-1)&&(i != 100)){
                                           
                                           [[[[[ref child:@"Week"] child: loginId] child: @"etc"] child: @"album"] updateChildValues:imgDiction];
                                           
                                       }
                                   }
                                   
                               }];
    
    //Video
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:NO completion:nil];
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    NSString *vedioPath = [NSString stringWithFormat:@"%@/video/%lld.mp3", @"2013111564", (long long)([NSDate date].timeIntervalSince1970 * 1000.0)];
    FIRStorageMetadata *VideoMetadata = [FIRStorageMetadata new];
    VideoMetadata.contentType = @"video/mp4";
    NSLog(@"storage ref");
    [[storageRef child:vedioPath] putData:videoData metadata:VideoMetadata
                               completion:^(FIRStorageMetadata * _Nullable VideoMetadata, NSError * _Nullable error) {
                                   if (error) {
                                       NSLog(@"Error uploading: %@", error);
                                       return;
                                   }
                                   NSDate *currentDate = [NSDate date];
                                   NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                   [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
                                   NSTimeZone *krTimeZone =[NSTimeZone timeZoneWithName:@"Asia/Seoul"];
                                   [dateFormatter setTimeZone:krTimeZone];
                                   NSString *krDate = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:currentDate]];
                                   
                                   NSMutableDictionary *imgDiction = [[NSMutableDictionary alloc] init];
                                   NSString *capturedDate = [NSString stringWithFormat:@"%@", krDate];
                                   
                                   [imgDiction setObject:[storageRef child:VideoMetadata.path].description forKey:capturedDate];
                                   
                                   
                                   
                                   NSCalendar *calendar = [NSCalendar currentCalendar];
                                   NSDateComponents *comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday
                                                                        fromDate:currentDate];
                                   NSInteger weekday = [comp weekday];
                                   
                                   NSString *subDateString = [krDate substringWithRange:NSMakeRange(0, 8)];
                                   NSString *subTimeString = [krDate substringWithRange:NSMakeRange(8, 4)];
                                   
                                   for(int i = 0; i < _lectureLength; i++){
                                       FIRDataSnapshot *lectureSnapshot = lecture[i];
                                       
                                       FIRDatabaseReference *snapshotRef = lectureSnapshot.ref;
                                       [[snapshotRef child:@"time"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                                           FIRDatabaseReference *tempSnapshot = snapshot.ref;
                                           [[tempSnapshot child:@"week"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot2) {
                                               if([snapshot2.value integerValue] == weekday){
                                                   [[tempSnapshot child:@"start"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot3){
                                                       if([subTimeString integerValue] > [snapshot3.value integerValue]){
                                                           [[tempSnapshot child:@"end"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot4){
                                                               if([subTimeString integerValue] < [snapshot4.value integerValue]){
                                                                   [[tempSnapshot.parent child:@"name"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull nameSnapshot) {
                                                                       
                                                                       FIRDataSnapshot *beforeWeekSnapshot = nil;
                                                                       NSString *beforeWeekDate;
                                                                       for(int i = 0; i < _weekLength; i++){
                                                                           FIRDataSnapshot *weekSnapshot = week[i];
                                                                           NSString *weekDate = weekSnapshot.value;
                                                                           
                                                                           if(beforeWeekSnapshot != nil){
                                                                               if([subDateString integerValue] > [beforeWeekDate integerValue] && [subDateString integerValue] < [weekDate integerValue]){
                                                                                   //                                                                                   [[[[[[[ref child:@"Week"] child: loginId] child: nameSnapshot.value] child: weekSnapshot.key] child: @"album"] childByAutoId] setValue:imgDiction];
                                                                                   [[[[[[ref child:@"Week"] child: @"2013111564"] child: weekSnapshot.key] child: nameSnapshot.value] child: @"video"] updateChildValues:imgDiction];
                                                                                   
                                                                                   NSLog(@"week save : %@", weekSnapshot.key);
                                                                                   i = 100;
                                                                               }
                                                                           }
                                                                           beforeWeekSnapshot = weekSnapshot;
                                                                           beforeWeekDate = beforeWeekSnapshot.value;
                                                                       }
                                                                       
                                                                   }];
                                                               }
                                                               
                                                           }];
                                                       }
                                                   }];
                                                   
                                               }
                                           }];
                                           
                                       }];
                                       if((i == _lectureLength-1)&&(i != 100)){
                                           
                                           [[[[[ref child:@"Week"] child:@"2013111564"] child:@"etc"] child:@"audio"] updateChildValues:imgDiction];
                                           
                                       }
                                   }
                                   
                               }];

    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Title"
                                 message:@"Message"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* errorButton = [UIAlertAction
                                  actionWithTitle:@"Video Saving Failed"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      //Handle your yes please button action here
                                  }];
    
    UIAlertAction* saveButton = [UIAlertAction
                                 actionWithTitle:@"Saved To Photo Album"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     //Handle your yes please button action here
                                 }];
    
    if (error){
        
        [alert addAction:errorButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        
        [alert addAction:saveButton];
        
        [self presentViewController:alert animated:YES completion:nil];    }

}


- (IBAction)pushMemo:(id)sender {
}






 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([[segue identifier] isEqualToString:@"toCollectionView"])
     {
         CollectionViewController *deptVC = [segue destinationViewController];
         
        // deptVC.title = ;
         deptVC.loginId = loginId;
     }

 }
 


@end
