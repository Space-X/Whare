//
//  VideoRecognizer.swift
//  whare
//
//  Created by LaoWen on 16/7/1.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass//坑：Swift必须包含这个模块，否则坑坑坑

class VideoRecognizer: UIPanGestureRecognizer {
    enum Direction {
        case Unknown
        case Horizontal
        case Vertical
    }
    enum Position {
        case Unknown
        case Left
        case Right
    }
    
    var direction: Direction = .Unknown//TODO:做成只读属性
    var position: Position = .Unknown
    var delta: CGFloat = 0
    
    private var startPoint: CGPoint!
    private var lastPoint: CGPoint!
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        startPoint = touches.first!.locationInView(self.view)
        lastPoint = startPoint
        self.state = .Began
        direction = .Unknown
        
        let width = self.view!.bounds.size.width
        if startPoint.x < width/2 {
            position = .Left
        } else {
            position = .Right
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let width = self.view!.bounds.size.width
        let height = self.view!.bounds.size.height
        
        let currentPoint = touches.first!.locationInView(self.view)
        let tanX = (currentPoint.y-startPoint.y)/(currentPoint.x-startPoint.x)//与X轴夹角

        if abs(tanX) < sqrt(3)/3 {
            //与X轴夹角小于30度，认为是水平
            if direction == .Unknown {
                direction = .Horizontal
            }
            delta = (currentPoint.x-lastPoint.x)/width
            state = .Changed
        }

        if abs(tanX) > sqrt(3) {
            //与X轴夹角大于60度，认为是垂直
            if direction == .Unknown {
                direction = .Vertical
            }
            delta = -(currentPoint.y-lastPoint.y)/height
        }
        lastPoint = currentPoint
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        state = .Ended
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        state = .Cancelled
    }
}
