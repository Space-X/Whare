//
//  AttendanceViewController.swift
//  whare
//
//  Created by LaoWen on 16/7/7.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

import UIKit

class AttendanceViewController: UIViewController, LWFaceDetectorDelegate {
    enum AttendanceType {//签到类型
        case SignIn
        case SignOut
    }

    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var labelLocation: UILabel!
    
    private var faceDetector: LWFaceDetector?
    private var attendanceType = AttendanceType.SignIn
    
    override func viewDidLoad() {
        super.viewDidLoad()

        faceDetector = LWFaceDetector(cameraView: cameraView)
        faceDetector?.delegate = self
    }

    //签到
    @IBAction func onBtnSignInClicked(sender: UIButton) {
        attendanceType = .SignIn
        faceDetector?.startVerify()
    }

    //签退
    @IBAction func onBtnSignOutClicked(sender: UIButton) {
        attendanceType = .SignOut
        faceDetector?.startVerify()
    }

    func onFaceVerified(args: [NSObject : AnyObject]!) {
        switch attendanceType {
        case .SignIn:
            print("签到完成")
        case .SignOut:
            print("签退完成")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        faceDetector?.startCapture()
    }
    
    override func viewWillDisappear(animated: Bool) {
        faceDetector?.stopCapture()
    }
}
