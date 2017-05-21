//
//  SignInViewController.m
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 5. 14..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController (){
    NSUInteger studentlength;
    FIRDatabaseHandle _refHandle;
}

@end

@implementation SignInViewController

@synthesize students;
@synthesize ref;
@synthesize signInId;
@synthesize signInPasswd;

- (void)viewDidLoad {
    [super viewDidLoad];
    students = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
    
    [self configureDatabase];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[ref child:@"student"] removeObserverWithHandle:_refHandle];
}


- (void)configureDatabase {
    ref = [[FIRDatabase database] reference];
    // Listen for new messages in the Firebase database
    _refHandle = [[ref child:@"students"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [students addObject:snapshot];
        studentlength = students.count;

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

- (IBAction)loginButton:(UIButton *)sender {
    
   // [self performSegueWithIdentifier:@"toLoginSuccess" sender:self];
        if([[self.signInId text] isEqualToString:@""] ||
           [[self.signInPasswd text] isEqualToString:@""] ) {
        }
        else {
            for(int i = 0; i < studentlength; i++){
            FIRDataSnapshot *studentSnapshot = students[i];
            NSDictionary<NSString *, NSString *> *stud = studentSnapshot.value;
            NSLog(@"11111111111111%@", stud);
            NSString *loginId = [NSString stringWithFormat:@"%@", [stud valueForKey:@"stdId"]];
            NSString *loginPw = [NSString stringWithFormat:@"%@", [stud valueForKey:@"passwd"]];
            NSString *liId = [signInId text];
            NSString *liPw = [signInPasswd text];
            if([loginId isEqualToString:liId] && [loginPw isEqualToString:liPw]){
                
                    NSLog(@"pw%@", loginPw);
                    NSLog(@"id%@", liPw);
                NSLog(@"id%@", loginId);
                NSLog(@"id%@", liId);
            }
            }
        }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

@end
