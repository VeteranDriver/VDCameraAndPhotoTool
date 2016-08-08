//
//  CameraAndPhotoTool.h
//  sheet
//
//  Created by lyb on 16/3/22.
//  Copyright © 2016年 lyb. All rights reserved.
//  调用系统相机和相册的工具类

#import <UIKit/UIKit.h>

typedef void(^cameraReturn)(UIImage *image);
typedef void(^videoReturn)(NSURL *videoUrl);

@interface VDCameraAndPhotoTool : NSObject<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

+ (instancetype)shareInstance;

- (void)showVideoInViewController:(UIViewController *)vc andFinishBack:(videoReturn)finishBack;
/**
 *  调用系统相机
 *
 *  @param vc         要调用相机的控制器
 *  @param finishBack 拍照完成的回调
 */
- (void)showCameraInViewController:(UIViewController *)vc andFinishBack:(cameraReturn)finishBack;
/**
 *  调用系统相册
 *
 *  @param vc         要调用相册的控制器
 *  @param finishBack 选择完成的回调
 */
- (void)showPhotoInViewController:(UIViewController *)vc andFinishBack:(cameraReturn)finishBack;

/**
 *  显示相机或相册（弹出alert）
 *
 *  @param vc        控制器
 *  @param finsished 完成回掉
 */
- (void)showImagePickerController:(UIViewController *)vc andFinishBack:(cameraReturn)finishBack;

@end
