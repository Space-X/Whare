//
//  VideoProgressSlider.swift
//  whare
//
//  Created by LaoWen on 16/7/1.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

import UIKit

class VideoProgressSlider: UISlider {

    override func awakeFromNib() {
        setThumbImage(UIImage(named: "VideoProgressThumb"), forState: .Normal)
    }

}
