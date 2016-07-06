//
//  VideoViewController.swift
//  whare
//
//  Created by LaoWen on 16/6/30.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

import UIKit
import SnapKit//Masonry在swift中不大好用（mas_equalTo是个宏，在swift里好像去找了一个同名的没参数的方法，编译不过去）

class VideoViewController: UIViewController {

    let kUrlVideo1 = "http://wen.local/1.mp4"
    let kUrlVideo2 = "http://wen.local/0101/0101.m3u8"
    
    var videoView: VideoView?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let url = NSURL(string: kUrlVideo1)
        if url != nil {
            videoView = VideoView.videoView(url, superView: self.view)
            //videoView?.shouldAutoRotate = false
            
            //设置横竖屏的约束
            videoView?.setLayout({ (make: ConstraintMaker) in//竖屏
                make.left.equalTo(self.view.snp_left)
                make.top.equalTo(self.view.snp_top).offset(20)
                make.right.equalTo(self.view.snp_right)
                let screenSize = self.view.bounds.size
                let screenWidth = min(screenSize.width, screenSize.height)
                let screenHeight = max(screenSize.width, screenSize.height)
                let videoViewHeight = screenWidth/screenHeight*screenWidth
                make.height.equalTo(videoViewHeight)
                }, landscape: { (make: ConstraintMaker) in//横屏
                let size = self.view.bounds.size
                let width = max(size.width, size.height)
                let height = min(size.width, size.height)
                make.width.equalTo(width)
                make.height.equalTo(height)
                make.center.equalTo(self.view)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //课程直播
    @IBAction func onBtnCourseClicked(sender: UIButton) {
        videoView?.pause()
        videoView?.videoUrl = NSURL(string: kUrlVideo1)
        videoView?.play()
    }

    //教室监控
    @IBAction func onBtnClassroomClicked(sender: UIButton) {
        videoView?.pause()
        videoView?.videoUrl = NSURL(string: kUrlVideo2)
        videoView?.play()
    }
    
    @IBAction func onBtnBackClicked(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
