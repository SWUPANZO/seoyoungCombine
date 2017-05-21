//
//  weekViewController.m
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 5. 18..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import "weekViewController.h"

@interface weekViewController ()<UITableViewDataSource, UITableViewDelegate,
UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
FIRInviteDelegate> {
    int _msglength;
    FIRDatabaseHandle _refHandle;
}


@end

@implementation weekViewController

@synthesize weekTable;
@synthesize week;
@synthesize ref;
@synthesize storageRef;
@class remoteConfig;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    week = [[NSMutableArray alloc] init];
    [weekTable registerClass:UITableViewCell.self forCellReuseIdentifier:@"tableViewCell"];
    
    [self configureDatabase];
}

- (void)dealloc {
    [[ref child:@"Students/2013111564/week"] removeObserverWithHandle:_refHandle];
}


- (void)configureDatabase {
    ref = [[FIRDatabase database] reference];
    // Listen for new messages in the Firebase database
    _refHandle = [[ref child:@"Students/2013111564/week"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [week addObject:snapshot];
        [weekTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:week.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationAutomatic];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return week.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // Dequeue cell
    UITableViewCell *cell = [weekTable dequeueReusableCellWithIdentifier:@"tableViewCell" forIndexPath:indexPath];
    
    // Unpack message from Firebase DataSnapshot
    FIRDataSnapshot *weekSnapshot = week[indexPath.row];
    NSString *title = weekSnapshot.key;
    NSLog(@"%@", title);
    cell.textLabel.text = [NSString stringWithFormat:@"%@", title];
    return cell;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
