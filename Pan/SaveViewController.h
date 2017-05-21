//
//  SaveViewController.h
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 5. 16..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;

@interface SaveViewController : UIViewController <UITextFieldDelegate>{
    NSArray *array;
}

@property (strong, nonatomic) IBOutlet UITextView *textMemo;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRAuth *handle;

- (IBAction)savePressed:(UIBarButtonItem *)sender;
- (BOOL) textFieldShouldReturn:(UITextField *)textField;

@end
