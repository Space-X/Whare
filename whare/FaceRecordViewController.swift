//
//  FaceRecordViewController.swift
//  whare
//
//  Created by LaoWen on 16/7/6.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

import UIKit

class FaceRecordViewController: UIViewController, LWFaceDetectorDelegate {
    
    @IBOutlet weak var cameraView: UIView!

    @IBOutlet weak var message: UILabel!
    
    private var faceDetector: LWFaceDetector!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        faceDetector = LWFaceDetector(cameraView: cameraView)
        faceDetector.delegate = self
    }

    //人脸检测模块传来信息
    func onMessage(message: String!) {
        self.message.text = message
    }
    
    func onFaceDetected(faceImage: UIImage!) {
        print("检测到人脸")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        faceDetector.startCapture()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        faceDetector.stopCapture()
    }

    //开始人脸识别
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        faceDetector.startRecord()
    }
}
