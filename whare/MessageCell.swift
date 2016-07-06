//
//  MessageCell.swift
//  whare
//
//  Created by LaoWen on 16/7/5.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var displayName: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var message: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
