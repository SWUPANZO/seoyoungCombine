//
//  CalendarTimeTableViewController.h
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 6. 11..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;

extern NSArray * createdAt;
extern NSArray * parseSpot3;
extern NSArray * hadSession;

@interface CalendarTimeTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSString *loginId;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *time;
@property (strong, nonatomic) IBOutlet UITableView *timeTable;


@end

