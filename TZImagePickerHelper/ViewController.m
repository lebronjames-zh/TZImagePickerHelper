//
//  ViewController.m
//  TZImagePickerHelper
//
//  Created by 曾浩 on 2017/4/13.
//  Copyright © 2017年 曾浩. All rights reserved.
//

/*
 TZImagePickerController来源于banchichen的优秀开源项目：TZImagePickerController
 github链接：https://github.com/banchichen/TZImagePickerController
 我对这个类的使用进行封装成TZImagePickerHelper；
 感谢banchichen的优秀代码~
 我对banchichen的TZImagePickerController demo的代码进行了部分修改并封装了TZImagePickerHelper。
 */

#define WeakPointer(weakSelf) __weak __typeof(&*self)weakSelf = self
#define MAX_COUNT 5

#import "ViewController.h"
#import "LxGridViewFlowLayout.h"
#import "TZImageManager.h"
#import "TZImagePickerController.h"
#import "UIView+Layout.h"
#import "TZTestCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "TZVideoPlayerController.h"
#import "TZImagePickerHelper.h"

@interface ViewController ()<TZImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>
{
    CGFloat _itemWH;
    CGFloat _margin;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LxGridViewFlowLayout *layout;
@property (nonatomic, strong) NSMutableArray *imagesURL;

/**
 封装的获取图片工具类
 1. 初始化一个helper (需设置block回调已选择图片的路径数组);
 2. 调用showImagePickerControllerWithMaxCount:(NSInteger )maxCount WithViewController: (UIViewController *)superController;
 3. 调用结束后，刷新界面;
 */
@property (nonatomic, strong) TZImagePickerHelper *helper;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupView];
}

#pragma mark -- UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imagesURL.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TZTestCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZTestCell" forIndexPath:indexPath];
    cell.videoImageView.hidden = YES;
    if (indexPath.row == self.imagesURL.count)
    {
        cell.imageView.image = [UIImage imageNamed:@"AlbumAddBtn.png"];
        cell.deleteBtn.hidden = YES;
    }
    else
    {
        cell.imageView.image = [UIImage imageWithContentsOfFile:self.imagesURL[indexPath.row]];
        cell.deleteBtn.hidden = NO;
    }
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.imagesURL.count)
    {
        
        if ((MAX_COUNT - self.imagesURL.count) <= 0) return;
        
        [self.helper showImagePickerControllerWithMaxCount:(MAX_COUNT - self.imagesURL.count) WithViewController:self];
    }
    else
    {
        // preview photos or video / 预览照片或者视频
    }
}

#pragma mark -- 内部方法

/**
 删除
 
 @param sender sender
 */
- (void)deleteBtnClik:(UIButton *)sender
{
    [self.imagesURL removeObjectAtIndex:sender.tag];
    self.layout.itemCount = self.imagesURL.count;
    
    [self.collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [self.collectionView reloadData];
    }];
}

#pragma mark -- 页面布局

- (void)setupView
{
    [self.view addSubview:self.collectionView];
}

#pragma mark -- 懒加载

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 100, self.view.tz_width, self.view.tz_height - 300) collectionViewLayout:self.layout];
        CGFloat rgb = 244 / 255.0;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
        _collectionView.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.bounces  = NO;
        [_collectionView registerClass:[TZTestCell class] forCellWithReuseIdentifier:@"TZTestCell"];
    }
    return _collectionView;
}

- (LxGridViewFlowLayout *)layout
{
    if (!_layout) {
        _layout = [[LxGridViewFlowLayout alloc] init];
        _margin = 4;
        _itemWH = (self.view.tz_width - 2 * _margin - 4) / 3 - _margin;
        _layout.itemSize = CGSizeMake(_itemWH, _itemWH);
        _layout.minimumInteritemSpacing = _margin;
        _layout.minimumLineSpacing = _margin;
    }
    return _layout;
}

- (TZImagePickerHelper *)helper
{
    if (!_helper) {
        _helper = [[TZImagePickerHelper alloc] init];
        WeakPointer(weakSelf);
        _helper.finish = ^(NSArray *array){
            [weakSelf.imagesURL addObjectsFromArray:array];
            weakSelf.layout.itemCount = weakSelf.imagesURL.count;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.collectionView reloadData];
            });
        };
    }
    return _helper;
}

- (NSMutableArray *)imagesURL
{
    if (!_imagesURL) {
        _imagesURL = [NSMutableArray array];
    }
    return _imagesURL;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
