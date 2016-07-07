//
//  LWFaceDetector.m
//  OpenCVFaceVerifier
//
//  Created by LaoWen on 16/5/12.
//  Copyright © 2016年 LaoWen. All rights reserved.
//
#import <opencv2/highgui/cap_ios.h>
#import <Foundation/Foundation.h>
#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif
#import "UIImage+OpenCV.h"
using namespace cv;

#import "LWFaceDetector.h"

//注意：在Swift里使用OpenCV必须添加AssetsLibrary.framework（OC里不用）

#define SCALE 2.0
#define CONFICENCE_THRESHOLD 80

typedef enum{
    FACE_DETECT = 0,
    FACE_RECORD,
    FACE_VERIFY
} FaceMode;

@interface LWFaceDetector () <CvVideoCameraDelegate>
{
    CascadeClassifier _faceDetector;
    cv::Mat _faceImage;
    Ptr<FaceRecognizer> _faceClassifier;
    double _confidenceThreshold;//验证人脸是否为同一人的阈值
    FaceMode _faceMode;//工作模式，检测、录入、验证
    BOOL _isFaceRecored;//是否已经录入人脸
}

@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, weak)NSThread *ownerThread;

@end

@implementation LWFaceDetector

//0. 初始化并加载人脸模型库
- (instancetype)initWithCameraView:(UIView *)view
{
    if (self = [super init]) {
        //人脸检测相关
        self.videoCamera = [[CvVideoCamera alloc] initWithParentView:view];
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;//wenjunlin前置摄像头还是后置摄像头
        self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
        self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
        self.videoCamera.defaultFPS = 15;
        self.videoCamera.grayscaleMode = NO;
        self.videoCamera.delegate = self;
        self.scale = SCALE;
        
        NSString *faceCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2" ofType:@"xml"];
        
        const CFIndex CASCADE_NAME_LEN = 2048;
        char *CASCADE_NAME = (char *) malloc(CASCADE_NAME_LEN);
        CFStringGetFileSystemRepresentation( (CFStringRef)faceCascadePath, CASCADE_NAME, CASCADE_NAME_LEN);
        
        _faceDetector.load(CASCADE_NAME);
        
        free(CASCADE_NAME);
        
        //人脸识别相关
        _faceClassifier = createLBPHFaceRecognizer();
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/face"];
        if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
            _isFaceRecored = YES;
            _faceClassifier->load(path.UTF8String);
        }
        _confidenceThreshold = CONFICENCE_THRESHOLD;
        
        //=============================
        self.ownerThread = [NSThread currentThread];
        NSLog(@"ownerThread: %@", self.ownerThread);
    }
    return self;
}

//1. 开始捕捉摄像头
- (void)startCapture
{
    _faceMode = FACE_DETECT;
    [self.videoCamera start];
}

//2. 停止捕捉摄像头
- (void)stopCapture
{
    [self.videoCamera stop];
}

- (void)startRecord
{
    _faceMode = FACE_RECORD;
}

- (void)startVerify
{
    _faceMode = FACE_VERIFY;
}

//wenjunlin 代理中的方法，每捕捉到摄像头的一帧数据被调用一次，用来检测帧中的人脸并画出矩形
- (void)processImage:(cv::Mat&)image {
    // Do some OpenCV stuff with the image
    [self detectAndDrawFacesOn:image scale:_scale];
}

//wenjunlin 检测帧中的人脸并画出矩形
- (void)detectAndDrawFacesOn:(Mat&) img scale:(double) scale
{
    int i = 0;
    double t = 0;
    
    const static Scalar colors[] =  { CV_RGB(0,0,255),
        CV_RGB(0,128,255),
        CV_RGB(0,255,255),
        CV_RGB(0,255,0),
        CV_RGB(255,128,0),
        CV_RGB(255,255,0),
        CV_RGB(255,0,0),
        CV_RGB(255,0,255)} ;
    Mat gray, smallImg( cvRound (img.rows/scale), cvRound(img.cols/scale), CV_8UC1 );
    
    cvtColor( img, gray, COLOR_BGR2GRAY );
    resize( gray, smallImg, smallImg.size(), 0, 0, INTER_LINEAR );
    equalizeHist( smallImg, smallImg );
    
    t = (double)cvGetTickCount();
    double scalingFactor = 1.1;
    int minRects = 2;
    cv::Size minSize(30,30);
    
    vector<cv::Rect> faceRects;
    
    self->_faceDetector.detectMultiScale( smallImg, faceRects,
                                         scalingFactor, minRects, 0,
                                         minSize );
    
    t = (double)cvGetTickCount() - t;
    vector<cv::Mat> faceImages;
    
    if (faceRects.size() == 0) {
        return;
    }
    if (faceRects.size() > 1) {
        if ([_delegate respondsToSelector:@selector(onMessage:)]) {
            [_delegate onMessage:@"请确保屏幕中只有一张人脸"];
        }
        return;
    }
    //画每一个人脸的矩形框
    for( vector<cv::Rect>::const_iterator r = faceRects.begin(); r != faceRects.end(); r++, i++ )
    {
        cv::Mat smallImgROI;
        cv::Point center;
        Scalar color = colors[i%8];
        vector<cv::Rect> nestedObjects;
        rectangle(img,
                  cvPoint(cvRound(r->x*scale), cvRound(r->y*scale)),
                  cvPoint(cvRound((r->x + r->width-1)*scale), cvRound((r->y + r->height-1)*scale)),
                  color, 1, 8, 0);
        
        smallImgROI = smallImg(*r);
        
        faceImages.push_back(smallImgROI.clone());
        
        if (_faceMode == FACE_RECORD) {//人脸录入模式
            _faceImage = smallImgROI.clone();
            if ([_delegate respondsToSelector:@selector(onFaceDetected:)]) {
                [self stopCapture];//停止采集摄像头
                UIImage *faceImage = [UIImage imageFromCVMat:_faceImage];
                //[_delegate onFaceDetected:faceImage];
                [(NSObject *)_delegate performSelector:@selector(onFaceDetected:) onThread:self.ownerThread withObject:faceImage waitUntilDone:YES];
            }

        } else if (_faceMode == FACE_VERIFY) {//验证检测到的人脸与之前录入的是否相同
            
            if (!_isFaceRecored) {
                return;
            }
            
            int label;
            double confidence;
            
            self->_faceClassifier->predict(smallImgROI, label, confidence);
            if (confidence < _confidenceThreshold) {//人脸校验成功
                [self stopCapture];//停止检测
                if ([_delegate respondsToSelector:@selector(onFaceVerified:)]) {
                    UIImage *faceImage = [UIImage imageFromCVMat:smallImgROI.clone()];
                    [(NSObject *)_delegate performSelector:@selector(onFaceVerified:) onThread:self.ownerThread withObject:@{@"faceImage":faceImage, @"confidence":@(confidence)} waitUntilDone:YES];
                    
                    //用本次识别结果修正以前的识别结果
                    cv::Mat img = smallImgROI;
                    vector<cv::Mat> images = vector<cv::Mat>();
                    images.push_back(img);
                    vector<int> labels = vector<int>();
                    labels.push_back(0);
                    
                    self->_faceClassifier->update(images, labels);
                }
            }
        }
    }
}

- (void)recordFace
{
    cv::Mat img = _faceImage;
    vector<cv::Mat> images = vector<cv::Mat>();
    images.push_back(img);
    vector<int> labels = vector<int>();
    labels.push_back(0);
    
    self->_faceClassifier->update(images, labels);
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/face"];
    self->_faceClassifier->save(path.UTF8String);
    _isFaceRecored = YES;
}

@end
