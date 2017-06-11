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
    FIRDatabaseHandle _refHandle;
}

@end

@implementation CollectionViewController
@synthesize loginId;
@synthesize ImageCollectionView;
@synthesize AudioCollectionView;
@synthesize images;
@synthesize ref;
@synthesize storageRef;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    images = [[NSMutableArray alloc] init];
    
    [ImageCollectionView setDelegate:self];
    [ImageCollectionView setDataSource:self];
    [AudioCollectionView setDelegate:self];
    [AudioCollectionView setDataSource:self];
    
    [self configureDatabase];
    [self configureStorage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureDatabase {
    ref = [[FIRDatabase database] reference];
    // Listen for new messages in the Firebase database
    _refHandle = [[[[[[ref child:@"Week"] child:@"2013111564"] child:@"week14"] child:@"팀플"] child: @"album"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [images addObject:snapshot];
        [ImageCollectionView insertItemsAtIndexPaths: @[[NSIndexPath indexPathForRow:images.count-1 inSection:0]]];
        //[collectView insertItemsAtIndexPaths: @[[NSIndexPath indexPathForRow:images.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationAutomatic];
        _imglength = images.count;
    }];
}

- (void)configureStorage {
    self.storageRef = [[FIRStorage storage] reference];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(collectionView == self.ImageCollectionView){
        return images.count;
    } else if (collectionView == self.AudioCollectionView){
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
