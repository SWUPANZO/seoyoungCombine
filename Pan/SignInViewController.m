//
//  SignInViewController.m
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 5. 14..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import "SignInViewController.h"
#import "CalendarTimeTableViewController.h"

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



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"toLoginSuccess"])
    {
        CalendarTimeTableViewController *deptVC = [segue destinationViewController];

        deptVC.loginId = signInId.text;
    }

}


- (IBAction)loginButton:(UIButton *)sender {
    
    if([[self.signInId text] isEqualToString:@""] ||
       [[self.signInPasswd text] isEqualToString:@""] ) {
    }
    else {
        [[[ref child:@"Students"] child:[signInId text]] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot.value == [NSNull null]) {
                // The value is null
            }
            else{
                NSMutableDictionary *dict = snapshot.value;
                NSString *textPassword = [signInPasswd text];
                NSString *password = [dict valueForKey:@"passwd"];
                if(textPassword == password){
                    [self performSegueWithIdentifier:@"toLoginSuccess" sender:self];
                }
            }
        } withCancelBlock:^(NSError * _Nonnull error) {
            NSLog(@"%@", error.localizedDescription);
        }];
        
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

@end
