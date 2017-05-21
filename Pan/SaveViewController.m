//
//  SaveViewController.m
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 5. 16..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import "SaveViewController.h"

#import <CoreData/CoreData.h>


@interface SaveViewController ()

@end

@implementation SaveViewController
@synthesize textMemo;
@synthesize ref;
@synthesize handle;



- (BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES; }


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ref = [[FIRDatabase database] reference];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */





- (IBAction)savePressed:(UIBarButtonItem *)sender {
    NSManagedObjectContext *context =nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext]; }
    
    NSManagedObject *newMemo = [NSEntityDescription
                                insertNewObjectForEntityForName:@"Memos"
                                inManagedObjectContext:context];
    
    [newMemo setValue:textMemo.text forKey:@"memo"];
    [newMemo setValue:[NSDate date] forKey:@"saveDate"];
    // save() method를 호출하여 자료를 저장함
    NSError *error = nil;
    // Save the context
    if (![context save:&error]) {
        NSLog(@"Save Failed! %@ %@", error, [error localizedDescription]); }
    // 이전 화면으로 복귀
    [self.navigationController popViewControllerAnimated:YES];
    
    // NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"yyyymmdd"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSDate *date = [NSDate date];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    NSString *textvalue = [NSString stringWithFormat:@"%@",textMemo.text];
    NSMutableDictionary *diction = [[NSMutableDictionary alloc]init];
    [diction setValue:textvalue forKey:formattedDateString];
    
    NSLog(@"diction : %@", diction);
    [[[ref child:@"student/01" ]child : formattedDateString] setValue:diction];
    
    
}//화면이 싹 사라지면서 테이블뷰가 보여야함















@end

