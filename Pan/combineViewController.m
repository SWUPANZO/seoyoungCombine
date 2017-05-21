//
//  combineViewController.m
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 5. 16..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import "combineViewController.h"

@interface combineViewController ()<UITableViewDataSource, UITableViewDelegate,
UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
FIRInviteDelegate> {
    int _msglength;
    FIRDatabaseHandle _refHandle;
}

@end

@implementation combineViewController

@synthesize functionView;
@synthesize weekTable;
@synthesize week;
@synthesize ref;
@synthesize storageRef;
@class remoteConfig;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.functionView setHidden:YES];
    
    week = [[NSMutableArray alloc] init];
    [weekTable registerClass:UITableViewCell.self forCellReuseIdentifier:@"tableViewCell"];
    
    [self configureDatabase];
    // Do any additional setup after loading the view.
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


- (IBAction)showView:(id)sender {
        [self.functionView setHidden:NO];
    
}

- (IBAction)pushCamera:(id)sender {
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)pushVideo:(id)sender {
    [self startCameraControllerFromViewController:self usingDelegate:self];
}

-(BOOL)startCameraControllerFromViewController:(UIViewController*)controller
                                 usingDelegate:(id )delegate {
    // 1 - Validattions
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil)) {
        return NO;
    }
    // 2 - Get image picker
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    // Displays a control that allows the user to choose movie capture
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = delegate;
    // 3 - Display image picker
    [self presentViewController: cameraUI animated:YES completion:nil];
    return YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:NO completion:nil];
    // Handle a movie capture
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(moviePath, self,
                                                @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    NSLog(@"data :%i",[UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]);
    image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Title"
                                 message:@"Message"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* errorButton = [UIAlertAction
                                  actionWithTitle:@"Video Saving Failed"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      //Handle your yes please button action here
                                  }];
    
    UIAlertAction* saveButton = [UIAlertAction
                                 actionWithTitle:@"Saved To Photo Album"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     //Handle your yes please button action here
                                 }];
    
    if (error){
        
        [alert addAction:errorButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        
        [alert addAction:saveButton];
        
        [self presentViewController:alert animated:YES completion:nil];    }
}



- (IBAction)pushMemo:(id)sender {
}


//주차별 리스트
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
    cell.textLabel.text = [NSString stringWithFormat:@"%@주차", title];
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
