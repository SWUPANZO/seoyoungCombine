//
//  SignInViewController.h
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 5. 14..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;

@interface SignInViewController : UIViewController

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *students;
@property (strong, nonatomic) IBOutlet UITextField *signInId;
@property (strong, nonatomic) IBOutlet UITextField *signInPasswd;

- (IBAction)loginButton:(UIButton *)sender;

@end
