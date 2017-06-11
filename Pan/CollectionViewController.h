//
//  CollectionViewController.h
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 6. 11..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;

@interface CollectionViewController : UIViewController<UICollectionViewDelegate , UICollectionViewDataSource>{
}

@property (strong, nonatomic) NSString *loginId;
@property (strong, nonatomic) IBOutlet UICollectionView *ImageCollectionView;
@property (strong, nonatomic) IBOutlet UICollectionView *AudioCollectionView;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *images;
@property (strong, nonatomic) FIRStorageReference *storageRef;

@end
