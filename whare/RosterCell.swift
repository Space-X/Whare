//
//  RosterCell.swift
//  whare
//
//  Created by LaoWen on 16/7/4.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

import UIKit

class RosterCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var displayName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
