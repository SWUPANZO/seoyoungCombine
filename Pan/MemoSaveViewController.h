//
//  MemoSaveViewController.h
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 6. 13..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;

@interface MemoSaveViewController : UIViewController

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *week;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *lecture;
@property (strong, nonatomic) NSString *loginId;



@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIButton *button;

- (IBAction)PressButton:(id)sender;


@end
