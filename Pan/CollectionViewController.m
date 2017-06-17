//
//  CollectionViewController.m
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 6. 11..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import "CollectionViewController.h"
#import "ImageCollectionViewCell.h"
#import "AudioCollectionViewCell.h"
@import Firebase;

@interface CollectionViewController (){
    NSUInteger _imglength;
    FIRDatabaseHandle _ImgRefHandle;
    FIRDatabaseHandle _MemoRefHandle;
    FIRDatabaseHandle _AudioRefHandle;
}

@end

@implementation CollectionViewController{
    NSArray *array;
}
@synthesize loginId;
@synthesize lectureTitle;
@synthesize weekSelected;
@synthesize ImageCollectionView;
@synthesize AudioCollectionView;
@synthesize images;
@synthesize audios;
@synthesize ref;
@synthesize storageRef;
@synthesize mmemo,memoTable;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    images = [[NSMutableArray alloc] init];
    
    //이미지, 오디오 불러오기
    [ImageCollectionView setDelegate:self];
    [ImageCollectionView setDataSource:self];
    [AudioCollectionView setDelegate:self];
    [AudioCollectionView setDataSource:self];
    
    //메모 불러오기
    mmemo = [[NSMutableArray alloc] init];
    [memoTable registerClass:UITableViewCell.self forCellReuseIdentifier:@"MemoCell"];
    
    [self configureDatabase];
    [self configureStorage];
}
/*
- (void)dealloc {
    [[ref child:@"memos"] removeObserverWithHandle:_refHandle];
}
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureDatabase {
    ref = [[FIRDatabase database] reference];
    
    // Listen for new messages in the Firebase database
    _ImgRefHandle = [[[[[[ref child:@"Week"] child:loginId] child:weekSelected] child:lectureTitle] child: @"album"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [images addObject:snapshot];
        [ImageCollectionView insertItemsAtIndexPaths: @[[NSIndexPath indexPathForRow:images.count-1 inSection:0]]];
        //[collectView insertItemsAtIndexPaths: @[[NSIndexPath indexPathForRow:images.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationAutomatic];
        _imglength = images.count;
    }];
    
    _MemoRefHandle = [[[[[[ref child:@"Week"] child:loginId] child:weekSelected] child:lectureTitle] child: @"memo"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [mmemo addObject:snapshot];
            [memoTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:mmemo.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationAutomatic];
    //    _imglength = images.count;
    }];
/*
    _AudioRefHandle = [[[[[[ref child:@"Week"] child:loginId] child:weekSelected] child:lectureTitle] child: @"audio"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [audios addObject:snapshot];
        [AudioCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:audios.count-1 inSection:0]]];
       //    _imglength = images.count;
    }];
*/
                       
                       
}

- (void)configureStorage {
    self.storageRef = [[FIRStorage storage] reference];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(collectionView == ImageCollectionView){
        return images.count;
    } else if (collectionView == AudioCollectionView){
        return 1;
    }
    
    return 0;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    
    if(cv == self.ImageCollectionView){
        NSString *cellIdentifier = @"ImageCell";
        ImageCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        FIRDataSnapshot *imageSnapshot = images[indexPath.row];
        NSString *imageURL = imageSnapshot.value;
        [[[FIRStorage storage] referenceForURL:imageURL] dataWithMaxSize:INT64_MAX
                                                              completion:^(NSData *data, NSError *error) {
                                                                  if (error) {
                                                                      NSLog(@"Error downloading: %@", error);
                                                                      return;
                                                                  }
                                                                  [cell.imgBg setImage:[UIImage imageWithData:data]];
                                                              }];
        return cell;
    } else if (cv == self.AudioCollectionView){
        NSString *cellIdentifier = @"AudioCell";
        AudioCollectionViewCell *cell = [AudioCollectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        [cell.audioBg setTitle: @"버튼" forState:UIControlStateNormal];
        return cell;
    }
    
    return nil;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return mmemo.count;
}
    

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // Dequeue cell
    UITableViewCell *cell = [memoTable dequeueReusableCellWithIdentifier:@"MemoCell" forIndexPath:indexPath];
    
    // Unpack message from Firebase DataSnapshot
    FIRDataSnapshot *timeSnapshot = mmemo[indexPath.row];
    NSLog(@"time snapshot : %@", timeSnapshot.value);
    cell.textLabel.text = [NSString stringWithFormat:@"%@" ,timeSnapshot.value];
    
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
