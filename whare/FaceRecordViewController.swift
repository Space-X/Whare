//
//  FaceRecordViewController.swift
//  whare
//
//  Created by LaoWen on 16/7/6.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

import UIKit

class FaceRecordViewController: UIViewController, LWFaceDetectorDelegate, FaceRecordConfirmDelegate {
    
    @IBOutlet weak var cameraView: UIView!

    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var recordTipMessage: UILabel!
    
    private var faceDetector: LWFaceDetector?
    private let requiredRecordCount = 3//需要录入人脸的次数
    private var validRecordCount = 0//已经录入人脸的次数
    private var faceImage:UIImage?//采集到的人脸
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if NSUserDefaults.standardUserDefaults().boolForKey("faceRecorded") == true {//TODO:如果不写==true意思完全一样吗
            let alert = UIAlertController(title: "不能录脸", message: "您已经录过脸了，如果要重新录入请先到“我的”页面清除录脸结果", preferredStyle: .Alert)
            let actionConfirm = UIAlertAction(title: "确认", style: .Default, handler: { (action) in
                self.navigationController?.popViewControllerAnimated(true)
            })
            alert.addAction(actionConfirm)
            presentViewController(alert, animated: true, completion: nil)
        } else {
            faceDetector = LWFaceDetector(cameraView: cameraView)
            faceDetector?.delegate = self
        }
    }

    //人脸检测模块传来信息
    func onMessage(message: String!) {
        self.message.text = message
    }
    
    func onFaceDetected(faceImage: UIImage!) {
        print("检测到人脸")
        self.faceImage = faceImage//TODO:这里能不能直接得到segue
        self.performSegueWithIdentifier("FaceRecordConfirm", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let faceRecordConfirmVC = segue.destinationViewController as! FaceRecordConfirmViewController
        faceRecordConfirmVC.faceImage = faceImage
        faceRecordConfirmVC.delegate = self
        faceImage = nil
    }
    
    //本次人脸录入结果保留
    func faceRecordConfirm(sender: FaceRecordConfirmViewController) {
        validRecordCount += 1
        recordTipMessage.text = "您需要录脸\(requiredRecordCount), 这是第\(validRecordCount+1)次"
        if validRecordCount >= requiredRecordCount {//录脸完成
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "faceRecorded")//TODO:键名统一管理
            //TODO:增加清除已录脸，允许重新录脸
            //提示用户录脸完成
            let alert = UIAlertController(title: "录入完成", message: nil
            , preferredStyle: .Alert)
            let actionConfirm = UIAlertAction(title: "确认", style: .Default, handler: { (action: UIAlertAction) in
                self.navigationController?.popViewControllerAnimated(true)
            })
            alert.addAction(actionConfirm)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //本次人脸录入结果取消
    func faceRecordCancel(sender: FaceRecordConfirmViewController) {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        faceDetector?.startCapture()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        faceDetector?.stopCapture()
    }

    //开始人脸识别
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        faceDetector?.startRecord()
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
    
    }
}
