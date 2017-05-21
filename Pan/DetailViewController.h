//
//  DetailViewController.h
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 5. 16..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface DetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *textMemo;
@property (strong, nonatomic) IBOutlet UITextField *saveDate;

@property (strong, nonatomic) NSManagedObject *detailMemo;

@end
