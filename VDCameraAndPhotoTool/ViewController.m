//
//  ViewController.m
//  VDCameraAndPhotoTool
//
//  Created by lyb on 16/8/8.
//  Copyright © 2016年 lyb. All rights reserved.
//

#import "ViewController.h"
#import "VDCameraAndPhotoTool.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (strong ,nonatomic) AVPlayer *player;//播放器，用于录制完视频后播放视频

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

- (IBAction)cameraClick:(id)sender {
    
    [[VDCameraAndPhotoTool shareInstance] showCameraInViewController:self andFinishBack:^(UIImage *image,NSString *videoPath) {
        
        [self removePlayerLayer];
        
        if (image) {
            
            self.imgView.image = image;
        }
    }];

}

- (IBAction)sheetClick:(id)sender {
    
    [[VDCameraAndPhotoTool shareInstance] showImagePickerController:self andFinishBack:^(UIImage *image,NSString *videoPath) {
        
        if (image) {//图片
            
            [self removePlayerLayer];
            
            self.imgView.image = image;
        }
        
        if (videoPath) {//视频
            
            self.imgView.image = nil;
            
            [self addPlayerLayer:videoPath];
        }
    }];
}
- (IBAction)photoClick:(id)sender {
    
    [[VDCameraAndPhotoTool shareInstance] showPhotoInViewController:self andFinishBack:^(UIImage *image,NSString *videoPath) {
        
        [self removePlayerLayer];
        
        if (image) {
            
            self.imgView.image = image;
        }
        
    }];
}


- (IBAction)videoClick:(id)sender {
    
    [[VDCameraAndPhotoTool shareInstance] showVideoInViewController:self andFinishBack:^(UIImage *image,NSString *videoPath) {
        
        if (videoPath) {
            
            self.imgView.image = nil;
            
            [self addPlayerLayer:videoPath];
        }
        
    }];
}

/**
 *  移除player
 */
- (void)removePlayerLayer {
    
    for (CALayer *layer in self.imgView.layer.sublayers) {
        
        if ([layer isKindOfClass:[AVPlayerLayer class]]) {
            
            [layer removeFromSuperlayer];
            self.player = nil;
        }
    }
}

/**
 *  添加player
 */
- (void)addPlayerLayer:(NSString *)videoPath {
    
    NSURL *url = [NSURL fileURLWithPath:videoPath];
    _player = [AVPlayer playerWithURL:url];
    AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = self.imgView.frame;
    [self.imgView.layer addSublayer:playerLayer];
    [_player play];
}

@end
