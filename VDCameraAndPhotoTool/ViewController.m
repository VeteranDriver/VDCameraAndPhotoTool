//
//  ViewController.m
//  VDCameraAndPhotoTool
//
//  Created by lyb on 16/8/8.
//  Copyright © 2016年 lyb. All rights reserved.
//

#import "ViewController.h"
#import "VDCameraAndPhotoTool.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}
- (IBAction)cameraClick:(id)sender {
    
    [[VDCameraAndPhotoTool shareInstance] showCameraInViewComtroller:self andFinishBack:^(UIImage *image) {
        
        self.imgView.image = image;
    }];
}

- (IBAction)sheetClick:(id)sender {
    
    [[VDCameraAndPhotoTool shareInstance] showImagePickerController:self andFinishBack:^(UIImage *image) {
        
        self.imgView.image = image;
    }];
}
- (IBAction)photoClick:(id)sender {
    
    [[VDCameraAndPhotoTool shareInstance] showPhotoInViewComtroller:self andFinishBack:^(UIImage *image) {
        
        self.imgView.image = image;
    }];
}


@end
