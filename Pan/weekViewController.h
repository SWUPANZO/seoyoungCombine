//
//  weekViewController.h
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 5. 18..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;

@interface weekViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *weekTable;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *week;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (nonatomic, strong) FIRRemoteConfig *remoteConfig;

@end
