//
//  TZImagePickerHelper.h
//  TZImagePickerControllerDemoZH
//
//  Created by 曾浩 on 2017/4/12.
//  Copyright © 2017年 曾浩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TZImagePickerController.h"

@interface TZImagePickerHelper : NSObject<UINavigationControllerDelegate,  UIImagePickerControllerDelegate, TZImagePickerControllerDelegate>

/**
 完成后返回图片路径数组
 */
@property (nonatomic, copy) void(^finish)(NSArray *array);


/**
 打开手机图片库

 @param maxCount 最大张数
 @param superController superController 
 */
- (void)showImagePickerControllerWithMaxCount:(NSInteger )maxCount WithViewController: (UIViewController *)superController;

@end
