//
//  CameraAndPhotoTool.m
//  sheet
//
//  Created by lyb on 16/3/22.
//  Copyright © 2016年 lyb. All rights reserved.
//

#import "VDCameraAndPhotoTool.h"
#import "UIImage+Extension.h"

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.picker = [[UIImagePickerController alloc] init];//初始化
        self.picker.delegate = self;
        self.picker.allowsEditing = NO;//设置不可编辑
    }
    return self;
}

- (void)showCameraInViewComtroller:(UIViewController *)vc andFinishBack:(cameraReturn)finishBack {
    
    if (finishBack) {
        
        self.finishBack = finishBack;
    }
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    self.picker.sourceType = sourceType;
    [vc presentViewController:self.picker animated:YES completion:nil];//进入照相界面
    [vc.view layoutIfNeeded];
}

- (void)showPhotoInViewComtroller:(UIViewController *)vc andFinishBack:(cameraReturn)finishBack{
    
    if (finishBack) {
        
        self.finishBack = finishBack;
    }
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    self.picker.sourceType = sourceType;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [vc presentViewController:self.picker animated:YES completion:nil];//进入相册界面
    [vc.view layoutIfNeeded];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);
        });
    }
    
   //根据屏幕方向裁减图片(640, 480)||(480, 640),如不需要裁减请注释
    image = [UIImage resizeImageWithOriginalImage:image];
    
    if (self.finishBack) {
        
        self.finishBack(image);
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
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


#pragma mark - actionsheet delegate


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        
        [self showCameraInViewComtroller:self.fromVc andFinishBack:nil];
        
    }else if (buttonIndex == 1) {
        
        [self showPhotoInViewComtroller:self.fromVc andFinishBack:nil];
    }

}



#pragma mark - getter and setter

- (UIActionSheet *)actionSheet {
    if (_actionSheet == nil) {
        _actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册", nil];
    }
    return _actionSheet;
}
@end
