//
//  CameraAndPhotoTool.m
//  sheet
//
//  Created by lyb on 16/3/22.
//  Copyright © 2016年 lyb. All rights reserved.
//

#import "VDCameraAndPhotoTool.h"
#import "UIImage+Extension.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef enum {
    
    photoType,
    cameraType,
    videoType
}pickerType;
static VDCameraAndPhotoTool *tool ;

@interface VDCameraAndPhotoTool ()<UIActionSheetDelegate>

@property (nonatomic, copy)cameraReturn finishBack;

@property (nonatomic, strong) UIActionSheet *actionSheet;

@property(nonatomic, weak)UIViewController *fromVc;

@property (nonatomic, strong) UIImagePickerController *picker;


@end


@implementation VDCameraAndPhotoTool

+ (instancetype)shareInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        tool = [[VDCameraAndPhotoTool alloc] init];
    });
    
    return tool;
}


- (void)showVideoInViewController:(UIViewController *)vc andFinishBack:(cameraReturn)finishBack {
    
    if (finishBack) {
        
        self.finishBack = finishBack;
    }
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    [self setUpImagePicker:videoType];
    
    [vc presentViewController:self.picker animated:YES completion:nil];//进入照相界面
    [vc.view layoutIfNeeded];
}


- (void)showCameraInViewController:(UIViewController *)vc andFinishBack:(cameraReturn)finishBack {
    
    if (finishBack) {
        
        self.finishBack = finishBack;
    }
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    [self setUpImagePicker:cameraType];
    
    [vc presentViewController:self.picker animated:YES completion:nil];//进入照相界面
    [vc.view layoutIfNeeded];
}

- (void)showPhotoInViewController:(UIViewController *)vc andFinishBack:(cameraReturn)finishBack{
    
    if (finishBack) {
        
        self.finishBack = finishBack;
    }
    
   [self setUpImagePicker:photoType];
    
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [vc presentViewController:self.picker animated:YES completion:nil];//进入相册界面
    [vc.view layoutIfNeeded];

}

#pragma mark - imagePicker delegate
/**
 *  完成回调
 *
 *  @param picker imagePickerController
 *  @param info   信息字典
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);
            });
        }
        
        //根据屏幕方向裁减图片(640, 480)||(480, 640),如不需要裁减请注释
        image = [UIImage resizeImageWithOriginalImage:image];
        
        if (self.finishBack) {
            
            self.finishBack(image,nil);
        }
        
        [picker dismissViewControllerAnimated:YES completion:nil];
        
    }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        
        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        NSString *urlStr=[url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
            
            //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
        }
    }
    
    
}

//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {//可以在此解析错误
        
    }else{//保存成功
        
        //录制完之后自动播放
        if (self.finishBack) {
            
            self.finishBack(nil,videoPath);
        }
        
       [self.picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)showImagePickerController:(UIViewController *)vc andFinishBack:(cameraReturn)finishBack{
    
    if (finishBack) {
        
        self.finishBack = finishBack;
    }
    
    if (vc) {
        
        self.fromVc = vc;
        [self.actionSheet showInView:vc.view];
    }
    
}


- (void)setUpImagePicker:(pickerType )type {
    
    self.picker = nil;
    
    self.picker = [[UIImagePickerController alloc] init];//初始化
    self.picker.delegate = self;
    self.picker.allowsEditing = NO;//设置不可编辑
    
    if (type == photoType) {
        
        //判断用户是否允许访问相册权限
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
            //无权限
            return;
        }
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        self.picker.sourceType = sourceType;
    }else if (type == cameraType){
        //判断用户是否允许访问相机权限
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
        {
            //无权限
            return;
        }
        //判断用户是否允许访问相册权限
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
            //无权限
            return;
        }
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        self.picker.sourceType = sourceType;
        
        
    }else if (type == videoType) {
        //判断用户是否允许访问相机权限
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
        {
            //无权限
            return;
        }
        
        //判断用户是否允许访问麦克风权限
        authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
        {
            //无权限
            return;
        }

        //判断用户是否允许访问相册权限
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
            //无权限
            return;
        }
        
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        self.picker.sourceType = sourceType;
        
        self.picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        self.picker.videoQuality=UIImagePickerControllerQualityTypeIFrame1280x720;
        self.picker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;
       
    }
    
}

#pragma mark - actionsheet delegate


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        
        [self showCameraInViewController:self.fromVc andFinishBack:nil];
        
    }else if (buttonIndex == 1) {
        
        [self showPhotoInViewController:self.fromVc andFinishBack:nil];
        
    }else if (buttonIndex == 2) {
        
        [self showVideoInViewController:self.fromVc andFinishBack:nil];
    }

}



#pragma mark - getter and setter

- (UIActionSheet *)actionSheet {
    if (_actionSheet == nil) {
        _actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册",@"录像", nil];
    }
    return _actionSheet;
}
@end
