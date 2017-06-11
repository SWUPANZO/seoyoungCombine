//
//  audioRecordViewController.m
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 4. 12..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import "audioRecordViewController.h"

@interface audioRecordViewController (){
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    FIRDatabaseHandle _lectureRefHandle;
    FIRDatabaseHandle _weekRefHandle;
    NSUInteger _lectureLength;
    NSUInteger _weekLength;
}

@end

@implementation audioRecordViewController

@synthesize recordPauseButton;
@synthesize playButton;
@synthesize stopButton;
@synthesize ref;
@synthesize storageRef;
@synthesize lecture;
@synthesize week;


- (void)viewDidLoad {
    [super viewDidLoad];
    week = [[NSMutableArray alloc] init];
    lecture = [[NSMutableArray alloc] init];
    
    // Disable Stop/Play button when application launches
    [stopButton setEnabled:NO];
    [playButton setEnabled:NO];
    
    [self configureDatabase];
    [self configureStorage];
    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
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

- (IBAction)recordAudio:(id)sender {
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        [recordPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        
    } else {
        
        // Pause recording
        [recorder pause];
        [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    }
    
    [stopButton setEnabled:YES];
    [playButton setEnabled:NO];
}

- (IBAction)playAudio:(id)sender {
    if (!recorder.recording){
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
    }
}

- (IBAction)stopAudio:(id)sender {
    [recorder stop];
    
    NSData *audioData = [NSData dataWithContentsOfURL:recorder.url];
    NSLog(@"audio Data : %@", recorder.url);
    NSString *audioPath = [NSString stringWithFormat:@"%@/audios/%lld.mp3", @"2013111564", (long long)([NSDate date].timeIntervalSince1970 * 1000.0)];
    FIRStorageMetadata *metadata = [FIRStorageMetadata new];
    metadata.contentType = @"audio/mpeg";
    NSLog(@"storage ref");
    [[storageRef child:audioPath] putData:audioData metadata:metadata
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
                                       NSLog(@"week save");
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
                                                                                   [[[[[[ref child:@"Week"] child: @"2013111564"] child: weekSnapshot.key] child: nameSnapshot.value] child: @"audio"] updateChildValues:imgDiction];
                                                                                   
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
    
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    
    [stopButton setEnabled:NO];
    [playButton setEnabled:YES];
}


@end
