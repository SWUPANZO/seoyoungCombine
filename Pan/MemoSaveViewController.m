//
//  MemoSaveViewController.m
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 6. 13..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import "MemoSaveViewController.h"

@interface MemoSaveViewController (){
    FIRDatabaseHandle _refHandle;
    FIRDatabaseHandle _lectureRefHandle;
    FIRDatabaseHandle _weekRefHandle;
    NSUInteger _weekLength;
    NSUInteger _lectureLength;
}

@end

@implementation MemoSaveViewController

@synthesize ref;
@synthesize textView,button;
@synthesize week,lecture;
@synthesize loginId;

- (void)viewDidLoad {
    [super viewDidLoad];
    week = [[NSMutableArray alloc] init];
    lecture = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
    [self configureDatabase];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureDatabase {
    ref = [[FIRDatabase database] reference];
    
    _weekRefHandle = [[ref child:@"AcademicCalendar"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [week addObject:snapshot];
        
        _weekLength = week.count;
    }];
    
    _lectureRefHandle = [[[[ref child:@"Students"] child:loginId] child:@"lecture"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        NSLog(@"lecture : %@",snapshot);
        [lecture addObject:snapshot];
        
        _lectureLength = lecture.count;
    }];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)PressButton:(id)sender {
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSTimeZone *krTimeZone =[NSTimeZone timeZoneWithName:@"Asia/Seoul"];
    [dateFormatter setTimeZone:krTimeZone];
    NSString *krDate = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:currentDate]];
    
    NSMutableDictionary *imgDiction = [[NSMutableDictionary alloc] init];
    NSString *capturedDate = [NSString stringWithFormat:@"%@", krDate];
    
    [imgDiction setObject:textView.text forKey:capturedDate];
    
    
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
                                                    [[[[[[ref child:@"Week"] child: loginId] child: weekSnapshot.key] child: nameSnapshot.value] child: @"memo"] updateChildValues:imgDiction];
                                                    
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
            
            FIRDataSnapshot *beforeWeekSnapshot = nil;
            NSString *beforeWeekDate;
            for(int j = 0; j < _weekLength; j++){
                FIRDataSnapshot *weekSnapshot = week[j];
                NSString *weekDate = weekSnapshot.value;
                
                if(beforeWeekSnapshot != nil){
                    if([subDateString integerValue] > [beforeWeekDate integerValue] && [subDateString integerValue] < [weekDate integerValue]){
                        [[[[[[ref child:@"Week"] child: loginId] child: weekSnapshot.key] child: @"etc"] child: @"memo"] updateChildValues:imgDiction];
                        
                        j = 100;
                        NSLog(@"week save : %@", weekSnapshot.key);
                    }
                }
                beforeWeekSnapshot = weekSnapshot;
                beforeWeekDate = beforeWeekSnapshot.value;
            }
            
        }
        
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
        
    }


}
@end
