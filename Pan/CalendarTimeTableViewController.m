//
//  CalendarTimeTableViewController.m
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 6. 11..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import "Constants.h"
#import "CalendarTimeTableViewController.h"
#import "combineViewController.h"


@interface CalendarTimeTableViewController (){
    FIRDatabaseHandle _refHandle;
    NSString *sendTitle;
}

@end

@implementation CalendarTimeTableViewController{
    NSArray *array;
}
@synthesize ref;
@synthesize time,timeTable;
@synthesize loginId;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    time = [[NSMutableArray alloc] init];
    [timeTable registerClass:UITableViewCell.self forCellReuseIdentifier:@"TimeTableCell"];
    [self configureDatabase];

    // Do any additional setup after loading the view.
}

- (void)dealloc {
    [[ref child:@"Students/2013111564/lecture"] removeObserverWithHandle:_refHandle];
}

- (void)configureDatabase {
    ref = [[FIRDatabase database] reference];
    // Listen for new messages in the Firebase database
    _refHandle = [[ref child:@"Students/2013111564/lecture"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        NSLog(@"%@", snapshot);
        [time addObject:snapshot];
        NSLog(@"%lu", (unsigned long)time.count);
        [timeTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:time.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationAutomatic];
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
    return time.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // Dequeue cell
    UITableViewCell *cell = [timeTable dequeueReusableCellWithIdentifier:@"TimeTableCell" forIndexPath:indexPath];
    
    // Unpack message from Firebase DataSnapshot
    FIRDataSnapshot *timeSnapshot = time[indexPath.row];
    NSDictionary<NSString *, NSString *> *time = timeSnapshot.value;
    NSString *name = time[timeFieldsname];
    cell.textLabel.text = [NSString stringWithFormat:@"%@" ,name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FIRDataSnapshot *temp = time[indexPath.row];
    NSDictionary<NSString *, NSString *> *temp2 = temp.value;
    sendTitle = temp2[timeFieldsname];
    [self performSegueWithIdentifier:@"toDetailSubjectView" sender:self];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"toDetailSubjectView"])
    {
        combineViewController *deptVC = [segue destinationViewController];
        
        deptVC.title = sendTitle;
        deptVC.loginId = loginId;
    }
}


@end
