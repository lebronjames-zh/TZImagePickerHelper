//
//  TZImagePickerHelper.m
//  TZImagePickerControllerDemoZH
//
//  Created by 曾浩 on 2017/4/12.
//  Copyright © 2017年 曾浩. All rights reserved.
//

#import "TZImagePickerHelper.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TZImagePickerController.h"
#import "NSString+Category.h"
#import "UIImage+Category.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "UIView+Alert.h"

@interface TZImagePickerHelper()<UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray *imagesURL;
@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, weak) UIViewController *superViewController;

@property (nonatomic, assign) CGFloat compressionQuality;

@end

@implementation TZImagePickerHelper

/**
 打开手机图片库
 
 @param superController superController description
 */
- (void)showImagePickerControllerWithMaxCount:(NSInteger )maxCount WithViewController: (UIViewController *)superController
{
    self.maxCount = maxCount;
    self.superViewController = superController;

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"去相册选择", nil];
    [sheet showInView:superController.view];
}

/**
 选取手机图片
 */
- (void)pushImagePickerController
{
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:self.maxCount delegate:self];
    
#pragma mark - 四类个性化设置，这些参数都可以不传，此时会走默认设置
    // imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    
    // 1.如果你需要将拍照按钮放在外面，不要传这个参数
    // imagePickerVc.selectedAssets = _selectedAssets; // optional, 可选的
    imagePickerVc.allowTakePicture = YES; // 在内部显示拍照按钮
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    //     imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    //     imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    //     imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        //NSLog(@"assets");
    }];
    
    [self.superViewController presentViewController:imagePickerVc animated:YES completion:nil];
}

/**
 拍照
 */
- (void)takePhoto
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && iOS8Later)
    {
        // 无权限 -> 提示
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
        
    }
    else
    {
        // 调用相机
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
            [ipc setSourceType:UIImagePickerControllerSourceTypeCamera];
            ipc.delegate = self;
            ipc.allowsEditing = YES;
            if ([[[UIDevice
                  currentDevice] systemVersion] floatValue] >= 8.0)
            {
                ipc.modalPresentationStyle=UIModalPresentationOverCurrentContext;
                //ipc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            }
            
            [self.superViewController presentViewController:ipc animated:YES completion:nil];
        }
        else
        {
            NSLog(@"模拟器中无法打开照相机,请在真机中使用");
        }
    }
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 去拍照、选取图片
    if (buttonIndex == 0)
    {
        [self takePhoto];
    }
    else if (buttonIndex == 1)
    {
        [self pushImagePickerController];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1)
    {
        // 去设置界面，开启相机访问权限
        if (iOS8Later)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        else
        {
            // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=Photos"]];
        }
    }
}


#pragma mark - TZImagePickerControllerDelegate

// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i<photos.count; i++)
        {
            UIImage *image = photos[i];
            // 1. 处理图片
            image = [self imageProcessing:image];
            // 2. 写入缓存
            NSString *filePath = [self imageDataWriteToFile:image];
            // 3. 加入数组、返回数组、重置数组
            [self.imagesURL addObject:filePath];
            self.finish(self.imagesURL);
            self.imagesURL = nil;
        }
    });
}

#pragma mark -- UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([picker.mediaTypes containsObject:(NSString *)kUTTypeImage])
    {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.superViewController.view showHUDWithText:@"处理中..."];
            });
            // 原图/编辑后的图片
            // UIImagePickerControllerOriginalImage/UIImagePickerControllerEditedImage
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            // 1. 处理图片
            image = [self imageProcessing:image];
            // 2. 写入缓存
            NSString *filePath = [self imageDataWriteToFile:image];
            // 3. 加入数组、返回数组、重置数组
            [self.imagesURL addObject:filePath];
            self.finish(self.imagesURL);
            self.imagesURL = nil;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.superViewController.view hideHUD];
            });
        });
    }
    
    [self.superViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [self.superViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- 内部方法

- (NSString *)imageDataWriteToFile:(UIImage *)image
{
    NSData *data;
    NSString *filePath =  [[NSString stringWithFormat:@"img_%d.jpg",arc4random()] cacheDic];
    if (UIImagePNGRepresentation(image) == nil)
    {
        data = UIImageJPEGRepresentation(image, self.compressionQuality);
    }
    else
    {
        // 将PNG转JPG
        [UIImageJPEGRepresentation(image, self.compressionQuality) writeToFile:filePath atomically:YES];
        UIImage *jpgImage = [UIImage imageWithContentsOfFile:filePath];
        data = UIImageJPEGRepresentation(jpgImage, self.compressionQuality);
    }
    
    [data writeToFile:filePath atomically:YES];
    return filePath;
}

/**
 处理图片

 @param image image
 @return return 新图片
 */
- (UIImage *)imageProcessing:(UIImage *)image
{
    UIImageOrientation imageOrientation = image.imageOrientation;
    if (imageOrientation != UIImageOrientationUp)
    {
        // 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会向左转９０度的现象。
        // 以下为调整图片角度的部分
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        // 调整图片角度完毕
    }
    
    CGSize imagesize = image.size;
    //质量压缩系数
    self.compressionQuality = 1;
    
    //如果大于两倍屏宽 或者两倍屏高
    if (image.size.width > 640 || image.size.height > 568*2)
    {
        self.compressionQuality = 0.5;
        //宽大于高
        if (image.size.width > image.size.height)
        {
            imagesize.width = 320*2;
            imagesize.height = image.size.height*imagesize.width/image.size.width;
        }
        else
        {
            imagesize.height = 568*2;
            imagesize.width = image.size.width*imagesize.height/image.size.height;
        }
    }
    else
    {
        self.compressionQuality = 0.6;
    }
    
    // 对图片大小进行压缩
    UIImage *newImage = [UIImage imageWithImage:image scaledToSize:imagesize];
    return newImage;
}

#pragma mark -- 懒加载

- (NSMutableArray *)imagesURL
{
    if (!_imagesURL) {
        _imagesURL = [NSMutableArray array];
    }
    return _imagesURL;
}

@end
