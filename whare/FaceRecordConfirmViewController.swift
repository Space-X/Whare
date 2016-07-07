//
//  FaceRecordConfirmViewController.swift
//  whare
//
//  Created by LaoWen on 16/7/7.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

import UIKit

protocol FaceRecordConfirmDelegate: class {//这里必须指定为class，否则声明代理指针的时候不能使用weak
    //确认本次录入
    func faceRecordConfirm(sender: FaceRecordConfirmViewController)
    //取消本次录入
    func faceRecordCancel(sender: FaceRecordConfirmViewController)
}

class FaceRecordConfirmViewController: UIViewController {
    
    weak var delegate: FaceRecordConfirmDelegate?
    
    var faceImage: UIImage?
    
    @IBOutlet weak var faceImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        faceImageView.image = faceImage
    }

    //确认本次录入
    @IBAction func onBtnConfirmClicked(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)//TODO:exit segue和action哪个先执行，能指定吗？
        delegate?.faceRecordConfirm(self)
    }

    //取消本次录入
    @IBAction func onBtnCancelClicked(sender: UIButton) {
        delegate?.faceRecordCancel(self)
    }
}
