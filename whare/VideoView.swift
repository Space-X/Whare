//
//  VideoView.swift
//  whare
//
//  Created by LaoWen on 16/6/30.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

public class VideoView: UIView {
    
    public var videoUrl: NSURL? {
        didSet {
            if videoUrl == nil {
                return
            }
            avPlayerItem = AVPlayerItem(URL: videoUrl!)
            if avPlayerItem != nil {
                avPlayer = AVPlayer(playerItem: avPlayerItem!)
                (self.layer as! AVPlayerLayer).player = avPlayer
                activityIndicatorView.startAnimating()
                activityIndicatorView.hidden = false
                
                addKVOs()
            }

        }
    }
    public var avPlayerItem: AVPlayerItem? {
        willSet {//URL变化时会重新创建AVPlayerItem，老的AVPlayerItem会被删除。需要先把其KVO取消，否则会崩
            removeKVOs()
        }
    }
    public var avPlayer: AVPlayer?
    //TODO:改成外部只读
    public var isPlaying = false {
        didSet {
            if isPlaying {
                btnPlay.setBackgroundImage(UIImage(named: "Pause"), forState: .Normal)
            } else {
                btnPlay.setBackgroundImage(UIImage(named: "Play"), forState: .Normal)
            }
        }
    }
    public var shouldAutoRotate = true
    
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBOutlet weak var btnFullScreen: UIButton!
    
    @IBOutlet weak var progressSlider: UISlider!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var bottomView: UIView!
    
    private var isFullScreen = false {
        didSet {
            if isFullScreen {
                btnFullScreen.setBackgroundImage(UIImage(named: "SmallWindow"), forState: .Normal)
            } else {
                btnFullScreen.setBackgroundImage(UIImage(named: "FullScreen"), forState: .Normal)
            }
        }
    }
    private var theSuperView: UIView!
    private var isInitialLandscape = false;
    private var currentOrientation = UIDeviceOrientation.Unknown
    
    private var layoutPortrait: ((ConstraintMaker)->())?
    private var layoutLandscape: ((ConstraintMaker)->())?
    
    override public class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        currentOrientation = UIDeviceOrientation.Unknown
        shouldAutoRotate = true
        bottomView.backgroundColor = UIColor.clearColor()
        addNotifications()
        
        let videoRegonizer = VideoRecognizer(target: self, action: #selector(VideoView.onVideoRecognizer(_:)))
        addGestureRecognizer(videoRegonizer)
    }
    
    deinit {
        removeKVOs()
        removeNotifications()
    }

    public class func videoView(url:NSURL?, superView:UIView) -> VideoView? {
        if let view: VideoView = NSBundle.mainBundle().loadNibNamed("VideoView", owner: self, options: nil)[0] as? VideoView {
            view.videoUrl = url
            superView.addSubview(view)
            return view
        }
        return nil
    }
    
    func initialSetting() {
        addKVOs()
        addNotifications()
    }
    
    func addKVOs() {
        avPlayerItem?.addObserver(self, forKeyPath: "status", options: [.Old, .New], context: nil)
        avPlayerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: [.Old, .New], context: nil)
        avPlayerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: [.Old, .New], context: nil)
    }
    
    func removeKVOs() {
        avPlayerItem?.removeObserver(self, forKeyPath: "status")
        avPlayerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        avPlayerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
    }
    
    func addNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoView.onDeviceOriengationChanged(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
    }
    
    func removeNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
    }
    
    func play() {
        avPlayer?.play()
    }
    
    func pause() {
        avPlayer?.pause()
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let k = keyPath {
            switch k {
            case "status":
                onStatusChanged()
            case "playbackBufferEmpty":
                onPlaybackBufferEmpty()
            case "playbackLikelyToKeepUp":
                onPlaybackLikelyToKeepUp()
            default: break
                
            }
        }
    }
    
    func onStatusChanged() {
        print("onStatusChanged")
        switch avPlayerItem!.status {
        case .ReadyToPlay:
            let duration = avPlayerItem!.duration.value/Int64(avPlayerItem!.duration.timescale)
            progressSlider.maximumValue = Float(duration)//获取视频总时长
            
            //实时刷新播放进度
            avPlayer?.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue: dispatch_get_main_queue(), usingBlock: { (time: CMTime) in
                let progress = time.value/Int64(time.timescale)
                self.progressSlider.value = Float(progress)
            })
            
        case .Failed:
            print("播放失败")//TODO:显示失败信息
            
        case .Unknown:
            print("视频状态未知")
        }

    }
    
    func onPlaybackBufferEmpty() {
        print("onPlaybackBufferEmpty")
        activityIndicatorView.startAnimating()
        activityIndicatorView.hidden = true
    }
    
    func onPlaybackLikelyToKeepUp() {
        print("onPlaybackLikelyToKeepUp")
        activityIndicatorView.stopAnimating()
        activityIndicatorView.hidden = true
    }
    
    @IBAction func onBtnPlayClicked(sender: UIButton) {
        if isPlaying {
            isPlaying = false
            pause()
        } else {
            isPlaying = true
            play()
        }
    }
    
    @IBAction func onBtnFullScreenClicked(sender: UIButton) {
        if isFullScreen {//进入窗口模式
            isFullScreen = false
            toOrientation(.Portrait)
        } else {//进入全屏模式
            isFullScreen = true
            toOrientation(.LandscapeLeft)
        }
    }

    func setLayout(portrait:(ConstraintMaker)->(), landscape:(ConstraintMaker)->()) {
        layoutPortrait = portrait
        layoutLandscape = landscape
        
        toOrientation(UIDeviceOrientation.Portrait)//TODO:去掉，依懒旋转通知
    }
    
    func toOrientation(orientation: UIDeviceOrientation) {
        switch orientation {
        case .LandscapeLeft:
            if layoutLandscape != nil {
                self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                self.superview!.bringSubviewToFront(self)
                self.snp_remakeConstraints(closure: layoutLandscape!)
                isFullScreen = true
            }
        case .LandscapeRight:
            if layoutLandscape != nil {
                self.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                self.superview!.bringSubviewToFront(self)
                self.snp_remakeConstraints(closure: layoutLandscape!)
                isFullScreen = true
            }
        default:
            if layoutPortrait != nil {
                self.transform = CGAffineTransformIdentity
                self.snp_remakeConstraints(closure: layoutPortrait!)
                isFullScreen = false
            }
        }
    }
    
    func onDeviceOriengationChanged(notification: NSNotification) {
        if !shouldAutoRotate {
            return
        }
        let orientation = UIDevice.currentDevice().orientation
        toOrientation(orientation)
    }
    
    func onVideoRecognizer(sender: VideoRecognizer) {
        switch sender.direction {
        case .Horizontal:
            print("播放进度:\(sender.delta)")
        case .Vertical:
            switch sender.position {
            case .Left:
                //print("亮度:\(sender.delta)")
                UIScreen.mainScreen().brightness += sender.delta
                print("亮度:\(UIScreen.mainScreen().brightness)")
            case .Right:
                print("音量:\(sender.delta)")
            default:
                break
            }
        default:
            break
        }
    }
}
