//
//  recordVideoViewController.m
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 4. 25..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import "recordVideoViewController.h"

@interface recordVideoViewController (){
    FIRDatabaseHandle _lectureRefHandle;
    FIRDatabaseHandle _weekRefHandle;
    NSUInteger _lectureLength;
    NSUInteger _weekLength;
}

@end

@implementation recordVideoViewController

@synthesize ref;
@synthesize storageRef;
@synthesize week;
@synthesize lecture;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    week = [[NSMutableArray alloc] init];
    lecture = [[NSMutableArray alloc] init];
    
    [self configureDatabase];
    [self configureStorage];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureDatabase {
    ref = [[FIRDatabase database] reference];
    
    _lectureRefHandle = [[[[ref child:@"Students"] child:@"2013111564"] child:@"lecture"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [lecture addObject:snapshot];
        
        _lectureLength = lecture.count;
    }];
    
    _weekRefHandle = [[ref child:@"AcademicCalendar"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [week addObject:snapshot];
        
        _weekLength = week.count;
    }];
}

- (void)configureStorage {
    self.storageRef = [[FIRStorage storage] reference];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)recordAndPlay:(id)sender {
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:NO completion:nil];
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    NSString *vedioPath = [NSString stringWithFormat:@"%@/video/%lld.mp3", @"2013111564", (long long)([NSDate date].timeIntervalSince1970 * 1000.0)];
    FIRStorageMetadata *metadata = [FIRStorageMetadata new];
    metadata.contentType = @"video/mp4";
    NSLog(@"storage ref");
    [[storageRef child:vedioPath] putData:videoData metadata:metadata
                               completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
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
                                   
                                   [imgDiction setObject:[storageRef child:metadata.path].description forKey:capturedDate];
                                   
                                   
                                   
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
                                           
                                           [[[[[ref child:@"Week"] child: @"2013111564"] child: @"etc"] child: @"audio"] updateChildValues:imgDiction];
                                           
                                       }
                                   }
                                   
                               }];
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


@end
