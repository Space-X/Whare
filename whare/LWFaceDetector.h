//
//  LWFaceDetector.h
//  OpenCVFaceVerifier
//
//  Created by LaoWen on 16/5/12.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol LWFaceDetectorDelegate <NSObject>

@optional
- (void)onFaceDetected:(UIImage *)faceImage;//检测到人脸

//- (void)onFaceVerified:(UIImage *)faceImage confidence:(double)confidence;//人脸验证完成
- (void)onFaceVerified:(NSDictionary *)args;

- (void)onMessage:(NSString *)message;

@end

//本类需要提供如下接口：


//3. 每捕捉到一帧画面检测其中的人脸并画框，如果已学习过（人脸模型库不为空）则验证其中的人脸是否与之前录入的相同（调用者可以指定confidence的阈值）,如果confidence<阈值则认为相同并更新人脸模型库，并调用代理方法通知人脸验证成功

@interface LWFaceDetector : NSObject

@property id<LWFaceDetectorDelegate> delegate;

//0. 初始化并加载人脸模型库
- (instancetype)initWithCameraView:(UIView *)view;

//1. 开始捕捉摄像头
- (void)startCapture;

//2. 停止捕捉摄像头
- (void)stopCapture;

- (void)startRecord;

- (void)recordFace;

- (void)startVerify;

@end
